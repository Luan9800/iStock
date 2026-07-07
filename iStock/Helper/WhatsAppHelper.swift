//
//  WhatsAppHelper.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum WhatsAppHelper {
    /// Formata número brasileiro para link wa.me (apenas dígitos, com DDI 55).
    static func numeroFormatado(_ telefone: String) -> String? {
        let numeros = telefone.filter(\.isNumber)
        guard numeros.count >= 10 else { return nil }

        if numeros.hasPrefix("55"), numeros.count >= 12 {
            return numeros
        }
        if numeros.count == 10 || numeros.count == 11 {
            return "55" + numeros
        }
        return numeros
    }

    static func urlMensagem(numero: String, texto: String? = nil) -> URL? {
        guard let formatado = numeroFormatado(numero) else { return nil }
        var urlString = "https://wa.me/\(formatado)"
        if let texto, !texto.isEmpty,
           let encoded = texto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "?text=\(encoded)"
        }
        return URL(string: urlString)
    }
}

extension Cliente {
    var temWhatsApp: Bool {
        possuiWhatsApp && telefone != nil && !(telefone?.isEmpty ?? true)
    }

    var numeroWhatsApp: String? {
        guard temWhatsApp, let telefone else { return nil }
        return WhatsAppHelper.numeroFormatado(telefone)
    }
}
