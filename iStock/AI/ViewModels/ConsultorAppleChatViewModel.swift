//
//  ConsultorAppleChatViewModel.swift
//  iStock
//

import Foundation
import Combine

@MainActor
final class ConsultorAppleChatViewModel: ObservableObject {
    @Published var mensagens: [MensagemNegociacao] = []
    @Published var processando = false
    @Published var modo: ModoConsultorApple = .cliente

    private let assistente = ConsultorAppleAssistenteService()

    var sugestoes: [SugestaoRapidaConsultor] {
        SugestaoRapidaConsultor.padroes
    }

    func iniciar() {
        guard mensagens.isEmpty else { return }
        mensagens.append(MensagemNegociacao(
            papel: .assistente,
            texto: ConsultorAppleMotorLocal().mensagemBoasVindas(modo: modo)
        ))
    }

    func alterarModo(_ novoModo: ModoConsultorApple) {
        guard modo != novoModo else { return }
        modo = novoModo
        mensagens.append(MensagemNegociacao(
            papel: .assistente,
            texto: "Modo alterado para **\(novoModo.titulo)**. \(ConsultorAppleMotorLocal().mensagemBoasVindas(modo: novoModo))"
        ))
    }

    func enviar(_ texto: String) async {
        let pergunta = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pergunta.isEmpty, !processando else { return }

        mensagens.append(MensagemNegociacao(papel: .usuario, texto: pergunta))
        processando = true

        let contexto = ContextoConsultorApple(
            produtosEstoque: LancamentoService.shared.lancamentos,
            modo: modo
        )
        let resposta = await AssistenteIATiming.aguardarResposta {
            await self.assistente.responder(pergunta: pergunta, contexto: contexto)
        }

        mensagens.append(MensagemNegociacao(papel: .assistente, texto: resposta))
        processando = false
    }

    func usarSugestao(_ sugestao: SugestaoRapidaConsultor) async {
        await enviar(sugestao.texto)
    }

    func limparConversa() {
        mensagens.removeAll()
        assistente.reiniciarConversa()
        iniciar()
    }
}
