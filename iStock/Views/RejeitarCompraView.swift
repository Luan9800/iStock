//
//  RejeitarCompraView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct RejeitarCompraView: View {
    let avaliacao: Avaliacao
    let onConfirmar: (String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var justificativa = ""
    @State private var erroLocal: String?

    private var valido: Bool {
        !justificativa.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView {
                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 16) {
                        TituloTelaView(
                            titulo: "Não aprovar compra",
                            subtitulo: avaliacao.tituloExibicao
                        )

                        Text("Informe o motivo da recusa. A justificativa será registrada no log de ações e nos relatórios.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))

                        CampoAppView(
                            icone: "text.alignleft",
                            placeholder: "Justificativa (obrigatória)",
                            texto: $justificativa
                        )

                        if let erroLocal {
                            Text(erroLocal)
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.9))
                        }

                        BotaoPrimarioView(titulo: "Confirmar recusa", desabilitado: !valido) {
                            if onConfirmar(justificativa) {
                                dismiss()
                            } else {
                                erroLocal = AvaliacaoService.shared.erro ?? "Não foi possível registrar a recusa."
                            }
                        }

                        Button("Cancelar") { dismiss() }
                            .font(.subheadline)
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
