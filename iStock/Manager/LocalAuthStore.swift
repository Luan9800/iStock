//
//  LocalAuthStore.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum LocalAuthError: LocalizedError {
    case nomeObrigatorio
    case emailInvalido
    case senhaFraca
    case emailEmUso
    case emailNaoEncontrado

    var errorDescription: String? {
        switch self {
        case .nomeObrigatorio: return "Informe o nome."
        case .emailInvalido: return "E-mail inválido."
        case .senhaFraca: return "Senha muito fraca (mínimo 6 caracteres)."
        case .emailEmUso: return "Esse e-mail já está cadastrado localmente."
        case .emailNaoEncontrado: return "Nenhuma conta local encontrada com este e-mail."
        }
    }
}

@MainActor
final class LocalAuthStore {
    static let shared = LocalAuthStore()

    private let contasKey = "istock.contas.locais"
    private let sessaoKey = "istock.sessao.local.id"

    private init() {}

    func contaAtual() -> ContaLocal? {
        guard let id = UserDefaults.standard.string(forKey: sessaoKey) else { return nil }
        return carregarContas().first { $0.id == id }
    }

    func registrar(nome: String, email: String, senha: String) -> Result<ContaLocal, LocalAuthError> {
        let emailNormalizado = email.trimmingCharacters(in: .whitespaces).lowercased()
        let nomeLimpo = nome.trimmingCharacters(in: .whitespaces)

        guard !nomeLimpo.isEmpty else { return .failure(.nomeObrigatorio) }
        guard emailNormalizado.contains("@") else { return .failure(.emailInvalido) }
        guard senha.count >= 6 else { return .failure(.senhaFraca) }

        var contas = carregarContas()
        if contas.contains(where: { $0.email == emailNormalizado }) {
            return .failure(.emailEmUso)
        }

        let salt = PasswordHasher.gerarSalt()
        let conta = ContaLocal(
            id: UUID().uuidString,
            nome: nomeLimpo,
            email: emailNormalizado,
            salt: salt,
            senhaHash: PasswordHasher.hash(senha: senha, salt: salt)
        )
        contas.append(conta)
        salvarContas(contas)
        iniciarSessao(conta)
        return .success(conta)
    }

    func entrar(email: String, senha: String) -> ContaLocal? {
        let emailNormalizado = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard let conta = carregarContas().first(where: { $0.email == emailNormalizado }),
              PasswordHasher.verificar(senha: senha, salt: conta.salt, hash: conta.senhaHash) else {
            return nil
        }
        iniciarSessao(conta)
        return conta
    }

    func sair() {
        UserDefaults.standard.removeObject(forKey: sessaoKey)
    }

    @discardableResult
    func excluirContaAtual(senha: String) -> Bool {
        guard let id = UserDefaults.standard.string(forKey: sessaoKey),
              let conta = carregarContas().first(where: { $0.id == id }),
              PasswordHasher.verificar(senha: senha, salt: conta.salt, hash: conta.senhaHash) else {
            return false
        }

        var contas = carregarContas()
        contas.removeAll { $0.id == id }
        salvarContas(contas)
        sair()
        return true
    }

    func redefinirSenha(email: String, novaSenha: String) -> Result<Void, LocalAuthError> {
        let emailNormalizado = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard emailNormalizado.contains("@") else { return .failure(.emailInvalido) }
        guard novaSenha.count >= 6 else { return .failure(.senhaFraca) }

        var contas = carregarContas()
        guard let indice = contas.firstIndex(where: { $0.email == emailNormalizado }) else {
            return .failure(.emailNaoEncontrado)
        }

        let contaAtual = contas[indice]
        let novoSalt = PasswordHasher.gerarSalt()
        contas[indice] = ContaLocal(
            id: contaAtual.id,
            nome: contaAtual.nome,
            email: contaAtual.email,
            salt: novoSalt,
            senhaHash: PasswordHasher.hash(senha: novaSenha, salt: novoSalt)
        )
        salvarContas(contas)
        return .success(())
    }

    private func iniciarSessao(_ conta: ContaLocal) {
        UserDefaults.standard.set(conta.id, forKey: sessaoKey)
    }

    private func carregarContas() -> [ContaLocal] {
        guard let data = UserDefaults.standard.data(forKey: contasKey),
              let contas = try? JSONDecoder().decode([ContaLocal].self, from: data) else {
            return []
        }
        return contas
    }

    private func salvarContas(_ contas: [ContaLocal]) {
        guard let data = try? JSONEncoder().encode(contas) else { return }
        UserDefaults.standard.set(data, forKey: contasKey)
    }
}
