//
//  LancamentoService.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import SwiftUI
import Combine
import Foundation
import FirebaseFirestore


@MainActor
final class LancamentoService: ObservableObject {
    static let shared = LancamentoService()
    
    @Published var lancamentos: [Lancamento] = []
    private let colecao = Firestore.firestore().collection("lancamentos")
    
    private init() {
        colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] (resultado, erro) in
                if let erro {
                    print("Erro ao buscar lançamentos: \(erro.localizedDescription)")
                    return
                }
                self?.lancamentos = resultado?.documents.compactMap {
                    try? $0.data(as: Lancamento.self)
                } ?? []
        }
    }
    
    func salvar(_ item: Lancamento) {
        do {
            try colecao.addDocument(from: item)
        } catch {
            print("Erro ao salvar produto: \(error.localizedDescription)")
        }
    }
}
