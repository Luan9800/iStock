//
//  UsuarioLocal.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

struct ContaLocal: Codable, Identifiable, Equatable {
    let id: String
    var nome: String
    var email: String
    let salt: String
    var senhaHash: String
}
