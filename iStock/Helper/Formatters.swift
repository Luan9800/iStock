//
//  Formatters.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//


import Foundation

enum Formatters {
    static let moeda: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "pt_BR")
        f.currencySymbol = "R$"
        return f
    }()

    static func brl(_ valor: Double) -> String {
        moeda.string(from: NSNumber(value: valor)) ?? "R$ 0,00"
    }

    static let dataCurta: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM/yy"
        return f
    }()

    static let dataCompleta: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM/yyyy HH:mm"
        return f
    }()

    static let dataTransacao: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return f
    }()

    static let arquivoData: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "yyyy-MM-dd-HHmm"
        return f
    }()
}
