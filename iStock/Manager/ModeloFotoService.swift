//
//  ModeloFotoService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class ModeloFotoService: ObservableObject {
    static let shared = ModeloFotoService()
    static let maxFotosPorCadastro = 100

    @Published var fotos: [ModeloFoto] = []
    @Published var erro: String?

    private let colecao = Firestore.firestore().collection("modelo_fotos")
    private let fotosLocaisKey = "istock.cadastro.fotos"
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
                        print("Erro ao buscar fotos de cadastro: \(erro.localizedDescription)")
                        return
                    }
                    self.erro = nil
                    self.fotos = resultado?.documents.compactMap {
                        try? $0.data(as: ModeloFoto.self)
                    } ?? []
                }
            }
    }

    func carregarLocal() {
        listener?.remove()
        listener = nil
        fotos = carregarFotosLocais()
        erro = nil
    }

    func pararListener() {
        listener?.remove()
        listener = nil
        fotos = []
        erro = nil
    }

    func fotos(para cadastroId: String) -> [ModeloFoto] {
        fotos.filter { $0.cadastroId == cadastroId }
    }

    func contagem(para cadastroId: String) -> Int {
        fotos(para: cadastroId).count
    }

    func podeAdicionar(cadastroId: String) -> Bool {
        contagem(para: cadastroId) < Self.maxFotosPorCadastro
    }

    func adicionar(
        cadastroId: String,
        tipo: TipoProduto,
        imagemData: Data,
        criadoPor: String?
    ) async -> Bool {
        guard podeAdicionar(cadastroId: cadastroId) else {
            erro = "Limite de \(Self.maxFotosPorCadastro) fotos atingido para este cadastro."
            return false
        }

        if AuthService.shared.usandoLoginLocal {
            return adicionarLocal(cadastroId: cadastroId, tipo: tipo, imagemData: imagemData, criadoPor: criadoPor)
        }

        guard Auth.auth().currentUser != nil else {
            erro = "Faça login na aba Nuvem para enviar fotos."
            return false
        }

        let id = UUID().uuidString
        let path = "cadastros/\(cadastroId)/\(id).jpg"

        do {
            let url = try await ImageStorageService.shared.upload(data: imagemData, path: path)
            let foto = ModeloFoto(
                cadastroId: cadastroId,
                tipoProduto: tipo,
                fotoURL: url.absoluteString,
                fotoPath: path,
                criadoPor: criadoPor
            )
            try colecao.addDocument(from: foto)
            erro = nil
            return true
        } catch {
            erro = error.localizedDescription
            print("Erro ao adicionar foto do cadastro: \(error.localizedDescription)")
            return false
        }
    }

    func remover(_ foto: ModeloFoto) async {
        if AuthService.shared.usandoLoginLocal {
            removerLocal(foto)
            return
        }

        guard let id = foto.id else { return }

        do {
            try await ImageStorageService.shared.delete(path: foto.fotoPath)
            try await colecao.document(id).delete()
            erro = nil
        } catch {
            erro = error.localizedDescription
            print("Erro ao remover foto do cadastro: \(error.localizedDescription)")
        }
    }

    // MARK: - Local

    @discardableResult
    private func adicionarLocal(
        cadastroId: String,
        tipo: TipoProduto,
        imagemData: Data,
        criadoPor: String?
    ) -> Bool {
        let diretorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("cadastros/\(cadastroId)", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let nome = "\(UUID().uuidString).jpg"
            let arquivo = diretorio.appendingPathComponent(nome)
            try imagemData.write(to: arquivo)

            let foto = ModeloFoto(
                id: UUID().uuidString,
                cadastroId: cadastroId,
                tipoProduto: tipo,
                fotoURL: arquivo.absoluteString,
                fotoPath: arquivo.path,
                criadoPor: criadoPor
            )
            fotos.insert(foto, at: 0)
            persistirFotosLocais()
            erro = nil
            return true
        } catch {
            self.erro = error.localizedDescription
            return false
        }
    }

    private func removerLocal(_ foto: ModeloFoto) {
        if !foto.fotoPath.isEmpty {
            try? FileManager.default.removeItem(atPath: foto.fotoPath)
        }
        fotos.removeAll { $0.id == foto.id }
        persistirFotosLocais()
        erro = nil
    }

    private func carregarFotosLocais() -> [ModeloFoto] {
        guard let data = UserDefaults.standard.data(forKey: fotosLocaisKey),
              let itens = try? JSONDecoder().decode([ModeloFoto].self, from: data) else {
            return []
        }
        return itens
    }

    private func persistirFotosLocais() {
        guard let data = try? JSONEncoder().encode(fotos) else { return }
        UserDefaults.standard.set(data, forKey: fotosLocaisKey)
    }
}
