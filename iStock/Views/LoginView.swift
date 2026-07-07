//
//  LoginView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

enum ModoAutenticacao: String, CaseIterable, Identifiable {
    case nuvem = "Nuvem"
    case local = "Local"

    var id: String { rawValue }
}

struct LoginView: View {
    @ObservedObject private var auth = AuthService.shared

    @State private var modoAuth: ModoAutenticacao = .nuvem
    @State private var modoCadastro = false
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var confirmarSenha = ""
    @State private var erroSenha = ""
    @State private var mostrandoRedefinirSenha = false
    @State private var papelSelecionado: PapelUsuario = .consultorVendas
    @State private var adminDisponivel = true

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    cabecalho
                    cartaoLogin
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: modoAuth) { _, _ in
            limparErros()
            if modoCadastro { Task { await atualizarDisponibilidadeAdmin() } }
        }
        .onChange(of: senha) { _, _ in erroSenha = "" }
        .onChange(of: confirmarSenha) { _, _ in erroSenha = "" }
        .onChange(of: modoCadastro) { _, cadastro in
            if cadastro { Task { await atualizarDisponibilidadeAdmin() } }
        }
        .sheet(isPresented: $mostrandoRedefinirSenha) {
            RedefinirSenhaView(modoAuth: modoAuth)
        }
    }

    private var cabecalho: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.azulPrimario.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 8)

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: AppTheme.azulPrimario.opacity(0.6), radius: 20, y: 8)
            }

            VStack(spacing: 6) {
                Text("iStock")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Gestão inteligente de inventário")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.top, 12)
    }

    private var cartaoLogin: some View {
        CartaoVidroView {
            VStack(spacing: 20) {
                SeletorModoAuthView(selecao: $modoAuth)

                Text(subtitulo)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if modoAuth == .nuvem && !modoCadastro {
                    SocialLoginCardsView(
                        onGoogle: { Task { await auth.entrarComGoogle() } },
                        onApple: { Task { await auth.entrarComApple() } }
                    )
                    .disabled(auth.carregando)

                    DivisorLoginView()
                }

                VStack(spacing: 12) {
                    if modoCadastro {
                        CampoLoginView(icone: "person.fill", placeholder: "Nome", texto: $nome)
                    }

                    CampoLoginView(icone: "envelope.fill", placeholder: "E-mail", texto: $email)
                    CampoLoginView(icone: "lock.fill", placeholder: "Senha", texto: $senha, ehSenha: true)

                    if !modoCadastro {
                        HStack {
                            Spacer()
                            Button("Esqueci minha senha") {
                                auth.limparMensagens()
                                mostrandoRedefinirSenha = true
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.azulClaro)
                            .buttonStyle(.plain)
                        }
                    }

                    if modoCadastro {
                        CampoLoginView(
                            icone: "lock.rotation",
                            placeholder: "Confirmar senha",
                            texto: $confirmarSenha,
                            ehSenha: true
                        )

                        seletorPapel
                    }
                }

                mensagensErro

                BotaoPrimarioView(
                    titulo: modoCadastro ? "Criar conta" : "Entrar",
                    desabilitado: camposInvalidos || auth.carregando
                ) {
                    autenticar()
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        modoCadastro.toggle()
                        limparErros()
                        confirmarSenha = ""
                    }
                } label: {
                    Text(modoCadastro ? "Já tenho conta" : "Criar nova conta")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.azulClaro)
                }
                .buttonStyle(.plain)

                if auth.carregando {
                    ProgressView()
                        .tint(AppTheme.azulClaro)
                }
            }
        }
    }

    private var seletorPapel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Perfil de acesso")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))

            ForEach(PapelUsuario.allCases) { papel in
                let desabilitado = papel == .administrador && !adminDisponivel
                Button {
                    guard !desabilitado else { return }
                    papelSelecionado = papel
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: papel.icone)
                            .font(.body)
                            .foregroundStyle(papelSelecionado == papel ? papel.cor : .white.opacity(0.45))
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(papel.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(desabilitado ? .white.opacity(0.35) : .white)
                            Text(papel.descricaoCadastro)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(desabilitado ? 0.25 : 0.45))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        if papelSelecionado == papel {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(papel.cor)
                        }
                    }
                    .padding(12)
                    .background(
                        papelSelecionado == papel
                            ? papel.cor.opacity(0.12)
                            : Color.white.opacity(0.05),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                papelSelecionado == papel ? papel.cor.opacity(0.45) : Color.clear,
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(desabilitado)
            }

            if !adminDisponivel {
                Text("Limite de 4 administradores atingido.")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }

    @ViewBuilder
    private var mensagensErro: some View {
        if !erroSenha.isEmpty {
            Label(erroSenha, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(Color.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        if let erro = auth.erro {
            Label(erro, systemImage: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color.red.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var subtitulo: String {
        if modoAuth == .local {
            return modoCadastro
                ? "Conta local neste dispositivo — sem sincronização na nuvem"
                : "Acesso offline — dados não sincronizam com Firebase"
        }
        return modoCadastro ? "Cadastre-se para sincronizar na nuvem" : "Acesse sua conta na nuvem"
    }

    private var camposInvalidos: Bool {
        if modoCadastro && nome.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        if modoCadastro && confirmarSenha.isEmpty { return true }
        if modoCadastro && papelSelecionado == .administrador && !adminDisponivel { return true }
        return email.isEmpty || senha.isEmpty
    }

    private func limparErros() {
        auth.erro = nil
        auth.mensagemSucesso = nil
        erroSenha = ""
    }

    private func autenticar() {
        if modoCadastro && senha != confirmarSenha {
            erroSenha = "As senhas não coincidem."
            return
        }
        limparErros()

        if modoAuth == .local {
            if modoCadastro {
                auth.cadastrarLocal(nome: nome, email: email, senha: senha, papel: papelSelecionado)
            } else {
                auth.entrarLocal(email: email, senha: senha)
            }
        } else {
            Task {
                if modoCadastro {
                    await auth.cadastrar(nome: nome, email: email, senha: senha, papel: papelSelecionado)
                } else {
                    await auth.entrar(email: email, senha: senha)
                }
            }
        }
    }

    private func atualizarDisponibilidadeAdmin() async {
        if modoAuth == .local {
            adminDisponivel = LocalAuthStore.shared.podeRegistrarAdministradorLocal()
        } else {
            adminDisponivel = await UsuarioService.shared.podeRegistrarAdministradorNuvem()
        }
        if !adminDisponivel && papelSelecionado == .administrador {
            papelSelecionado = .consultorVendas
        }
    }
}

#Preview {
    LoginView()
}
