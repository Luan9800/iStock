//
//  UsuarioService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

<<<<<<< HEAD
=======
import FirebaseAuth
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
import FirebaseFirestore
import Foundation

enum UsuarioError: LocalizedError {
    case limiteAdministradores
    case usuarioNaoEncontrado
    case naoAutenticado
<<<<<<< HEAD
=======
    case permissaoNegada(String)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)

    var errorDescription: String? {
        switch self {
        case .limiteAdministradores:
            return "Limite de 4 administradores atingido. Escolha outro perfil."
        case .usuarioNaoEncontrado:
            return "Perfil do usuário não encontrado."
        case .naoAutenticado:
            return "Faça login na nuvem para continuar."
<<<<<<< HEAD
=======
        case .permissaoNegada(let mensagem):
            return mensagem
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
        }
    }
}

@MainActor
final class UsuarioService {
    static let shared = UsuarioService()
    static let maxAdministradores = 4

<<<<<<< HEAD
    private let colecao = Firestore.firestore().collection("usuarios")
=======
    private let colecao = FirestoreProvider.db.collection("usuarios")
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)

    private init() {}

    func contarAdministradoresNuvem() async -> Int {
<<<<<<< HEAD
=======
        if Auth.auth().currentUser == nil {
            return await contarAdministradoresPublico()
        }

>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
        do {
            let resultado = try await colecao
                .whereField("papel", isEqualTo: PapelUsuario.administrador.rawValue)
                .getDocuments()
            return resultado.documents.count
        } catch {
<<<<<<< HEAD
=======
            return await contarAdministradoresPublico()
        }
    }

    private func contarAdministradoresPublico() async -> Int {
        do {
            let documento = try await FirestoreProvider.db
                .collection("config")
                .document("limites")
                .getDocument()
            return documento.data()?["administradores"] as? Int ?? 0
        } catch {
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
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
<<<<<<< HEAD
            return .success(())
        } catch {
=======
            await atualizarContadorAdministradores()
            return .success(())
        } catch {
            if FirebaseErrorHelper.ehPermissaoNegada(error) {
                return .failure(.permissaoNegada(FirebaseErrorHelper.mensagem(error)))
            }
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
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
<<<<<<< HEAD
=======
        await atualizarContadorAdministradores()
    }

    private func atualizarContadorAdministradores() async {
        let total = await contarAdministradoresNuvem()
        try? await FirestoreProvider.db
            .collection("config")
            .document("limites")
            .setData(["administradores": total], merge: true)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
    }
}
