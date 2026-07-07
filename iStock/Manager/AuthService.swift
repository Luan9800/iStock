//
//  AuthService.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Combine
import FirebaseAuth
import FirebaseCore
import Foundation

enum MetodoLogin {
    case local
    case email
    case google
    case apple
    case desconhecido
}

enum AuthDeleteError: LocalizedError {
    case senhaObrigatoria
    case metodoNaoSuportado

    var errorDescription: String? {
        switch self {
        case .senhaObrigatoria: return "Informe sua senha para confirmar a exclusão."
        case .metodoNaoSuportado: return "Não foi possível confirmar sua identidade para excluir a conta."
        }
    }
}

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var usuario: User?
    @Published var usuarioLocal: ContaLocal?
    @Published var erro: String?
    @Published var mensagemSucesso: String?
    @Published var carregando = false
    @Published private(set) var usandoLoginLocal = false
    @Published private(set) var papelAtual: PapelUsuario?

    private var handle: AuthStateDidChangeListenerHandle?

    private init() {
        if let conta = LocalAuthStore.shared.contaAtual() {
            usuarioLocal = conta
            usandoLoginLocal = true
            papelAtual = conta.papel
            LancamentoService.shared.carregarLocal()
            AvaliacaoService.shared.carregarLocal()
            TransacaoLogService.shared.carregarLocal()
            ModeloFotoService.shared.carregarLocal()
            sincronizarPerfil()
        }
        configurarListenerSeNecessario()
    }

    func configurarListenerSeNecessario() {
        guard handle == nil, FirebaseApp.app() != nil else { return }
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                if user != nil {
                    self.limparSessaoLocal()
                }
                self.usuario = user
                FirebaseSyncCoordinator.shared.atualizarEstadoAuth(usuarioFirebase: user)
                self.sincronizarPerfil()
                if user != nil {
                    Task { await self.carregarPapelUsuario() }
                } else {
                    self.papelAtual = nil
                }
            }
        }

        if let user = Auth.auth().currentUser {
            usuario = user
            FirebaseSyncCoordinator.shared.atualizarEstadoAuth(usuarioFirebase: user)
            Task { await carregarPapelUsuario() }
        }
    }

    var ehAdministrador: Bool { papelAtual == .administrador }

    var estaLogado: Bool { usuario != nil || usuarioLocal != nil }

    var autenticadoNaNuvem: Bool { usuario != nil }

    var uid: String? { usuario?.uid ?? usuarioLocal?.id }

    var nomeOuEmail: String {
        if let local = usuarioLocal { return local.nome }
        if let usuario, let nome = usuario.displayName, !nome.isEmpty { return nome }
        return usuario?.email ?? ""
    }

    var emailExibicao: String? {
        if let local = usuarioLocal { return local.email }
        return usuario?.email
    }

    var metodoLoginAtual: MetodoLogin {
        if usandoLoginLocal { return .local }
        guard let usuario else { return .desconhecido }
        let provedores = usuario.providerData.map(\.providerID)
        if provedores.contains("google.com") { return .google }
        if provedores.contains("apple.com") { return .apple }
        if provedores.contains("password") { return .email }
        return .desconhecido
    }

    var exigeSenhaParaExcluir: Bool {
        metodoLoginAtual == .local || metodoLoginAtual == .email
    }

    var descricaoMetodoExclusao: String {
        switch metodoLoginAtual {
        case .local:
            return "Sua conta local será removida deste dispositivo."
        case .email:
            return "Sua conta na nuvem será excluída permanentemente. Informe sua senha para confirmar."
        case .google:
            return "Sua conta na nuvem será excluída. Será necessário confirmar com o Google."
        case .apple:
            return "Sua conta na nuvem será excluída. Será necessário confirmar com a Apple."
        case .desconhecido:
            return "Sua conta será excluída permanentemente."
        }
    }

    // MARK: - Firebase

    func entrar(email: String, senha: String) async {
        carregando = true
        erro = nil
        limparSessaoLocal()
        do {
            try await Auth.auth().signIn(withEmail: email, password: senha)
            await carregarPapelUsuario()
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func cadastrar(nome: String, email: String, senha: String, papel: PapelUsuario) async {
        carregando = true
        erro = nil
        limparSessaoLocal()
        do {
            let resultado = try await Auth.auth().createUser(withEmail: email, password: senha)
            let changeRequest = resultado.user.createProfileChangeRequest()
            changeRequest.displayName = nome
            try await changeRequest.commitChanges()

            let salvo = await UsuarioService.shared.salvarPerfilNuvem(
                uid: resultado.user.uid,
                nome: nome,
                email: email,
                papel: papel
            )

            switch salvo {
            case .success:
                papelAtual = papel
            case .failure(let usuarioErro):
                try? await resultado.user.delete()
                erro = usuarioErro.localizedDescription
            }
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func entrarComGoogle() async {
        carregando = true
        erro = nil
        limparSessaoLocal()
        do {
            GoogleSignInHelper.configurar()
            try await GoogleSignInHelper.entrar()
        } catch let erroSocial as SocialAuthError {
            if case .cancelado = erroSocial { self.erro = nil } else { erro = erroSocial.localizedDescription }
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func entrarComApple() async {
        carregando = true
        erro = nil
        limparSessaoLocal()
        do {
            try await AppleSignInHelper.shared.entrar()
        } catch let erroSocial as SocialAuthError {
            if case .cancelado = erroSocial { self.erro = nil } else { erro = erroSocial.localizedDescription }
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func redefinirSenhaNuvem(email: String) async {
        carregando = true
        erro = nil
        mensagemSucesso = nil

        let emailLimpo = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard emailLimpo.contains("@") else {
            erro = "E-mail inválido."
            carregando = false
            return
        }

        do {
            try await Auth.auth().sendPasswordReset(withEmail: emailLimpo)
            mensagemSucesso = "Enviamos um link de redefinição para \(emailLimpo). Verifique sua caixa de entrada."
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func redefinirSenhaLocal(email: String, novaSenha: String) {
        carregando = true
        erro = nil
        mensagemSucesso = nil

        switch LocalAuthStore.shared.redefinirSenha(email: email, novaSenha: novaSenha) {
        case .success:
            mensagemSucesso = "Senha redefinida com sucesso. Faça login com a nova senha."
        case .failure(let erro):
            self.erro = erro.localizedDescription
        }
        carregando = false
    }

    func limparMensagens() {
        erro = nil
        mensagemSucesso = nil
    }

    // MARK: - Local

    func entrarLocal(email: String, senha: String) {
        carregando = true
        erro = nil
        try? Auth.auth().signOut()

        if let conta = LocalAuthStore.shared.entrar(email: email, senha: senha) {
            usuarioLocal = conta
            usandoLoginLocal = true
            papelAtual = conta.papel
            LancamentoService.shared.carregarLocal()
            AvaliacaoService.shared.carregarLocal()
            TransacaoLogService.shared.carregarLocal()
            ModeloFotoService.shared.carregarLocal()
            sincronizarPerfil()
        } else {
            erro = "E-mail ou senha incorretos."
        }
        carregando = false
    }

    func cadastrarLocal(nome: String, email: String, senha: String, papel: PapelUsuario) {
        carregando = true
        erro = nil
        try? Auth.auth().signOut()

        switch LocalAuthStore.shared.registrar(nome: nome, email: email, senha: senha, papel: papel) {
        case .success(let conta):
            usuarioLocal = conta
            usandoLoginLocal = true
            papelAtual = conta.papel
            LancamentoService.shared.carregarLocal()
            AvaliacaoService.shared.carregarLocal()
            TransacaoLogService.shared.carregarLocal()
            ModeloFotoService.shared.carregarLocal()
            sincronizarPerfil()
        case .failure(let erro):
            self.erro = erro.localizedDescription
        }
        carregando = false
    }

    func sair() {
        if usandoLoginLocal {
            LocalAuthStore.shared.sair()
            limparSessaoLocal()
            LancamentoService.shared.pararListener()
            AvaliacaoService.shared.pararListener()
            TransacaoLogService.shared.pararListener()
            sincronizarPerfil()
        } else {
            FirebaseSyncCoordinator.shared.pararSincronizacao()
            try? Auth.auth().signOut()
        }
    }

    func excluirConta(senha: String? = nil) async {
        carregando = true
        erro = nil

        if usandoLoginLocal {
            guard let senha, !senha.isEmpty else {
                erro = AuthDeleteError.senhaObrigatoria.localizedDescription
                carregando = false
                return
            }
            if LocalAuthStore.shared.excluirContaAtual(senha: senha) {
                limparSessaoLocal()
            } else {
                erro = "Senha incorreta."
            }
            carregando = false
            return
        }

        guard let user = Auth.auth().currentUser else {
            carregando = false
            return
        }

        let uid = user.uid

        do {
            try await reautenticar(user: user, senha: senha)
            FirebaseSyncCoordinator.shared.pararSincronizacao()
            await UsuarioService.shared.removerPerfilNuvem(uid: uid)
            try await user.delete()
        } catch let erroSocial as SocialAuthError {
            if case .cancelado = erroSocial { self.erro = nil } else { erro = erroSocial.localizedDescription }
        } catch {
            erro = traduzErroExclusao(error)
        }
        carregando = false
    }

    private func reautenticar(user: User, senha: String?) async throws {
        let provedores = user.providerData.map(\.providerID)

        if provedores.contains("password") {
            guard let email = user.email, let senha, !senha.isEmpty else {
                throw AuthDeleteError.senhaObrigatoria
            }
            let credencial = EmailAuthProvider.credential(withEmail: email, password: senha)
            try await user.reauthenticate(with: credencial)
            return
        }

        if provedores.contains("google.com") {
            GoogleSignInHelper.configurar()
            let credencial = try await GoogleSignInHelper.obterCredencial()
            try await user.reauthenticate(with: credencial)
            return
        }

        #if os(iOS)
        if provedores.contains("apple.com") {
            let credencial = try await AppleSignInHelper.shared.obterCredencial()
            try await user.reauthenticate(with: credencial)
            return
        }
        #endif

        throw AuthDeleteError.metodoNaoSuportado
    }

    private func traduzErroExclusao(_ error: Error) -> String {
        if let erroExclusao = error as? AuthDeleteError {
            return erroExclusao.localizedDescription
        }
        let codigo = (error as NSError).code
        if AuthErrorCode(rawValue: codigo) == .requiresRecentLogin {
            return exigeSenhaParaExcluir
                ? "Confirme sua senha para excluir a conta."
                : "Confirme sua identidade novamente para excluir a conta."
        }
        return traduzErro(error)
    }

    private func limparSessaoLocal() {
        LocalAuthStore.shared.sair()
        usuarioLocal = nil
        usandoLoginLocal = false
        papelAtual = nil
    }

    private func carregarPapelUsuario() async {
        if usandoLoginLocal {
            papelAtual = usuarioLocal?.papel
            return
        }
        guard let uid = usuario?.uid else {
            papelAtual = nil
            return
        }
        papelAtual = await UsuarioService.shared.carregarPapelNuvem(uid: uid) ?? .consultorVendas
    }

    private func sincronizarPerfil() {
        PerfilService.shared.carregarParaUsuario(uid: uid)
    }

    private func traduzErro(_ error: Error) -> String {
        let nsErro = error as NSError
        let codigo = nsErro.code

        if nsErro.domain == AuthErrorDomain,
           AuthErrorCode(rawValue: codigo) == .keychainError {
            return mensagemErroKeychain()
        }

        if nsErro.localizedDescription.lowercased().contains("keychain") {
            return mensagemErroKeychain()
        }

        switch AuthErrorCode(rawValue: codigo) {
        case .invalidEmail: return "E-mail inválido."
        case .emailAlreadyInUse: return "Esse e-mail já está cadastrado."
        case .weakPassword: return "Senha muito fraca (mínimo 6 caracteres)."
        case .wrongPassword, .invalidCredential: return "E-mail ou senha incorretos."
        case .userNotFound: return "Usuário não encontrado."
        case .operationNotAllowed:
            return "Login por e-mail desativado no Firebase. Ative em Authentication → Sign-in method → E-mail/Senha."
        case .accountExistsWithDifferentCredential:
            return "Já existe uma conta com este e-mail usando outro método de login."
        default: return "Erro: \(error.localizedDescription)"
        }
    }

    private func mensagemErroKeychain() -> String {
        #if os(macOS)
        return """
        Erro ao acessar o Keychain do Mac. Tente:
        1. Feche o iStock completamente
        2. Abra Acesso às Chaves e remova entradas antigas do iStock
        3. Reinstale o app e tente login novamente
        """
        #else
        return "Erro ao acessar o Keychain. Reinstale o app ou faça login novamente."
        #endif
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
}
