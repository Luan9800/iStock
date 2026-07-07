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
    var papel: PapelUsuario
    let salt: String
    var senhaHash: String

    init(
        id: String,
        nome: String,
        email: String,
        papel: PapelUsuario,
        salt: String,
        senhaHash: String
    ) {
        self.id = id
        self.nome = nome
        self.email = email
        self.papel = papel
        self.salt = salt
        self.senhaHash = senhaHash
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        nome = try container.decode(String.self, forKey: .nome)
        email = try container.decode(String.self, forKey: .email)
        papel = try container.decodeIfPresent(PapelUsuario.self, forKey: .papel) ?? .consultorVendas
        salt = try container.decode(String.self, forKey: .salt)
        senhaHash = try container.decode(String.self, forKey: .senhaHash)
    }
}
