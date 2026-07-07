//
//  Lacamento.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Foundation
import FirebaseFirestore
import SwiftUI

enum TipoProduto: String, Codable, CaseIterable, Identifiable {
    case iphone = "iPhone"
    case mac = "Mac"
    case watch = "Watch"
    case ipad = "iPad"
    case appleWatch = "Apple Watch"
    case macbook = "MacBook"
    case airpods = "AirPods"
    case appleTV = "Apple TV"
    case mouse = "Magic Mouse"
    case ipod = "iPod"
    case outro = "Outro"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .iphone: return "iphone"
        case .mac: return "desktopcomputer"
        case .watch: return "applewatch"
        case .ipad: return "ipad"
        case .appleWatch: return "applewatch"
        case .macbook: return "laptopcomputer"
        case .airpods: return "airpodspro"
        case .appleTV: return "appletv.fill"
        case .mouse: return "computermouse.fill"
        case .ipod: return "ipod"
        case .outro: return "shippingbox.fill"
        }
    }

    var suportaBateria: Bool {
        switch self {
        case .iphone, .ipad, .macbook, .watch, .appleWatch, .ipod: return true
        default: return false
        }
    }

    var suportaCapacidade: Bool {
        switch self {
        case .iphone, .ipad, .mac, .macbook, .ipod, .appleTV: return true
        default: return false
        }
    }
}

enum StatusProduto: String, Codable, CaseIterable, Identifiable {
    case disponivel = "Disponível"
    case reservado = "Reservado"
    case vendido = "Vendido"

    var id: String { rawValue }

    var cor: Color {
        switch self {
        case .disponivel: return AppTheme.azulClaro
        case .reservado: return .orange
        case .vendido: return .green
        }
    }

    var icone: String {
        switch self {
        case .disponivel: return "checkmark.circle"
        case .reservado: return "clock"
        case .vendido: return "bag.fill"
        }
    }
}

enum OrdenacaoProduto: String, CaseIterable, Identifiable {
    case dataRecente = "Mais recentes"
    case dataAntiga = "Mais antigos"
    case precoMaior = "Maior preço"
    case precoMenor = "Menor preço"
    case nome = "Nome A–Z"

    var id: String { rawValue }
}

struct Lancamento: Identifiable, Codable {
    @DocumentID var id: String?
    var nome: String
    var tipoProduto: TipoProduto
    var modelo: String?
    var capacidade: String?
    var cor: String?
    var telefone: String?
    var serial: String?
    var lacrado: Bool
    var condicaoPercentual: Int?
    var custoCompra: Double?
    var valor: Double
    var status: StatusProduto = .disponivel
    var data: Date = .now
    var criadoPor: String?
    var clienteVendaId: String?
    var clienteVendaNome: String?
    var dataVenda: Date?
    var observacoes: String?
    var problemasModelo: [ProblemaModelo]?

    static let diasLimiteEstoque = 30

    var diasNoEstoque: Int {
        max(0, Calendar.current.dateComponents([.day], from: data, to: .now).day ?? 0)
    }

    var estaHaMuitoTempoNoEstoque: Bool {
        status != .vendido && diasNoEstoque >= Self.diasLimiteEstoque
    }

    var estaNoEstoque: Bool {
        status == .disponivel || status == .reservado
    }

    var tituloExibicao: String {
        if let modelo, !modelo.isEmpty { return modelo }
        return nome
    }

    var descricaoCompleta: String {
        [modelo, capacidade, cor].compactMap { $0?.isEmpty == false ? $0 : nil }.joined(separator: " · ")
    }

    var margem: Double? {
        guard let custo = custoCompra, custo > 0 else { return nil }
        return valor - custo
    }

    var margemPercentual: Double? {
        guard let custo = custoCompra, custo > 0 else { return nil }
        return ((valor - custo) / custo) * 100
    }
}
