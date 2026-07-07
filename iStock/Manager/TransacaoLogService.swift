//
//  TransacaoLogService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class TransacaoLogService: ObservableObject {
    static let shared = TransacaoLogService()
    static let limiteExibicao = 5

    @Published var transacoes: [LogTransacao] = []
    @Published var erro: String?

    private let colecao = Firestore.firestore().collection("transacoes")
    private var listener: ListenerRegistration?

    private init() {}

    func iniciarListener() {
        guard listener == nil else { return }

        listener = colecao.order(by: "data", descending: true).limit(to: 200)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
                        self.erro = erro.localizedDescription
                        return
                    }
                    self.erro = nil
                    self.transacoes = resultado?.documents.compactMap {
                        try? $0.data(as: LogTransacao.self)
                    } ?? []
                }
            }
    }

    func carregarLocal() {
        pararListener(mantendoDados: false)
        transacoes = LocalTransacaoLogStore.shared.carregar()
    }

    func pararListener(mantendoDados: Bool = false) {
        listener?.remove()
        listener = nil
        if !mantendoDados { transacoes = [] }
        erro = nil
    }

    func registrar(
        tipo: TipoTransacao,
        titulo: String,
        detalhes: String? = nil,
        valor: Double? = nil,
        valorAnterior: Double? = nil,
        referenciaId: String? = nil
    ) {
        let item = LogTransacao(
            id: UUID().uuidString,
            tipo: tipo,
            titulo: titulo,
            detalhes: detalhes,
            valor: valor,
            valorAnterior: valorAnterior,
            referenciaId: referenciaId,
            usuario: AuthService.shared.nomeOuEmail
        )

        if AuthService.shared.usandoLoginLocal {
            transacoes.insert(item, at: 0)
            LocalTransacaoLogStore.shared.salvar(transacoes)
            return
        }

        guard Auth.auth().currentUser != nil else { return }
        do {
            try colecao.addDocument(from: item)
        } catch {
            self.erro = error.localizedDescription
        }
    }

    var recentes: [LogTransacao] {
        Array(transacoes.prefix(Self.limiteExibicao))
    }

    func exportarCSV() -> URL? {
        guard !transacoes.isEmpty else { return nil }

        var linhas = ["Data;Tipo;Título;Detalhes;Valor;Valor anterior;Usuário;Referência"]
        for item in transacoes {
            let campos = [
                Formatters.dataTransacao.string(from: item.data),
                item.tipo.rawValue,
                item.titulo,
                item.detalhes ?? "",
                item.valor.map { String(format: "%.2f", $0) } ?? "",
                item.valorAnterior.map { String(format: "%.2f", $0) } ?? "",
                item.usuario ?? "",
                item.referenciaId ?? ""
            ]
            linhas.append(campos.map(csvCampo).joined(separator: ";"))
        }

        let conteudo = linhas.joined(separator: "\n")
        let diretorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("exportacoes", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let nome = "log-transacoes-\(Formatters.arquivoData.string(from: .now)).csv"
            let url = diretorio.appendingPathComponent(nome)
            try conteudo.write(to: url, atomically: true, encoding: .utf8)
            erro = nil
            return url
        } catch {
            self.erro = error.localizedDescription
            return nil
        }
    }

    private func csvCampo(_ texto: String) -> String {
        if texto.contains(";") || texto.contains("\"") || texto.contains("\n") {
            return "\"\(texto.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return texto
    }
}
