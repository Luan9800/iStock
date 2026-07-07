//
//  PapelUsuario.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

enum PapelUsuario: String, Codable, CaseIterable, Identifiable {
    case administrador = "Administrador"
    case consultorVendas = "Consultor de vendas"
    case cliente = "Cliente"

    var id: String { rawValue }

    var rotuloExibicao: String {
        switch self {
        case .administrador: return "Administrador"
        case .consultorVendas: return "Consultor"
        case .cliente: return "Cliente"
        }
    }

    var icone: String {
        switch self {
        case .administrador: return "person.badge.key.fill"
        case .consultorVendas: return "person.crop.circle.badge.checkmark"
        case .cliente: return "person.fill"
        }
    }

    var cor: Color {
        switch self {
        case .administrador: return .mint
        case .consultorVendas: return AppTheme.azulClaro
        case .cliente: return .orange
        }
    }

    var descricaoCadastro: String {
        switch self {
        case .administrador:
            return "Acesso total ao sistema (máx. 4 contas)."
        case .consultorVendas:
            return "Vendas, estoque, avaliações e clientes."
        case .cliente:
            return "Avaliações e mensagens com a loja."
        }
    }
}

struct UsuarioApp: Identifiable, Codable {
    @DocumentID var id: String?
    var nome: String
    var email: String
    var papel: PapelUsuario
    var dataCadastro: Date = .now
}
