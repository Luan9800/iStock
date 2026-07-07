//
//  ConfirmarSenhaAdminView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct ConfirmarSenhaAdminView: View {
    let titulo: String
    let mensagem: String
    let acaoConfirmar: (String, String?) -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var senha = ""
    @State private var confirmacao = ""
    @State private var erro = ""

    private var configurandoPrimeiraSenha: Bool {
        !AdminService.shared.possuiSenhaConfigurada
    }

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView {
                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 18) {
                        TituloTelaView(titulo: titulo, subtitulo: mensagem)

                        if configurandoPrimeiraSenha {
                            Text("Primeiro acesso: defina a senha de administrador para proteger exclusões.")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }

                        CampoAppView(icone: "lock.shield", placeholder: "Senha de administrador", texto: $senha, ehSenha: true)

                        if configurandoPrimeiraSenha {
                            CampoAppView(icone: "lock.rotation", placeholder: "Confirmar senha", texto: $confirmacao, ehSenha: true)
                        }

                        if !erro.isEmpty {
                            Text(erro)
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.9))
                        }

                        BotaoPrimarioView(
                            titulo: configurandoPrimeiraSenha ? "Salvar e confirmar" : "Confirmar",
                            desabilitado: senha.isEmpty || (configurandoPrimeiraSenha && confirmacao.isEmpty)
                        ) {
                            let confirm = configurandoPrimeiraSenha ? confirmacao : nil
                            if acaoConfirmar(senha, confirm) {
                                dismiss()
                            } else {
                                erro = AvaliacaoService.shared.erro
                                    ?? (AdminService.shared.possuiSenhaConfigurada
                                        ? AdminError.senhaIncorreta.localizedDescription
                                        : AdminError.confirmacaoDiferente.localizedDescription)
                            }
                        }

                        Button("Cancelar") { dismiss() }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.azulClaro)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}
