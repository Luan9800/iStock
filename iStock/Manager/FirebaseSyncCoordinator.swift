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
        guard let usuario = Auth.auth().currentUser else {
            erro = "Autenticação na nuvem necessária para sincronizar."
            sincronizado = false
            return
        }

        Task {
            do {
                _ = try await usuario.getIDToken(forcingRefresh: true)
            } catch {
                erro = FirebaseErrorHelper.mensagem(error)
                sincronizado = false
                return
            }

            await NuvemMigracaoService.shared.migrarSeNecessario()

            erro = nil
            LancamentoService.shared.iniciarListener()
            ClienteService.shared.iniciarListener()
            ModeloFotoService.shared.iniciarListener()
            AvaliacaoService.shared.iniciarListener()
            TransacaoLogService.shared.iniciarListener()
            ChatService.shared.iniciarConversasListener(uid: usuario.uid)
            sincronizado = true
        }
    }

    func registrarErroPermissao(_ error: Error) {
        guard FirebaseErrorHelper.ehPermissaoNegada(error) else { return }
        erro = FirebaseErrorHelper.mensagem(error)
        sincronizado = false
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
