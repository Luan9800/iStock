//
//  NegociacaoChatViewModel.swift
//  iStock
//

import Foundation
import Combine

@MainActor
final class NegociacaoChatViewModel: ObservableObject {
    @Published var mensagens: [MensagemNegociacao] = []
    @Published var processando = false

    private let assistente = NegociacaoAssistenteService()

    func iniciar() {
        guard mensagens.isEmpty else { return }
        mensagens.append(MensagemNegociacao(
            papel: .assistente,
            texto: NegociacaoMotorLocal().mensagemBoasVindas()
        ))
    }

    func enviar(_ texto: String) async {
        let pergunta = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pergunta.isEmpty, !processando else { return }

        mensagens.append(MensagemNegociacao(papel: .usuario, texto: pergunta))
        processando = true

        let contexto = ContextoNegociacao(
            produtosEstoque: LancamentoService.shared.lancamentos,
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
