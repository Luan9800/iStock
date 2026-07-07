//
//  NotificacaoPainel.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import SwiftUI

enum TipoNotificacaoPainel: String, Codable {
    case emAvaliacao = "Em avaliação"
    case avaliado = "Avaliado"
    case sugestao = "Sugestão"
    case relatorio = "Relatório"

    var icone: String {
        switch self {
        case .emAvaliacao: return "clock.badge.checkmark"
        case .avaliado: return "chart.line.uptrend.xyaxis"
        case .sugestao: return "lightbulb.fill"
        case .relatorio: return "doc.richtext"
        }
    }

    var cor: Color {
        switch self {
        case .emAvaliacao: return .orange
        case .avaliado: return AppTheme.azulClaro
        case .sugestao: return .yellow
        case .relatorio: return .mint
        }
    }
}

struct NotificacaoPainel: Identifiable, Codable, Hashable {
    var id: String
    var tipo: TipoNotificacaoPainel
    var titulo: String
    var mensagem: String
    var referenciaId: String?
    var data: Date
    var lida: Bool = false
}

struct SugestaoPainel: Identifiable, Hashable {
    let id: String
    let titulo: String
    let mensagem: String
    let prioridade: PrioridadeSugestao

    enum PrioridadeSugestao: Int, Comparable {
        case baixa = 0
        case media = 1
        case alta = 2

        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        var cor: Color {
            switch self {
            case .baixa: return AppTheme.azulClaro
            case .media: return .orange
            case .alta: return .red
            }
        }
    }
}

struct RelatorioFinanceiro {
    let periodoInicio: Date
    let periodoFim: Date
    let receitaTotal: Double
    let despesasTotal: Double
    let lucroLiquido: Double
    let itensEstoque: Int
    let valorEstoque: Double
    let custoEstoque: Double
    let vendasQuantidade: Int
    let produtosParados: Int
    let avaliacoesPendentes: Int
    let avaliacoesAvaliadas: Int
    let pagamentosPendentes: Double
    let margemMediaPercentual: Double?
    let sugestoes: [SugestaoPainel]
    let estoquePorCategoria: [(tipo: TipoProduto, quantidade: Int, valor: Double)]
    let panorama: PanoramaRelatorio
    let comprasRecusadas: Int
    let recusasNoPeriodo: [RecusaCompraRegistro]
    let avaliacoesValores: [AvaliacaoValorResumo]
}

struct RecusaCompraRegistro: Identifiable, Hashable {
    let id: String
    let titulo: String
    let justificativa: String
    let data: Date
    let valorEstimado: Double?
}

struct AvaliacaoValorResumo: Identifiable, Hashable {
    let id: String
    let titulo: String
    let estimativa: Double
    let compra: Double
    let vendaReal: Double?
}

struct PanoramaRelatorio {
    let disponiveis: Int
    let reservados: Int
    let vendidosMes: Int
    let receitaMes: Double
    let receitaHistorica: Double
    let comprasAprovadas: Double
    let pagamentosAprovados: Double
    let pagamentosPendentesQuantidade: Int
    let avaliacoesAprovadas: Int
    let avaliacoesNoEstoque: Int
    let estimativaAvaliadas: Double
    let compraAvaliadas: Double
    let vendaRealAvaliadas: Double
    let margemPotencialEstoque: Double
    let comprasRecusadasTotal: Int
}

struct RelatorioArquivo: Identifiable, Hashable {
    let id: String
    let url: URL
    let dataGeracao: Date
    let periodoFim: Date
}
