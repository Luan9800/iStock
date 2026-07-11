//
//  MensagemConsultorApple.swift
//  iStock
//

import Foundation

struct SugestaoRapidaConsultor: Identifiable {
    let id = UUID()
    let icone: String
    let texto: String
}

extension SugestaoRapidaConsultor {
    static let padroes: [SugestaoRapidaConsultor] = [
        SugestaoRapidaConsultor(icone: "arrow.left.arrow.right", texto: "iPhone 14 ou 15 Pro?"),
        SugestaoRapidaConsultor(icone: "mic.fill", texto: "Argumentos para vender iPhone 15"),
        SugestaoRapidaConsultor(icone: "link", texto: "Benefícios do ecossistema Apple"),
        SugestaoRapidaConsultor(icone: "person.2", texto: "Cliente já tem Mac e iPad"),
        SugestaoRapidaConsultor(icone: "camera.fill", texto: "Diferença Pro vs comum"),
    ]
}

enum ModoConsultorApple: String, CaseIterable, Identifiable {
    case cliente
    case pessoal

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .cliente: return "Para meu cliente"
        case .pessoal: return "Minha dúvida"
        }
    }

    var icone: String {
        switch self {
        case .cliente: return "person.crop.circle.badge.checkmark"
        case .pessoal: return "person.fill.questionmark"
        }
    }

    var sugestoesChat: [String] {
        switch self {
        case .cliente:
            return [
                "Cliente busca iPhone com boa câmera até R$ 5.000",
                "O que temos em estoque de MacBook para estudante?",
                "Compare iPhone 14 Pro e 15 Pro para o cliente",
            ]
        case .pessoal:
            return [
                "iPhone 13 aquecendo após atualização",
                "MacBook Pro teclado butterfly travando",
                "AirPods Pro com chiado no ANC — o que verificar?",
            ]
        }
    }
}

struct ContextoConsultorApple {
    var produtosEstoque: [Lancamento] = []
    var modo: ModoConsultorApple = .cliente
    var criterios: CriteriosAssistente = .padrao
}

enum IntencaoConsultorApple {
    case comparacao
    case argumentos
    case ecossistema
    case especificacoes
    case geral
}

struct ModeloAppleDetectado: Equatable {
    let chave: String
    let nomeExibicao: String
    let geracao: Int
    let tier: TierIPhone
    let destaques: [String]
    let argumentosVenda: [String]

    enum TierIPhone: String {
        case se, regular, plus, pro, proMax
    }
}
