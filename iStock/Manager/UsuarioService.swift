//
//  UsuarioService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import FirebaseFirestore
import Foundation

enum UsuarioError: LocalizedError {
    case limiteAdministradores
    case usuarioNaoEncontrado
    case naoAutenticado

    var errorDescription: String? {
        switch self {
        case .limiteAdministradores:
            return "Limite de 4 administradores atingido. Escolha outro perfil."
        case .usuarioNaoEncontrado:
            return "Perfil do usuário não encontrado."
        case .naoAutenticado:
            return "Faça login na nuvem para continuar."
        }
    }
}

@MainActor
final class UsuarioService {
    static let shared = UsuarioService()
    static let maxAdministradores = 4

    private let colecao = Firestore.firestore().collection("usuarios")

    private init() {}

    func contarAdministradoresNuvem() async -> Int {
        do {
            let resultado = try await colecao
                .whereField("papel", isEqualTo: PapelUsuario.administrador.rawValue)
                .getDocuments()
            return resultado.documents.count
        } catch {
            return 0
        }
    }

    func podeRegistrarAdministradorNuvem() async -> Bool {
        await contarAdministradoresNuvem() < Self.maxAdministradores
    }

    func salvarPerfilNuvem(
        uid: String,
        nome: String,
        email: String,
        papel: PapelUsuario
    ) async -> Result<Void, UsuarioError> {
        if papel == .administrador {
            let total = await contarAdministradoresNuvem()
            if total >= Self.maxAdministradores {
                return .failure(.limiteAdministradores)
            }
        }

        let perfil = UsuarioApp(
            nome: nome.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            papel: papel,
            dataCadastro: .now
        )

        do {
            try colecao.document(uid).setData(from: perfil)
            return .success(())
        } catch {
            return .failure(.naoAutenticado)
        }
    }

    func carregarPapelNuvem(uid: String) async -> PapelUsuario? {
        do {
            let documento = try await colecao.document(uid).getDocument()
            guard let perfil = try? documento.data(as: UsuarioApp.self) else { return nil }
            return perfil.papel
        } catch {
            return nil
        }
    }

    func removerPerfilNuvem(uid: String) async {
        try? await colecao.document(uid).delete()
    }
}
