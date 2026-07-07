//
//  PasswordHasher.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import CryptoKit
import Foundation

enum PasswordHasher {
    static func gerarSalt() -> String {
        UUID().uuidString
    }

    static func hash(senha: String, salt: String) -> String {
        let data = Data((salt + senha).utf8)
        return SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    static func verificar(senha: String, salt: String, hash armazenado: String) -> Bool {
        hash(senha: senha, salt: salt) == armazenado
    }
}
