//
//  LocalInventoryStore.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

@MainActor
final class LocalInventoryStore {
    static let shared = LocalInventoryStore()

    private let chave = "istock.lancamentos.locais"

    private init() {}

    func carregar() -> [Lancamento] {
        guard let data = UserDefaults.standard.data(forKey: chave),
              let itens = try? JSONDecoder().decode([Lancamento].self, from: data) else {
            return []
        }
        return itens.sorted { $0.data > $1.data }
    }

    func salvar(_ itens: [Lancamento]) {
        guard let data = try? JSONEncoder().encode(itens) else { return }
        UserDefaults.standard.set(data, forKey: chave)
    }
}
