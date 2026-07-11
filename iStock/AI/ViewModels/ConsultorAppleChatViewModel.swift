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

    func iniciar() {
        guard mensagens.isEmpty else { return }
        mensagens.append(MensagemNegociacao(
            papel: .assistente,
            texto: ConsultorAppleMotorLocal().mensagemBoasVindas(modo: modo)
        ))
    }

    func enviar(_ texto: String) async {
        let pergunta = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pergunta.isEmpty, !processando else { return }

        mensagens.append(MensagemNegociacao(papel: .usuario, texto: pergunta))
        processando = true

        let contexto = ContextoConsultorApple(
            produtosEstoque: LancamentoService.shared.lancamentos,
            modo: modo,
            criterios: CriteriosAssistenteStore.shared.criterios
        )
        let resposta = await AssistenteIATiming.aguardarResposta {
            await self.assistente.responder(pergunta: pergunta, contexto: contexto)
        }

        mensagens.append(MensagemNegociacao(papel: .assistente, texto: resposta))
        processando = false
    }

    func limparConversa() {
        mensagens.removeAll()
        assistente.reiniciarConversa()
        iniciar()
    }
}
