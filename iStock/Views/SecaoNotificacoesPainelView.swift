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
                Text("Sugestões")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if notificacoes.possuiSugestoesParaExportar {
                    Button {
                        exportarSugestoes()
                    } label: {
                        Label(exportando ? "Exportando..." : "Exportar", systemImage: "square.and.arrow.up")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.azulClaro)
                    }
                    .buttonStyle(.plain)
                    .disabled(exportando)
                }
                Text(contadorSugestoes)
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.azulClaro)
            }

            if let mensagemExport {
                Label(mensagemExport, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if notificacoes.sugestoes.isEmpty {
                Text("Nenhuma sugestão no momento.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
            } else {
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
    }

    private var contadorSugestoes: String {
        let total = notificacoes.sugestoes.count
        if total > PainelNotificacaoService.limiteExibicao {
            return "\(PainelNotificacaoService.limiteExibicao) de \(total)"
        }
        return "\(total)"
    }

    private func exportarSugestoes() {
        exportando = true
        mensagemExport = nil
        let total = notificacoes.sugestoes.count
        if let url = notificacoes.exportarSugestoesCSV() {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
            mensagemExport = "Sugestões exportadas (\(total))"
        }
        exportando = false
    }
}

struct SecaoAtividadeRecenteView: View {
    @ObservedObject private var service = PainelNotificacaoService.shared
    @State private var exportando = false
    @State private var mensagemExport: String?

    private var total: Int { service.notificacoes.count }
    private var exibeExportar: Bool { service.possuiNotificacoesParaExportar }

    var body: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Atividade recente")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    if exibeExportar {
                        Button {
                            exportarAtividade()
                        } label: {
                            Label(exportando ? "Exportando..." : "Exportar", systemImage: "square.and.arrow.up")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.azulClaro)
                        }
                        .buttonStyle(.plain)
                        .disabled(exportando)
                    }
                    if !service.naoLidas.isEmpty {
                        Text("\(service.naoLidas.count) nova(s)")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2), in: Capsule())
                    }
                    Text(contadorTexto)
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.azulClaro)
                    if !service.notificacoes.isEmpty {
                        Button("Marcar lidas") {
                            service.marcarTodasComoLidas()
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

                if service.notificacoesRecentes.isEmpty {
                    Text("Nenhuma atividade registrada ainda.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                } else {
                    ForEach(service.notificacoesRecentes) { item in
                        Button {
                            service.marcarComoLida(item.id)
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
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var contadorTexto: String {
        if total > PainelNotificacaoService.limiteExibicao {
            return "\(PainelNotificacaoService.limiteExibicao) de \(total)"
        }
        return "\(total)"
    }

    private func exportarAtividade() {
        exportando = true
        mensagemExport = nil
        if let url = service.exportarNotificacoesCSV() {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
            mensagemExport = "Atividade exportada (\(total) registro(s))"
        }
        exportando = false
    }
}
