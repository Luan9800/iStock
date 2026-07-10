//
//  MensagemNegociacao.swift
//  iStock
//

import Foundation

enum PapelMensagemNegociacao: String, Codable {
    case usuario
    case assistente
}

struct MensagemNegociacao: Identifiable, Equatable {
    let id: UUID
    let papel: PapelMensagemNegociacao
    let texto: String
    let data: Date

    init(id: UUID = UUID(), papel: PapelMensagemNegociacao, texto: String, data: Date = .now) {
        self.id = id
        self.papel = papel
        self.texto = texto
        self.data = data
    }
}

struct SugestaoRapidaNegociacao: Identifiable {
    let id = UUID()
    let icone: String
    let texto: String
}

extension SugestaoRapidaNegociacao {
    static let padroes: [SugestaoRapidaNegociacao] = [
        SugestaoRapidaNegociacao(icone: "percent", texto: "Cliente pediu desconto"),
        SugestaoRapidaNegociacao(icone: "arrow.triangle.2.circlepath", texto: "Quer trocar aparelho usado"),
        SugestaoRapidaNegociacao(icone: "dollarsign.arrow.circlepath", texto: "Fez contraproposta de valor"),
        SugestaoRapidaNegociacao(icone: "exclamationmark.bubble", texto: "Disse que está caro"),
        SugestaoRapidaNegociacao(icone: "hand.thumbsup.fill", texto: "Como fechar a venda hoje?"),
    ]
}
