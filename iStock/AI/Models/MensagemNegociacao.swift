//
//  MensagemNegociacao.swift
//  iStock
//

import Combine
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

    static let textosNegociacao: [String] = [
        "Cliente quer pagar R$ 3.900 no iPhone 14 Pro",
        "Troca iPhone 13 por iPhone 15 Pro — quanto cobrar de diferença?",
        "Cliente pediu 10% de desconto à vista",
    ]
}

enum TomAtendimento: String, Codable, CaseIterable, Identifiable {
    case consultivo
    case assertivo
    case tecnico

    var id: String { rawValue }

    var rotulo: String {
        switch self {
        case .consultivo: return "Consultivo"
        case .assertivo: return "Assertivo"
        case .tecnico: return "Técnico"
        }
    }
}

enum FlexibilidadePreco: String, Codable, CaseIterable, Identifiable {
    case baixa
    case media
    case alta

    var id: String { rawValue }

    var rotulo: String {
        switch self {
        case .baixa: return "Baixa"
        case .media: return "Média"
        case .alta: return "Alta"
        }
    }
}

struct CriteriosAssistente: Codable, Equatable {
    var margemMinimaPercentual: Double
    var descontoMaximoPercentual: Double
    var valorMinimoMargem: Double
    var tomAtendimento: TomAtendimento
    var aceitarTroca: Bool
    var priorizarLacrado: Bool
    var flexibilidadePreco: FlexibilidadePreco
    var notasPersonalizadas: String

    static let padrao = CriteriosAssistente(
        margemMinimaPercentual: 15,
        descontoMaximoPercentual: 8,
        valorMinimoMargem: 150,
        tomAtendimento: .consultivo,
        aceitarTroca: true,
        priorizarLacrado: true,
        flexibilidadePreco: .media,
        notasPersonalizadas: ""
    )

    var resumo: String {
        "margem \(Int(margemMinimaPercentual))% · desconto máx. \(Int(descontoMaximoPercentual))% · tom \(tomAtendimento.rotulo.lowercased()) · flexibilidade \(flexibilidadePreco.rotulo.lowercased())"
    }

    var blocoPrompt: String {
        var linhas = [
            "Margem mínima: \(Int(margemMinimaPercentual))%",
            "Desconto máximo: \(Int(descontoMaximoPercentual))%",
            "Margem mínima em R$: \(Formatters.brl(valorMinimoMargem))",
            "Tom: \(tomAtendimento.rotulo)",
            "Flexibilidade de preço: \(flexibilidadePreco.rotulo)",
            "Aceitar troca: \(aceitarTroca ? "sim" : "não")",
            "Priorizar lacrado: \(priorizarLacrado ? "sim" : "não")",
        ]
        let notas = notasPersonalizadas.trimmingCharacters(in: .whitespacesAndNewlines)
        if !notas.isEmpty {
            linhas.append("Notas da loja: \(notas)")
        }
        return linhas.joined(separator: "\n")
    }
}

@MainActor
final class CriteriosAssistenteStore: ObservableObject {
    static let shared = CriteriosAssistenteStore()

    @Published private(set) var criterios: CriteriosAssistente

    private let chave = "istock.assistente.criterios"

    private init() {
        if let data = UserDefaults.standard.data(forKey: chave),
           let salvos = try? JSONDecoder().decode(CriteriosAssistente.self, from: data) {
            criterios = salvos
        } else {
            criterios = .padrao
        }
    }

    func salvar(_ novos: CriteriosAssistente) {
        criterios = novos
        if let data = try? JSONEncoder().encode(novos) {
            UserDefaults.standard.set(data, forKey: chave)
        }
    }
}
