//
//  AssistenteIATiming.swift
//  iStock
//

import Foundation

enum AssistenteIATiming {
    static let delayDigitando: Duration = .seconds(4)

    static func aguardarResposta<T>(_ operacao: () async -> T) async -> T {
        async let resultado = operacao()
        try? await Task.sleep(for: delayDigitando)
        return await resultado
    }
}
