//
//  SyncStatusBanner.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//
import SwiftUI
import Combine

struct SyncStatusBanner: View {

    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var sync = FirebaseSyncCoordinator.shared
    @ObservedObject private var lancamentos = LancamentoService.shared

    @State private var mostrarSucesso = false
    @State private var tarefaOcultar: Task<Void, Never>?

    var body: some View {
        Group {
            if auth.estaLogado && !auth.autenticadoNaNuvem {

                banner(
                    texto: "Login local — dados na nuvem não sincronizam.",
                    cor: .orange,
                    icone: "icloud.slash"
                )

            } else if let erro = mensagemErro {

                banner(
                    texto: erro,
                    cor: .red,
                    icone: "exclamationmark.icloud"
                )

            } else if auth.autenticadoNaNuvem &&
                        sync.sincronizado &&
                        mostrarSucesso {

                banner(
                    texto: "Sincronizado com Firebase",
                    cor: AppTheme.azulClaro,
                    icone: "icloud.fill"
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: mostrarSucesso)
        .onChange(of: sync.sincronizado) { _, sincronizado in
            agendarOcultacao(seSincronizado: sincronizado)
        }
    }

    private func banner(
        texto: String,
        cor: Color,
        icone: String
    ) -> some View {

        HStack(spacing: 8) {

            Image(systemName: icone)

            Text(texto)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()
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

    private func agendarOcultacao(seSincronizado sincronizado: Bool) {

        tarefaOcultar?.cancel()

        guard sincronizado else {
            mostrarSucesso = false
            return
        }

        mostrarSucesso = true

        tarefaOcultar = Task { @MainActor in

            try? await Task.sleep(
                nanoseconds: 3_000_000_000
            )

            guard !Task.isCancelled else {
                return
            }

            mostrarSucesso = false
        }
    }

    private var mensagemErro: String? {
        sync.erro ??
        lancamentos.erro ??
        ClienteService.shared.erro ??
        ModeloFotoService.shared.erro
    }
}
