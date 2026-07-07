//
//  ChatService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseFirestore
import Foundation

@MainActor
final class ChatService: ObservableObject {
    static let shared = ChatService()

    @Published var conversas: [Conversa] = []
    @Published var mensagens: [Mensagem] = []

    private let db = Firestore.firestore()
    private var conversasListener: ListenerRegistration?
    private var mensagensListener: ListenerRegistration?

    private init() {}

    func iniciarConversasListener(uid: String) {
        conversasListener?.remove()
        conversasListener = db.collection("conversas")
            .whereField("participantes", arrayContains: uid)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
                        print("Erro ao buscar conversas: \(erro.localizedDescription)")
                        return
                    }
                    let lista = resultado?.documents.compactMap {
                        try? $0.data(as: Conversa.self)
                    } ?? []
                    self.conversas = lista.sorted {
                        ($0.ultimaMensagemData ?? .distantPast) > ($1.ultimaMensagemData ?? .distantPast)
                    }
                }
            }
    }

    func pararConversasListener() {
        conversasListener?.remove()
        conversasListener = nil
        conversas = []
    }

    func observarMensagens(conversaId: String) {
        mensagensListener?.remove()
        mensagensListener = db.collection("conversas")
            .document(conversaId)
            .collection("mensagens")
            .order(by: "data")
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
                        print("Erro ao buscar mensagens: \(erro.localizedDescription)")
                        return
                    }
                    self.mensagens = resultado?.documents.compactMap {
                        try? $0.data(as: Mensagem.self)
                    } ?? []
                }
            }
    }

    func pararObservacaoMensagens() {
        mensagensListener?.remove()
        mensagensListener = nil
        mensagens = []
    }

    func criarConversa(com cliente: Cliente, vendedorNome: String) async -> Conversa? {
        guard let vendedorId = AuthService.shared.uid,
              let clienteId = cliente.id else { return nil }

        if let existente = conversas.first(where: { $0.clienteId == clienteId }) {
            return existente
        }

        var conversa = Conversa(
            clienteId: clienteId,
            clienteNome: cliente.nome,
            vendedorId: vendedorId,
            vendedorNome: vendedorNome,
            participantes: [vendedorId, clienteId],
            ultimaMensagem: nil,
            ultimaMensagemData: nil
        )

        do {
            let ref = try db.collection("conversas").addDocument(from: conversa)
            conversa.id = ref.documentID
            return conversa
        } catch {
            print("Erro ao criar conversa: \(error.localizedDescription)")
            return nil
        }
    }

    func enviarTexto(conversaId: String, texto: String, remetenteId: String, remetenteNome: String) async {
        let mensagem = Mensagem(
            conversaId: conversaId,
            remetenteId: remetenteId,
            remetenteNome: remetenteNome,
            tipo: .texto,
            texto: texto
        )
        await salvarMensagem(mensagem, conversaId: conversaId, preview: texto)
    }

    func enviarFoto(conversaId: String, data: Data, remetenteId: String, remetenteNome: String) async {
        let id = UUID().uuidString
        let path = "chat/\(conversaId)/\(id).jpg"

        do {
            let url = try await ImageStorageService.shared.upload(data: data, path: path)
            let mensagem = Mensagem(
                conversaId: conversaId,
                remetenteId: remetenteId,
                remetenteNome: remetenteNome,
                tipo: .foto,
                mediaURL: url.absoluteString,
                mediaPath: path
            )
            await salvarMensagem(mensagem, conversaId: conversaId, preview: "📷 Foto")
        } catch {
            print("Erro ao enviar foto: \(error.localizedDescription)")
        }
    }

    func enviarAudio(conversaId: String, data: Data, duracao: Double, remetenteId: String, remetenteNome: String) async {
        let id = UUID().uuidString
        let path = "chat/\(conversaId)/\(id).m4a"

        do {
            let url = try await ImageStorageService.shared.upload(data: data, path: path, contentType: "audio/mp4")
            let mensagem = Mensagem(
                conversaId: conversaId,
                remetenteId: remetenteId,
                remetenteNome: remetenteNome,
                tipo: .audio,
                mediaURL: url.absoluteString,
                mediaPath: path,
                duracaoAudio: duracao
            )
            let preview = "🎤 Áudio (\(Int(duracao))s)"
            await salvarMensagem(mensagem, conversaId: conversaId, preview: preview)
        } catch {
            print("Erro ao enviar áudio: \(error.localizedDescription)")
        }
    }

    private func salvarMensagem(_ mensagem: Mensagem, conversaId: String, preview: String) async {
        do {
            try db.collection("conversas")
                .document(conversaId)
                .collection("mensagens")
                .addDocument(from: mensagem)

            try await db.collection("conversas").document(conversaId).updateData([
                "ultimaMensagem": preview,
                "ultimaMensagemData": FieldValue.serverTimestamp()
            ])
        } catch {
            print("Erro ao salvar mensagem: \(error.localizedDescription)")
        }
    }
}
