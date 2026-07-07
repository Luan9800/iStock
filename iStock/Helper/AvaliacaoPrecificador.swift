//
//  AvaliacaoPrecificador.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum AvaliacaoPrecificador {
    struct Resultado {
        let valorVenda: Double
        let valorCompra: Double
        let detalhes: String
    }

    static func estimar(_ avaliacao: Avaliacao) -> Resultado {
        var base = valorBase(para: avaliacao.tipoProduto)
        base *= multiplicadorCapacidade(avaliacao.capacidade)

        if avaliacao.lacrado {
            base *= 1.12
        } else {
            let condicao = Double(avaliacao.condicaoPercentual ?? 85) / 100.0
            base *= (0.55 + condicao * 0.45)
        }

        if let modelo = avaliacao.modelo?.lowercased() {
            if modelo.contains("pro") || modelo.contains("max") || modelo.contains("ultra") {
                base *= 1.18
            } else if modelo.contains("mini") || modelo.contains("se") {
                base *= 0.88
            }
        }

        let venda = (base / 50).rounded() * 50
        let compra = (venda * 0.78 / 50).rounded() * 50

        let detalhes = """
        Base \(avaliacao.tipoProduto.rawValue) · \
        \(avaliacao.lacrado ? "lacrado" : "usado \(avaliacao.condicaoPercentual ?? 0)%") · \
        margem sugerida \(Formatters.brl(venda - compra))
        """

        return Resultado(valorVenda: max(venda, 100), valorCompra: max(compra, 50), detalhes: detalhes)
    }

    private static func valorBase(para tipo: TipoProduto) -> Double {
        switch tipo {
        case .iphone: return 3_800
        case .ipad: return 2_600
        case .macbook: return 6_200
        case .mac: return 4_800
        case .appleWatch, .watch: return 1_900
        case .airpods: return 950
        case .appleTV: return 1_350
        case .mouse: return 420
        case .ipod: return 650
        case .outro: return 900
        }
    }

    private static func multiplicadorCapacidade(_ capacidade: String?) -> Double {
        guard let capacidade else { return 1.0 }
        let texto = capacidade.lowercased()
        if texto.contains("2tb") || texto.contains("2 tb") { return 1.55 }
        if texto.contains("1tb") || texto.contains("1 tb") { return 1.35 }
        if texto.contains("512") { return 1.2 }
        if texto.contains("256") { return 1.08 }
        if texto.contains("128") { return 1.0 }
        if texto.contains("64") { return 0.92 }
        if texto.contains("32") { return 0.85 }
        return 1.0
    }
}
