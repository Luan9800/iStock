//
//  SecaoNotificacoesPainelView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct SecaoNotificacoesPainelView: View {
    @ObservedObject private var notificacoes = PainelNotificacaoService.shared
    @State private var exportando = false
    @State private var mensagemExport: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Notificações e sugestões")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if notificacoes.possuiItensParaExportar {
                    Button {
                        exportarItens()
                    } label: {
                        Label(exportando ? "Exportando..." : "Exportar", systemImage: "square.and.arrow.up")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                    .buttonStyle(.plain)
                    .disabled(exportando)
                }
                if !notificacoes.naoLidas.isEmpty {
                    Text("\(notificacoes.naoLidas.count) nova(s)")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2), in: Capsule())
                }
                if !notificacoes.notificacoes.isEmpty {
                    Button("Marcar lidas") {
                        notificacoes.marcarTodasComoLidas()
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.azulClaro)
                    .buttonStyle(.plain)
                }
            }

            if let mensagemExport {
                Label(mensagemExport, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if !notificacoes.sugestoes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Sugestões")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(contadorSugestoes)
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                    ForEach(notificacoes.sugestoesRecentes) { sugestao in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(sugestao.prioridade.cor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sugestao.titulo)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                Text(sugestao.mensagem)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(sugestao.prioridade.cor.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }

            if notificacoes.notificacoes.isEmpty {
                Text("Nenhuma notificação recente.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Atividade recente")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(contadorNotificacoes)
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                    ForEach(notificacoes.notificacoesRecentes) { item in
                        Button {
                            notificacoes.marcarComoLida(item.id)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: item.tipo.icone)
                                    .foregroundStyle(item.tipo.cor)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.titulo)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.white)
                                    Text(item.mensagem)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .multilineTextAlignment(.leading)
                                    Text(Formatters.dataTransacao.string(from: item.data))
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.35))
                                }
                                Spacer()
                                if !item.lida {
                                    Circle()
                                        .fill(AppTheme.azulClaro)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var contadorSugestoes: String {
        let total = notificacoes.sugestoes.count
        if total > PainelNotificacaoService.limiteExibicao {
            return "\(PainelNotificacaoService.limiteExibicao) de \(total)"
        }
        return "\(total)"
    }

    private var contadorNotificacoes: String {
        let total = notificacoes.notificacoes.count
        if total > PainelNotificacaoService.limiteExibicao {
            return "\(PainelNotificacaoService.limiteExibicao) de \(total)"
        }
        return "\(total)"
    }

    private func exportarItens() {
        exportando = true
        mensagemExport = nil
        let totalNotif = notificacoes.notificacoes.count
        let totalSug = notificacoes.sugestoes.count
        if let url = notificacoes.exportarCSV() {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
            mensagemExport = "Exportado (\(totalNotif) notificação(ões), \(totalSug) sugestão(ões))"
        }
        exportando = false
    }
}
