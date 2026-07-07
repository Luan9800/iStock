//
//  ProblemaModelo.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import SwiftUI

enum GravidadeDefeito: String, Codable, Hashable {
    case leve = "Leve"
    case moderado = "Moderado"
    case alto = "Alto"

    var cor: Color {
        switch self {
        case .leve: return .yellow
        case .moderado: return .orange
        case .alto: return .red
        }
    }
}

struct ProblemaModelo: Codable, Hashable, Identifiable {
    var id: String
    var titulo: String
    var descricao: String
    var gravidade: GravidadeDefeito
}
