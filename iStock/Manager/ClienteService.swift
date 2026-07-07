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

    private let colecao = Firestore.firestore().collection("clientes")
    private var listener: ListenerRegistration?

    private init() {}

    func iniciarListener() {
        guard listener == nil else { return }

        listener = colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
                        self.erro = erro.localizedDescription
                        print("Erro ao buscar clientes: \(erro.localizedDescription)")
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
            erro = error.localizedDescription
            print("Erro ao salvar cliente: \(error.localizedDescription)")
            return false
        }
    }

    func remover(_ cliente: Cliente) {
        guard let id = cliente.id else { return }
        colecao.document(id).delete()
    }
}
