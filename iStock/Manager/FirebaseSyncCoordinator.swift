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
<<<<<<< HEAD
        guard Auth.auth().currentUser != nil else {
=======
        guard let usuario = Auth.auth().currentUser else {
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            erro = "Autenticação na nuvem necessária para sincronizar."
            sincronizado = false
            return
        }

<<<<<<< HEAD
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
=======
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
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
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
