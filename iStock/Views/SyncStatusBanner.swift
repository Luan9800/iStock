//
//  SyncStatusBanner.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct SyncStatusBanner: View {
    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var sync = FirebaseSyncCoordinator.shared
    @ObservedObject private var lancamentos = LancamentoService.shared

    var body: some View {
        if auth.estaLogado && !auth.autenticadoNaNuvem {
            banner(
                texto: "Login local — dados na nuvem não sincronizam.",
                cor: .orange,
                icone: "icloud.slash"
            )
        } else if let erro = mensagemErro {
            banner(texto: erro, cor: .red, icone: "exclamationmark.icloud")
        } else if auth.autenticadoNaNuvem && sync.sincronizado {
            banner(texto: "Sincronizado com Firebase", cor: AppTheme.azulClaro, icone: "icloud.fill")
        }
    }

    private var mensagemErro: String? {
        sync.erro ?? lancamentos.erro ?? ClienteService.shared.erro ?? ModeloFotoService.shared.erro
    }

    private func banner(texto: String, cor: Color, icone: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icone)
            Text(texto)
                .font(.caption)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(cor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cor.opacity(0.12))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(cor.opacity(0.25))
                .frame(height: 1)
        }
    }
}
