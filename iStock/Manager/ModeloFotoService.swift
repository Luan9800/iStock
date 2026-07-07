//
//  ModeloFotoService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseFirestore
import Foundation

@MainActor
final class ModeloFotoService: ObservableObject {
    static let shared = ModeloFotoService()
    static let maxFotosPorModelo = 100

    @Published var fotos: [ModeloFoto] = []

    private let colecao = Firestore.firestore().collection("modelo_fotos")

    private init() {
        colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] resultado, erro in
                if let erro {
                    print("Erro ao buscar fotos de modelo: \(erro.localizedDescription)")
                    return
                }
                self?.fotos = resultado?.documents.compactMap {
                    try? $0.data(as: ModeloFoto.self)
                } ?? []
            }
    }

    func fotos(para tipo: TipoProduto) -> [ModeloFoto] {
        fotos.filter { $0.tipoProduto == tipo }
    }

    func podeAdicionar(tipo: TipoProduto) -> Bool {
        fotos(para: tipo).count < Self.maxFotosPorModelo
    }

    func adicionar(tipo: TipoProduto, imagemData: Data, criadoPor: String?) async -> Bool {
        guard podeAdicionar(tipo: tipo) else { return false }
        let id = UUID().uuidString
        let path = "modelos/\(tipo.rawValue)/\(id).jpg"

        do {
            let url = try await ImageStorageService.shared.upload(data: imagemData, path: path)
            let foto = ModeloFoto(
                tipoProduto: tipo,
                fotoURL: url.absoluteString,
                fotoPath: path,
                criadoPor: criadoPor
            )
            try colecao.addDocument(from: foto)
            return true
        } catch {
            print("Erro ao adicionar foto do modelo: \(error.localizedDescription)")
            return false
        }
    }

    func remover(_ foto: ModeloFoto) async {
        guard let id = foto.id else { return }

        do {
            try await ImageStorageService.shared.delete(path: foto.fotoPath)
            try await colecao.document(id).delete()
        } catch {
            print("Erro ao remover foto do modelo: \(error.localizedDescription)")
        }
    }
}
