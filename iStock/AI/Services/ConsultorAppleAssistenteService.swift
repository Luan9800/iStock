//
//  ConsultorAppleAssistenteService.swift
//  iStock
//

import Foundation
import FirebaseCore
import FirebaseAILogic

@MainActor
final class ConsultorAppleAssistenteService {
    private let motorLocal = ConsultorAppleMotorLocal()
    private var chat: Chat?
    private var modelo: GenerativeModel?
    private var iaDisponivel = false

    private static let instrucaoSistema = """
    Você é o Consultor Apple do app iStock, especialista em vendas de produtos Apple no Brasil.

    Ajude consultores com:
    - Argumentos de venda persuasivos e éticos
    - Comparação clara entre modelos (iPhone, iPad, Mac, AirPods, Watch)
    - Benefícios do ecossistema Apple (iCloud, AirDrop, Continuidade, Handoff, integração)

    Regras de resposta:
    - Português brasileiro, tom consultivo e profissional
    - Respeite os [Critérios da loja] quando enviados
    - No modo técnico, foque em diagnóstico, defeitos conhecidos e checklist de inspeção
    - Use seções com emojis: 📌 ✨ ⚖️ 💡 💬 🔗
    - Inclua frases prontas que o consultor pode dizer ao cliente
    - Destaque diferenciais práticos, não só especificações técnicas
    - Para comparações, indique perfil de cliente ideal para cada modelo
    - Mencione ecossistema quando relevante
    - Respostas concisas (~15 linhas), focadas em ajudar a vender com consultoria
    - Não invente preços — use contexto de estoque quando fornecido
    """

    init() {
        configurarIA()
    }

    func responder(pergunta: String, contexto: ContextoConsultorApple) async -> String {
        let perguntaLimpa = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !perguntaLimpa.isEmpty else {
            return motorLocal.mensagemBoasVindas(modo: contexto.modo)
        }

        let perguntaEnriquecida = enriquecerComContexto(perguntaLimpa, contexto: contexto)

        if iaDisponivel, let chat {
            do {
                let resposta = try await chat.sendMessage(perguntaEnriquecida)
                if let texto = resposta.text?.trimmingCharacters(in: .whitespacesAndNewlines), !texto.isEmpty {
                    return texto
                }
            } catch {
                print("⚠️ Consultor Apple: fallback local — \(error.localizedDescription)")
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

    private func enriquecerComContexto(_ pergunta: String, contexto: ContextoConsultorApple) -> String {
        let modo = contexto.modo == .cliente
            ? "Atendimento para cliente (incluir frases de venda)"
            : "Consulta técnica / dúvida pessoal do consultor"

        var bloco = "[Modo: \(modo)]\n"
        bloco += "[Critérios da loja]\n\(contexto.criterios.blocoPrompt)\n\n"

        let produtos = contexto.produtosEstoque.filter(\.estaNoEstoque)
        let filtrados = contexto.criterios.priorizarLacrado
            ? produtos.sorted { ($0.lacrado ? 0 : 1) < ($1.lacrado ? 0 : 1) }
            : Array(produtos)

        if !filtrados.isEmpty {
            let lista = filtrados.prefix(8).map { produto in
                var linha = "- \(produto.tituloExibicao): \(Formatters.brl(produto.valor))"
                if produto.lacrado { linha += " (lacrado)" }
                return linha
            }.joined(separator: "\n")
            bloco += "[Estoque iStock]\n\(lista)\n\n"
        }

        return bloco + "[Pergunta]\n\(pergunta)"
    }
}
