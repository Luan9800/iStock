//
//  Lacamento.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Foundation
import FirebaseFirestore

enum TipoProduto: String, Codable, CaseIterable, Identifiable {
    case iphone = "iPhone"
    case mac = "Mac"
    case watch = "Watch"
    case ipad = "iPad"
    case appleWatch = "Apple Watch"
    case macbook = "MacBook"
    case airpods = "AirPods"
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
        case .mouse: return "computermouse.fill"
        case .ipod: return "ipod"
        case .outro: return "shippingbox.fill"
        }
    }
}

struct Lancamento: Identifiable, Codable {
    @DocumentID var id: String?
    var nome: String
    var tipoProduto: TipoProduto
    var serial: String?
    var lacrado: Bool
    var condicaoPercentual: Int?
    var valor: Double
    var data: Date = .now
    var criadoPor: String?
}
