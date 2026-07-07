//
//  RelatoriosView.swift
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

struct RelatoriosView: View {
    @ObservedObject private var relatorios = RelatorioMensalService.shared
    @State private var gerando = false
    @State private var mostrandoCompartilhar = false
    @State private var urlCompartilhar: URL?

    private let colunas = [GridItem(.adaptive(minimum: 200), spacing: 14)]

    var body: some View {
        LayoutTelaView(
            titulo: "Relatórios",
            subtitulo: "Financeiro e estoque · próximo automático em \(relatorios.diasAteProximoRelatorio) dia(s)",
            trailing: {
                Button {
                    gerarPDF()
                } label: {
                    Label(gerando ? "Gerando..." : "Gerar PDF", systemImage: "doc.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.gradienteBotao, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(gerando)
            }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                if let relatorio = relatorios.relatorioAtual {
                    resumoFinanceiro(relatorio)
                    sugestoes(relatorio)
                    estoquePorCategoria(relatorio)
                }

                secaoPDFs

                if let erro = relatorios.erro {
                    Text(erro)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                }
            }
        }
        .onAppear {
            relatorios.atualizarRelatorioAtual()
            relatorios.carregarArquivos()
        }
    }

    @ViewBuilder
    private func resumoFinanceiro(_ relatorio: RelatorioFinanceiro) -> some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Período de \(RelatorioAnaliseService.diasPeriodoRelatorio) dias")
                    .font(.headline)
                    .foregroundStyle(.white)

                LazyVGrid(columns: colunas, spacing: 14) {
                    metrica("Receita", Formatters.brl(relatorio.receitaTotal), .green)
                    metrica("Despesas", Formatters.brl(relatorio.despesasTotal), .orange)
                    metrica("Lucro", Formatters.brl(relatorio.lucroLiquido), relatorio.lucroLiquido >= 0 ? .mint : .red)
                    metrica("Valor em estoque", Formatters.brl(relatorio.valorEstoque), AppTheme.azulClaro)
                    metrica("Itens em estoque", "\(relatorio.itensEstoque)", AppTheme.azulClaro)
                    metrica("Vendas", "\(relatorio.vendasQuantidade)", .green)
                }
            }
        }
    }

    @ViewBuilder
    private func sugestoes(_ relatorio: RelatorioFinanceiro) -> some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 12) {
                Label("O que melhorar", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(.white)

                ForEach(relatorio.sugestoes) { sugestao in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(sugestao.prioridade.cor)
                            .frame(width: 8, height: 8)
                            .padding(.top, 5)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sugestao.titulo)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(sugestao.mensagem)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func estoquePorCategoria(_ relatorio: RelatorioFinanceiro) -> some View {
        if !relatorio.estoquePorCategoria.isEmpty {
            CartaoVidroView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Estoque por categoria")
                        .font(.headline)
                        .foregroundStyle(.white)
                    ForEach(relatorio.estoquePorCategoria, id: \.tipo.id) { item in
                        HStack {
                            Label(item.tipo.rawValue, systemImage: item.tipo.sfSymbol)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                            Spacer()
                            Text("\(item.quantidade) · \(Formatters.brl(item.valor))")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.azulClaro)
                        }
                    }
                }
            }
        }
    }

    private var secaoPDFs: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Relatórios PDF gerados")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Um relatório é gerado automaticamente a cada \(RelatorioAnaliseService.diasPeriodoRelatorio) dias.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))

                if relatorios.arquivos.isEmpty {
                    Text("Nenhum PDF ainda. Toque em Gerar PDF para criar o primeiro.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                } else {
                    ForEach(relatorios.arquivos) { arquivo in
                        HStack {
                            Image(systemName: "doc.richtext")
                                .foregroundStyle(.red.opacity(0.8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(arquivo.url.lastPathComponent)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(Formatters.dataCompleta.string(from: arquivo.dataGeracao))
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            Spacer()
                            Button("Abrir") { abrirPDF(arquivo.url) }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.azulClaro)
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func metrica(_ titulo: String, _ valor: String, _ cor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(valor)
                .font(.title3.bold())
                .foregroundStyle(cor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private func gerarPDF() {
        gerando = true
        if let url = relatorios.gerarPDFManual() {
            abrirPDF(url)
        }
        gerando = false
    }

    private func abrirPDF(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}

#Preview {
    RelatoriosView()
}
