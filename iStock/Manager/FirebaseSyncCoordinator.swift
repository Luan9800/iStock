//
//  FirebaseSyncCoordinator.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import Foundation

@MainActor
final class FirebaseSyncCoordinator: ObservableObject {
    static let shared = FirebaseSyncCoordinator()

    @Published var sincronizado = false
    @Published var erro: String?

    private init() {}

    func atualizarEstadoAuth(usuarioFirebase: User?) {
        if usuarioFirebase != nil {
            iniciarSincronizacao()
        } else {
            pararSincronizacao()
        }
    }

    func iniciarSincronizacao() {
        guard Auth.auth().currentUser != nil else {
            erro = "Autenticação na nuvem necessária para sincronizar."
            sincronizado = false
            return
        }

        erro = nil
        LancamentoService.shared.iniciarListener()
        ClienteService.shared.iniciarListener()
        ModeloFotoService.shared.iniciarListener()
        AvaliacaoService.shared.iniciarListener()
        TransacaoLogService.shared.iniciarListener()

        if let uid = Auth.auth().currentUser?.uid {
            ChatService.shared.iniciarConversasListener(uid: uid)
        }

        sincronizado = true
    }

    func pararSincronizacao() {
        LancamentoService.shared.pararListener()
        ClienteService.shared.pararListener()
        ModeloFotoService.shared.pararListener()
        AvaliacaoService.shared.pararListener()
        TransacaoLogService.shared.pararListener()
        ChatService.shared.pararConversasListener()
        sincronizado = false
    }
}
