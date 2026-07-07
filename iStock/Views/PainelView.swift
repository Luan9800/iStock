//
//  PainelView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct PainelView: View {
    @ObservedObject private var service = LancamentoService.shared
    @ObservedObject private var avaliacoes = AvaliacaoService.shared

    private let colunas = [GridItem(.adaptive(minimum: 160), spacing: 14)]

    var body: some View {
        LayoutTelaView(titulo: "Painel", subtitulo: "Visão geral do inventário Apple") {
            VStack(alignment: .leading, spacing: 20) {
                CartaoVidroView {
                    SecaoNotificacoesPainelView()
                }

                SecaoAtividadeRecenteView()

                Text("Financeiro")
                    .font(.headline)
                    .foregroundStyle(.white)

                LazyVGrid(columns: colunas, spacing: 14) {
                        cartaoMetrica(
                            titulo: "Receita em estoque",
                            valor: Formatters.brl(service.valorTotalEstoque),
                            icone: "brazilianrealsign.circle.fill",
                            cor: AppTheme.azulClaro
                        )
                        cartaoMetrica(
                            titulo: "Total vendido",
                            valor: Formatters.brl(service.receitaTotalVendida),
                            icone: "bag.fill",
                            cor: .green
                        )
                        cartaoMetrica(
                            titulo: "Compras aprovadas",
                            valor: Formatters.brl(avaliacoes.totalCompradoAprovado),
                            icone: "checkmark.seal.fill",
                            cor: .green
                        )
                        cartaoMetrica(
                            titulo: "Pagamentos pendentes",
                            valor: Formatters.brl(avaliacoes.totalPagamentoPendente),
                            icone: "clock.badge.exclamationmark",
                            cor: .orange
                        )
                        cartaoMetrica(
                            titulo: "Pagamentos aprovados",
                            valor: Formatters.brl(avaliacoes.totalPagamentoAprovado),
                            icone: "banknote.fill",
                            cor: .mint
                        )
                        cartaoMetrica(
                            titulo: "Custo em estoque",
                            valor: Formatters.brl(service.custoTotalEstoque),
                            icone: "cart.fill",
                            cor: AppTheme.azulClaro
                        )
                    }

                    Text("Inventário")
                        .font(.headline)
                        .foregroundStyle(.white)

                    LazyVGrid(columns: colunas, spacing: 14) {
                        cartaoMetrica(
                            titulo: "Em estoque",
                            valor: "\(service.noEstoque.count)",
                            icone: "shippingbox.fill",
                            cor: AppTheme.azulClaro
                        )
                        cartaoMetrica(
                            titulo: "Disponíveis",
                            valor: "\(service.disponiveis.count)",
                            icone: "checkmark.circle.fill",
                            cor: .green
                        )
                        cartaoMetrica(
                            titulo: "Reservados",
                            valor: "\(service.reservados.count)",
                            icone: "clock.fill",
                            cor: .orange
                        )
                        cartaoMetrica(
                            titulo: "Vendidos no mês",
                            valor: "\(service.vendidosNoMes.count)",
                            icone: "calendar",
                            cor: .green
                        )
                        cartaoMetrica(
                            titulo: "Receita do mês",
                            valor: Formatters.brl(service.receitaMes),
                            icone: "chart.bar.fill",
                            cor: AppTheme.azulClaro
                        )
                        cartaoMetrica(
                            titulo: "Avaliados (estimativa)",
                            valor: Formatters.brl(avaliacoes.totalEstimadoAvaliadas),
                            icone: "chart.line.uptrend.xyaxis",
                            cor: AppTheme.azulClaro
                        )
                        cartaoMetrica(
                            titulo: "Venda real (avaliados)",
                            valor: Formatters.brl(avaliacoes.totalVendaRealAvaliadas),
                            icone: "checkmark.circle.fill",
                            cor: .green
                        )
                    }

                    if !avaliacoes.aprovadasSemPagamento.isEmpty {
                        secaoPagamentosPendentes
                    }

                    CartaoVidroView {
                        SecaoAvaliadosPainelView()
                    }

                    SecaoLogTransacoesView()

                    if !service.paradosNoEstoque.isEmpty {
                        alertaParados
                    }

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Estoque por categoria")
                                .font(.headline)
                                .foregroundStyle(.white)

                            ForEach(TipoProduto.allCases) { tipo in
                                let qtd = service.contagem(por: tipo)
                                if qtd > 0 {
                                    HStack {
                                        Label(tipo.rawValue, systemImage: tipo.sfSymbol)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.85))
                                        Spacer()
                                        Text("\(qtd)")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(AppTheme.azulClaro)
                                    }
                                }
                            }

                            if service.noEstoque.isEmpty {
                                Text("Nenhum produto em estoque.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                        }
                    }

                    if !service.vendidosNoMes.isEmpty {
                        CartaoVidroView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Últimas vendas do mês")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                ForEach(service.vendidosNoMes.prefix(5)) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.tituloExibicao)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.white)
                                            if let cliente = item.clienteVendaNome {
                                                Text(cliente)
                                                    .font(.caption)
                                                    .foregroundStyle(.white.opacity(0.45))
                                            }
                                        }
                                        Spacer()
                                        Text(Formatters.brl(item.valor))
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }

    private var secaoPagamentosPendentes: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Pagamentos aguardando aprovação")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(avaliacoes.aprovadasSemPagamento.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2), in: Capsule())
                }

                ForEach(avaliacoes.aprovadasSemPagamento.prefix(5)) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.tituloExibicao)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                            if let data = item.dataAprovacao {
                                Text("Aprovado em \(Formatters.dataCurta.string(from: data))")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                        }
                        Spacer()
                        Text(Formatters.brl(item.valorCompra))
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }

    private func cartaoMetrica(titulo: String, valor: String, icone: String, cor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icone)
                .font(.title2)
                .foregroundStyle(cor)
            Text(valor)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }

    private var alertaParados: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            Text("\(service.paradosNoEstoque.count) produto(s) há mais de \(Lancamento.diasLimiteEstoque) dias parados")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.red.opacity(0.35), lineWidth: 1)
        }
    }
}

#Preview {
    PainelView()
}
