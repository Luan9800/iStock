//
//  Avaliacao.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

enum StatusAvaliacao: String, Codable, CaseIterable, Identifiable {
    case emAvaliacao = "Em avaliação"
    case avaliado = "Avaliado"
    case aprovado = "Aprovado"
    case noEstoque = "No estoque"

    var id: String { rawValue }

    var cor: Color {
        switch self {
        case .emAvaliacao: return .orange
        case .avaliado: return AppTheme.azulClaro
        case .aprovado: return .green
        case .noEstoque: return .mint
        }
    }

    var icone: String {
        switch self {
        case .emAvaliacao: return "clock.badge.checkmark"
        case .avaliado: return "chart.line.uptrend.xyaxis"
        case .aprovado: return "checkmark.seal.fill"
        case .noEstoque: return "shippingbox.fill"
        }
    }
}

struct FotoAvaliacao: Codable, Identifiable, Hashable {
    var id: String
    var url: String
    var path: String?

    init(id: String = UUID().uuidString, url: String, path: String? = nil) {
        self.id = id
        self.url = url
        self.path = path
    }
}

struct Avaliacao: Identifiable, Codable {
    @DocumentID var id: String?
    var tipoProduto: TipoProduto
    var nome: String
    var modelo: String?
    var capacidade: String?
    var cor: String?
    var telefone: String?
    var serial: String?
    var lacrado: Bool
    var condicaoPercentual: Int?
    var observacoes: String?
    var fotos: [FotoAvaliacao]
    var status: StatusAvaliacao = .emAvaliacao
    var valorEstimado: Double?
    var valorCompraSugerido: Double?
    var valorVendaReal: Double?
    var pagamentoAprovado: Bool = false
    var data: Date = .now
    var dataAvaliacao: Date?
    var dataVendaReal: Date?
    var dataAprovacao: Date?
    var dataPagamento: Date?
    var criadoPor: String?
    var lancamentoId: String?
    var problemasModelo: [ProblemaModelo]?

    var tituloExibicao: String {
        if let modelo, !modelo.isEmpty { return modelo }
        return nome
    }

    var descricaoCompleta: String {
        [modelo, capacidade, cor].compactMap { $0?.isEmpty == false ? $0 : nil }.joined(separator: " · ")
    }

    var valorCompra: Double {
        valorCompraSugerido ?? 0
    }

    var valorVendaExibicao: Double {
        valorVendaReal ?? valorEstimado ?? 0
    }

    var possuiVendaReal: Bool {
        valorVendaReal != nil
    }

    var situacaoPagamento: String? {
        guard status == .aprovado else { return nil }
        return pagamentoAprovado ? "Pagamento aprovado" : "Pagamento pendente"
    }

    func paraLancamento(valorVenda: Double? = nil, custo: Double? = nil) -> Lancamento {
        Lancamento(
            nome: nome,
            tipoProduto: tipoProduto,
            modelo: modelo,
            capacidade: capacidade,
            cor: cor,
            telefone: telefone,
            serial: serial,
            lacrado: lacrado,
            condicaoPercentual: condicaoPercentual,
            custoCompra: custo ?? valorCompraSugerido,
            valor: valorVenda ?? valorVendaReal ?? valorEstimado ?? 0,
            status: .disponivel,
            criadoPor: criadoPor,
            observacoes: observacoes,
            problemasModelo: problemasModelo
        )
    }
}
