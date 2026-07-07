//
//  LocalTransacaoLogStore.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

@MainActor
final class LocalTransacaoLogStore {
    static let shared = LocalTransacaoLogStore()

    private let chave = "istock.transacoes.locais"

    private init() {}

    func carregar() -> [LogTransacao] {
        guard let data = UserDefaults.standard.data(forKey: chave),
              let itens = try? JSONDecoder().decode([LogTransacao].self, from: data) else {
            return []
        }
        return itens.sorted { $0.data > $1.data }
    }

    func salvar(_ itens: [LogTransacao]) {
        guard let data = try? JSONEncoder().encode(itens) else { return }
        UserDefaults.standard.set(data, forKey: chave)
    }
}
