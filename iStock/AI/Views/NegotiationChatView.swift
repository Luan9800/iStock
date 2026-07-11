//
//  NegotiationChatView.swift
//  iStock
//

import SwiftUI

struct NegotiationChatView: View {
    @StateObject private var viewModel = NegociacaoChatViewModel()

    var body: some View {
        AssistenteChatView(
            titulo: "Negociação",
            sugestoes: SugestaoRapidaNegociacao.textosNegociacao,
            mensagens: viewModel.mensagens,
            processando: viewModel.processando,
            onEnviar: { texto in await viewModel.enviar(texto) },
            onLimpar: { viewModel.limparConversa() }
        )
        .onAppear { viewModel.iniciar() }
    }
}
