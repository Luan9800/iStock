//
//  NegociacaoAssistenteService.swift
//  iStock
//

import Foundation
import FirebaseCore
import FirebaseAILogic

@MainActor
final class NegociacaoAssistenteService {
    private let motorLocal = NegociacaoMotorLocal()
    private var chat: Chat?
    private var modelo: GenerativeModel?
    private var iaDisponivel = false

    private static let instrucaoSistema = """
    Você é o Assistente de Negociação do app iStock, especializado em vendas de produtos Apple no Brasil.

    Ajude consultores de vendas com:
    - Descontos seguros (preservando margem)
    - Trocas e avaliação de aparelhos usados como entrada
    - Contrapropostas estratégicas
    - Estratégias para fechar vendas (PIX, parcelamento, urgência, benefícios)
    - Respostas a objeções (preço alto, concorrente, "vou pensar")

    Regras de resposta:
    - Português brasileiro, tom profissional e direto
    - Respeite SEMPRE os [Critérios da loja] enviados no contexto (margem, desconto máximo, troca, tom)
    - Use seções curtas com emojis: 📌 💡 💬 💰 ⚠️
    - Sempre inclua frases prontas que o consultor pode dizer ao cliente
    - Quando houver valores, use formato R$ brasileiro
    - Se faltar dado essencial (preço, custo, oferta do cliente), pergunte objetivamente
    - Não invente preços de mercado — trabalhe com os valores informados
    - Respostas concisas (máximo ~12 linhas), focadas em ação imediata
    """

    init() {
        configurarIA()
    }

    func responder(pergunta: String, contexto: ContextoNegociacao) async -> String {
        let perguntaLimpa = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !perguntaLimpa.isEmpty else {
            return motorLocal.mensagemBoasVindas()
        }

        let perguntaEnriquecida = enriquecerComContexto(perguntaLimpa, contexto: contexto)

        if iaDisponivel, let chat {
            do {
                let resposta = try await chat.sendMessage(perguntaEnriquecida)
                if let texto = resposta.text?.trimmingCharacters(in: .whitespacesAndNewlines), !texto.isEmpty {
                    return texto
                }
            } catch {
                print("⚠️ Assistente IA: fallback local — \(error.localizedDescription)")
            }
        }

        return motorLocal.responder(pergunta: perguntaLimpa, contexto: contexto)
    }

    func reiniciarConversa() {
        chat = modelo?.startChat()
    }

    // MARK: - Privado

    private func configurarIA() {
        let emPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"

        guard !emPreview, FirebaseApp.app() != nil else { return }

        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        modelo = ai.generativeModel(
            modelName: "gemini-2.0-flash",
            systemInstruction: ModelContent(role: "user", parts: Self.instrucaoSistema)
        )
        chat = modelo?.startChat()
        iaDisponivel = chat != nil
    }

    private func enriquecerComContexto(_ pergunta: String, contexto: ContextoNegociacao) -> String {
        var blocos: [String] = []

        blocos.append("""
        [Critérios da loja]
        \(contexto.criterios.blocoPrompt)
        """)

        let produtos = contexto.produtosEstoque.filter(\.estaNoEstoque)
        let filtrados = contexto.criterios.priorizarLacrado
            ? produtos.sorted { ($0.lacrado ? 0 : 1) < ($1.lacrado ? 0 : 1) }
            : Array(produtos)
        let amostra = filtrados.prefix(8)

        if !amostra.isEmpty {
            let lista = amostra.map { produto in
                var linha = "- \(produto.tituloExibicao): \(Formatters.brl(produto.valor)) (\(produto.status.rawValue))"
                if let margem = produto.margemPercentual {
                    linha += ", margem \(String(format: "%.0f", margem))%"
                }
                if produto.lacrado { linha += " [lacrado]" }
                return linha
            }.joined(separator: "\n")
            blocos.append("[Contexto do estoque iStock]\n\(lista)")
        }

        if !contexto.criterios.aceitarTroca {
            blocos.append("[Política] Troca/permuta não é prioridade nesta loja.")
        }

        blocos.append("[Pergunta do consultor]\n\(pergunta)")
        return blocos.joined(separator: "\n\n")
    }
}
