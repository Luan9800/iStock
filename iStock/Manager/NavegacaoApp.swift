//
//  NavegacaoApp.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import Foundation

@MainActor
final class NavegacaoApp: ObservableObject {
    static let shared = NavegacaoApp()

    @Published var abaDestino: SidebarItem?
    @Published var conversaDestino: Conversa?

    private init() {}

    func abrirMensagens(com cliente: Cliente) async {
        guard AuthService.shared.estaLogado else { return }

        let conversa = await ChatService.shared.criarConversa(
            com: cliente,
            vendedorNome: AuthService.shared.nomeOuEmail
        )

        guard let conversa else { return }

        conversaDestino = conversa
        abaDestino = .mensagens
    }

    func limparDestinoMensagens() {
        conversaDestino = nil
    }
}
