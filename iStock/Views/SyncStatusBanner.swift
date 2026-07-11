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

    private var estado: (texto: String, cor: Color, icone: String)? {
        if auth.estaLogado && !auth.autenticadoNaNuvem {
            return (
                "Login local — dados na nuvem não sincronizam.",
                .orange,
                "icloud.slash"
            )
        }
        if let erro = mensagemErro {
            return (erro, .red, "exclamationmark.icloud")
        }
        if auth.autenticadoNaNuvem && sync.sincronizado {
            return ("Sincronizado com Firebase", AppTheme.azulClaro, "icloud.fill")
        }
        return nil
    }

    var body: some View {
        if let estado {
            HStack(spacing: 8) {
                Image(systemName: estado.icone)
                Text(estado.texto)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .foregroundStyle(estado.cor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(estado.cor.opacity(0.12))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(estado.cor.opacity(0.25))
                    .frame(height: 1)
            }
        }
    }

    private var mensagemErro: String? {
        sync.erro ?? lancamentos.erro ?? ClienteService.shared.erro ?? ModeloFotoService.shared.erro
    }
}
