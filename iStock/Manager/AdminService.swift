//
//  AdminService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum AdminError: LocalizedError {
    case senhaObrigatoria
    case senhaIncorreta
    case confirmacaoDiferente

    var errorDescription: String? {
        switch self {
        case .senhaObrigatoria: return "Informe a senha de administrador."
        case .senhaIncorreta: return "Senha de administrador incorreta."
        case .confirmacaoDiferente: return "As senhas não coincidem."
        }
    }
}

@MainActor
final class AdminService {
    static let shared = AdminService()

    private let saltKey = "istock.admin.salt"
    private let hashKey = "istock.admin.hash"

    private init() {}

    var possuiSenhaConfigurada: Bool {
        UserDefaults.standard.string(forKey: saltKey) != nil
            && UserDefaults.standard.string(forKey: hashKey) != nil
    }

    @discardableResult
    func configurarSenha(_ senha: String, confirmacao: String) -> Result<Void, AdminError> {
        guard !senha.isEmpty else { return .failure(.senhaObrigatoria) }
        guard senha == confirmacao else { return .failure(.confirmacaoDiferente) }

        let salt = PasswordHasher.gerarSalt()
        let hash = PasswordHasher.hash(senha: senha, salt: salt)
        UserDefaults.standard.set(salt, forKey: saltKey)
        UserDefaults.standard.set(hash, forKey: hashKey)
        return .success(())
    }

    func verificarSenha(_ senha: String) -> Bool {
        guard possuiSenhaConfigurada,
              let salt = UserDefaults.standard.string(forKey: saltKey),
              let hash = UserDefaults.standard.string(forKey: hashKey) else {
            return false
        }
        return PasswordHasher.verificar(senha: senha, salt: salt, hash: hash)
    }

    @discardableResult
    func autorizar(_ senha: String, confirmacao: String? = nil) -> Result<Void, AdminError> {
        if !possuiSenhaConfigurada {
            guard let confirmacao else { return .failure(.confirmacaoDiferente) }
            return configurarSenha(senha, confirmacao: confirmacao)
        }
        guard verificarSenha(senha) else { return .failure(.senhaIncorreta) }
        return .success(())
    }
}
