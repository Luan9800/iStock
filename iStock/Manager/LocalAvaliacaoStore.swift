//
//  LocalAvaliacaoStore.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

@MainActor
final class LocalAvaliacaoStore {
    static let shared = LocalAvaliacaoStore()

    private let chave = "istock.avaliacoes.locais"

    private init() {}

    func carregar() -> [Avaliacao] {
        guard let data = UserDefaults.standard.data(forKey: chave),
              let itens = try? JSONDecoder().decode([Avaliacao].self, from: data) else {
            return []
        }
        return itens.sorted { $0.data > $1.data }
    }

    func salvar(_ itens: [Avaliacao]) {
        guard let data = try? JSONEncoder().encode(itens) else { return }
        UserDefaults.standard.set(data, forKey: chave)
    }
}
