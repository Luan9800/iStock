//
//  AssistenteIATiming.swift
//  iStock
//

import Foundation

enum AssistenteIATiming {
    /// Delay curto para o indicador “pensando” ficar visível.
    static let delayDigitando: Duration = .milliseconds(800)

    static func aguardarResposta<T>(_ operacao: () async -> T) async -> T {
        async let resultado = operacao()
        try? await Task.sleep(for: delayDigitando)
        return await resultado
    }
}
