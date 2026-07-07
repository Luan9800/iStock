//
//  ModeloFoto.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import FirebaseFirestore

struct ModeloFoto: Identifiable, Codable {
    @DocumentID var id: String?
    var tipoProduto: TipoProduto
    var fotoURL: String
    var fotoPath: String
    var data: Date = .now
    var criadoPor: String?
}
