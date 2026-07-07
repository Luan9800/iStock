//
//  Chat.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import FirebaseFirestore

enum TipoMensagem: String, Codable {
    case texto
    case foto
    case audio
}

struct Conversa: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var clienteId: String
    var clienteNome: String
    var vendedorId: String
    var vendedorNome: String
    var participantes: [String]
    var ultimaMensagem: String?
    var ultimaMensagemData: Date?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Conversa, rhs: Conversa) -> Bool {
        lhs.id == rhs.id
    }
}

struct Mensagem: Identifiable, Codable {
    @DocumentID var id: String?
    var conversaId: String
    var remetenteId: String
    var remetenteNome: String
    var tipo: TipoMensagem
    var texto: String?
    var mediaURL: String?
    var mediaPath: String?
    var duracaoAudio: Double?
    var data: Date = .now
}
