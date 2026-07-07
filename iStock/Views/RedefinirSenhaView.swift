//
//  RedefinirSenhaView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct RedefinirSenhaView: View {
    let modoAuth: ModoAutenticacao

    @ObservedObject private var auth = AuthService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var novaSenha = ""
    @State private var confirmarSenha = ""
    @State private var erroSenha = ""

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    TituloTelaView(
                        titulo: "Redefinir senha",
                        subtitulo: modoAuth == .nuvem
                            ? "Enviaremos um link para o seu e-mail"
                            : "Defina uma nova senha para sua conta local"
                    )

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 16) {
                            CampoAppView(icone: "envelope.fill", placeholder: "E-mail", texto: $email)

                            if modoAuth == .local {
                                CampoAppView(icone: "lock.fill", placeholder: "Nova senha", texto: $novaSenha, ehSenha: true)
                                CampoAppView(
                                    icone: "lock.rotation",
                                    placeholder: "Confirmar nova senha",
                                    texto: $confirmarSenha,
                                    ehSenha: true
                                )
                            }

                            if !erroSenha.isEmpty {
                                Label(erroSenha, systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }

                            if let erro = auth.erro {
                                Label(erro, systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                            }

                            if let sucesso = auth.mensagemSucesso {
                                Label(sucesso, systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.azulClaro)
                            }

                            BotaoPrimarioView(
                                titulo: modoAuth == .nuvem ? "Enviar link" : "Redefinir senha",
                                desabilitado: botaoDesabilitado || auth.carregando
                            ) {
                                redefinir()
                            }

                            if auth.carregando {
                                ProgressView()
                                    .tint(AppTheme.azulClaro)
                                    .frame(maxWidth: .infinity)
                            }

                            Button("Cancelar") { dismiss() }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.azulClaro)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear { auth.limparMensagens() }
        .onChange(of: auth.mensagemSucesso) { _, mensagem in
            if mensagem != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
            }
        }
    }

    private var botaoDesabilitado: Bool {
        let emailVazio = email.trimmingCharacters(in: .whitespaces).isEmpty
        if modoAuth == .local {
            return emailVazio || novaSenha.isEmpty || confirmarSenha.isEmpty
        }
        return emailVazio
    }

    private func redefinir() {
        erroSenha = ""
        auth.limparMensagens()

        if modoAuth == .local {
            if novaSenha != confirmarSenha {
                erroSenha = "As senhas não coincidem."
                return
            }
            auth.redefinirSenhaLocal(email: email, novaSenha: novaSenha)
        } else {
            Task { await auth.redefinirSenhaNuvem(email: email) }
        }
    }
}

#Preview {
    RedefinirSenhaView(modoAuth: .nuvem)
}
