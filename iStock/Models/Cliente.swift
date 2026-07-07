//
//  Cliente.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import FirebaseFirestore

struct Cliente: Identifiable, Codable {
    @DocumentID var id: String?
    var nome: String
    var email: String?
    var telefone: String?
    var possuiWhatsApp: Bool = false
    var tiposNotificacao: [TipoProduto]
    var ativo: Bool = true
    var data: Date = .now
    var criadoPor: String?
}
