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
        .onChange(of: modoAuth) { _, _ in limparErros() }
        .onChange(of: senha) { _, _ in erroSenha = "" }
        .onChange(of: confirmarSenha) { _, _ in erroSenha = "" }
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
                auth.cadastrarLocal(nome: nome, email: email, senha: senha)
            } else {
                auth.entrarLocal(email: email, senha: senha)
            }
        } else {
            Task {
                if modoCadastro {
                    await auth.cadastrar(nome: nome, email: email, senha: senha)
                } else {
                    await auth.entrar(email: email, senha: senha)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
