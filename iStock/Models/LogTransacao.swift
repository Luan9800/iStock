//
//  LogTransacao.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

enum TipoTransacao: String, Codable, CaseIterable, Identifiable {
    case avaliacaoCriada = "Avaliação criada"
    case avaliacaoConcluida = "Avaliação concluída"
    case compraAprovada = "Compra aprovada"
    case compraRecusada = "Compra não aprovada"
    case retiradaRegistrada = "Retirada registrada"
    case pagamentoAprovado = "Pagamento aprovado"
    case valorVendaAtualizado = "Valor de venda atualizado"
    case adicionadoEstoque = "Adicionado ao estoque"
    case avaliacaoExcluida = "Avaliação excluída"
    case vendaProduto = "Produto vendido"

    var id: String { rawValue }

    var icone: String {
        switch self {
        case .avaliacaoCriada: return "plus.circle"
        case .avaliacaoConcluida: return "chart.line.uptrend.xyaxis"
        case .compraAprovada: return "checkmark.seal"
        case .compraRecusada: return "xmark.seal"
        case .retiradaRegistrada: return "hand.raised.fill"
        case .pagamentoAprovado: return "banknote"
        case .valorVendaAtualizado: return "pencil.circle"
        case .adicionadoEstoque: return "shippingbox"
        case .avaliacaoExcluida: return "trash"
        case .vendaProduto: return "bag"
        }
    }

    var cor: Color {
        switch self {
        case .avaliacaoExcluida, .compraRecusada: return .red
        case .pagamentoAprovado, .vendaProduto, .adicionadoEstoque, .retiradaRegistrada: return .green
        case .valorVendaAtualizado: return .orange
        default: return AppTheme.azulClaro
        }
    }
}

struct LogTransacao: Identifiable, Codable {
    @DocumentID var id: String?
    var tipo: TipoTransacao
    var titulo: String
    var detalhes: String?
    var valor: Double?
    var valorAnterior: Double?
    var referenciaId: String?
    var usuario: String?
    var data: Date = .now
}
