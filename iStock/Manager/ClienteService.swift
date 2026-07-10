//
//  ClienteService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class ClienteService: ObservableObject {
    static let shared = ClienteService()

    @Published var clientes: [Cliente] = []
    @Published var erro: String?

<<<<<<< HEAD
    private let colecao = Firestore.firestore().collection("clientes")
=======
    private let colecao = FirestoreProvider.db.collection("clientes")
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
    private var listener: ListenerRegistration?

    private init() {}

    func iniciarListener() {
        guard listener == nil else { return }

        listener = colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
<<<<<<< HEAD
                        self.erro = erro.localizedDescription
                        print("Erro ao buscar clientes: \(erro.localizedDescription)")
=======
                        self.erro = FirebaseErrorHelper.mensagem(erro)
                        FirebaseSyncCoordinator.shared.registrarErroPermissao(erro)
                        print("Erro ao buscar clientes: \(FirebaseErrorHelper.mensagem(erro))")
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
                        return
                    }
                    self.erro = nil
                    self.clientes = resultado?.documents.compactMap {
                        try? $0.data(as: Cliente.self)
                    } ?? []
                }
            }
    }

    func pararListener() {
        listener?.remove()
        listener = nil
        clientes = []
        erro = nil
    }

    @discardableResult
    func salvar(_ cliente: Cliente) -> Bool {
        guard Auth.auth().currentUser != nil else {
            erro = "Faça login na aba Nuvem para salvar na nuvem."
            return false
        }

        do {
            if let id = cliente.id {
                try colecao.document(id).setData(from: cliente)
            } else {
                try colecao.addDocument(from: cliente)
            }
            erro = nil
            return true
        } catch {
<<<<<<< HEAD
            erro = error.localizedDescription
            print("Erro ao salvar cliente: \(error.localizedDescription)")
=======
            erro = FirebaseErrorHelper.mensagem(error)
            print("Erro ao salvar cliente: \(FirebaseErrorHelper.mensagem(error))")
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return false
        }
    }

    func remover(_ cliente: Cliente) {
        guard let id = cliente.id else { return }
        colecao.document(id).delete()
    }
}
