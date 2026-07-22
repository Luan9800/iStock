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

                #if os(macOS)
                CartaoTintadoView(accent: AppTheme.amarelo) {
                    SecaoAtividadeRecenteView()
                }
                #else
                SecaoAtividadeRecenteView()
                #endif

                Text("Financeiro")
                    .font(.headline)
                    .foregroundStyle(.white)

                LazyVGrid(columns: colunas, spacing: 14) {
                    cartaoMetrica(
                        titulo: "Receita em estoque",
                        valor: Formatters.brl(service.valorTotalEstoque),
                        icone: "brazilianrealsign.circle.fill",
                        cor: AppTheme.azulClaro,
                        secao: .financeiro
                    )
                    cartaoMetrica(
                        titulo: "Total vendido",
                        valor: Formatters.brl(service.receitaTotalVendida),
                        icone: "bag.fill",
                        cor: AppTheme.verde,
                        secao: .financeiro
                    )
                    cartaoMetrica(
                        titulo: "Compras aprovadas",
                        valor: Formatters.brl(avaliacoes.totalCompradoAprovado),
                        icone: "checkmark.seal.fill",
                        cor: AppTheme.verde,
                        secao: .financeiro
                    )
                    cartaoMetrica(
                        titulo: "Pagamentos pendentes",
                        valor: Formatters.brl(avaliacoes.totalPagamentoPendente),
                        icone: "clock.badge.exclamationmark",
                        cor: AppTheme.laranja,
                        secao: .financeiro
                    )
                    cartaoMetrica(
                        titulo: "Pagamentos aprovados",
                        valor: Formatters.brl(avaliacoes.totalPagamentoAprovado),
                        icone: "banknote.fill",
                        cor: AppTheme.mint,
                        secao: .financeiro
                    )
                    cartaoMetrica(
                        titulo: "Custo em estoque",
                        valor: Formatters.brl(service.custoTotalEstoque),
                        icone: "cart.fill",
                        cor: AppTheme.azulClaro,
                        secao: .financeiro
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
                        cor: AppTheme.azulClaro,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Disponíveis",
                        valor: "\(service.disponiveis.count)",
                        icone: "checkmark.circle.fill",
                        cor: AppTheme.verde,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Reservados",
                        valor: "\(service.reservados.count)",
                        icone: "clock.fill",
                        cor: AppTheme.laranja,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Vendidos no mês",
                        valor: "\(service.vendidosNoMes.count)",
                        icone: "calendar",
                        cor: AppTheme.verde,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Receita do mês",
                        valor: Formatters.brl(service.receitaMes),
                        icone: "chart.bar.fill",
                        cor: AppTheme.azulClaro,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Avaliados (estimativa)",
                        valor: Formatters.brl(avaliacoes.totalEstimadoAvaliadas),
                        icone: "chart.line.uptrend.xyaxis",
                        cor: AppTheme.azulClaro,
                        secao: .inventario
                    )
                    cartaoMetrica(
                        titulo: "Venda real (avaliados)",
                        valor: Formatters.brl(avaliacoes.totalVendaRealAvaliadas),
                        icone: "checkmark.circle.fill",
                        cor: AppTheme.verde,
                        secao: .inventario
                    )
                }

                if !avaliacoes.aprovadasSemPagamento.isEmpty {
                    secaoPagamentosPendentes
                }

                #if os(macOS)
                CartaoTintadoView(accent: AppTheme.mint) {
                    SecaoAvaliadosPainelView()
                }
                #else
                CartaoVidroView {
                    SecaoAvaliadosPainelView()
                }
                #endif

                SecaoLogTransacoesView()

                if !service.paradosNoEstoque.isEmpty {
                    alertaParados
                }

                #if os(macOS)
                CartaoTintadoView(accent: AppTheme.ciano) {
                    estoquePorCategoria
                }
                #else
                CartaoVidroView {
                    estoquePorCategoria
                }
                #endif

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
                                        .foregroundStyle(AppTheme.verde)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var estoquePorCategoria: some View {
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

    private var secaoPagamentosPendentes: some View {
        Group {
            #if os(macOS)
            CartaoTintadoView(accent: AppTheme.laranja) {
                conteudoPagamentosPendentes
            }
            #else
            CartaoVidroView {
                conteudoPagamentosPendentes
            }
            #endif
        }
    }

    private var conteudoPagamentosPendentes: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pagamentos aguardando aprovação")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(avaliacoes.aprovadasSemPagamento.count)")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.laranja)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.laranja.opacity(0.2), in: Capsule())
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
                        .foregroundStyle(AppTheme.laranja)
                }
            }
        }
    }

    private enum SecaoPainel {
        case financeiro, inventario, padrao

        var accent: Color? {
            #if os(macOS)
            switch self {
            case .financeiro: return AppTheme.verde
            case .inventario: return AppTheme.azulClaro
            case .padrao: return nil
            }
            #else
            return nil
            #endif
        }
    }

    private func cartaoMetrica(
        titulo: String,
        valor: String,
        icone: String,
        cor: Color,
        secao: SecaoPainel = .padrao
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icone)
                .font(.title2)
                .foregroundStyle(cor)
            Text(valor)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fundoMetrica(secao: secao))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(bordaMetrica(secao: secao), lineWidth: 1)
        }
        #if os(macOS)
        .shadow(color: .black.opacity(secao.accent == nil ? 0 : 0.3), radius: 12, x: 0, y: 10)
        .shadow(
            color: (secao.accent ?? .clear).opacity(secao == .inventario ? 0.28 : 0.22),
            radius: 14,
            x: 0,
            y: 12
        )
        #endif
    }

    private func fundoMetrica(secao: SecaoPainel) -> some ShapeStyle {
        #if os(macOS)
        if let accent = secao.accent {
            return AnyShapeStyle(AppTheme.gradienteSecao(accent))
        }
        #endif
        return AnyShapeStyle(Color.white.opacity(0.07))
    }

    private func bordaMetrica(secao: SecaoPainel) -> Color {
        #if os(macOS)
        if let accent = secao.accent {
            return accent.opacity(0.35)
        }
        #endif
        return Color.white.opacity(0.1)
    }

    private var alertaParados: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(AppTheme.vermelho)
            Text("\(service.paradosNoEstoque.count) produto(s) há mais de \(Lancamento.diasLimiteEstoque) dias parados")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.vermelho.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.vermelho.opacity(0.35), lineWidth: 1)
        }
    }
}

#Preview {
    PainelView()
}
