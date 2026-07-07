//
//  PainelNotificacaoService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class PainelNotificacaoService: ObservableObject {
    static let shared = PainelNotificacaoService()

    @Published private(set) var notificacoes: [NotificacaoPainel] = []
    @Published private(set) var sugestoes: [SugestaoPainel] = []

    private let notificacoesKey = "istock.painel.notificacoes"
    private let emAvaliacaoNotificadosKey = "istock.avaliacao.notif.em"
    private let avaliadoNotificadosKey = "istock.avaliacao.notif.ok"

    private init() {
        carregarNotificacoes()
        atualizarSugestoes()
    }

    var naoLidas: [NotificacaoPainel] {
        notificacoes.filter { !$0.lida }
    }

    func verificarAvaliacoes(_ avaliacoes: [Avaliacao]) {
        for item in avaliacoes where item.status == .emAvaliacao {
            guard let id = item.id, !jaNotificadoEmAvaliacao(id) else { continue }
            adicionar(
                tipo: .emAvaliacao,
                titulo: "Nova avaliação",
                mensagem: "\(item.tituloExibicao) aguarda análise.",
                referenciaId: id
            )
            enviarPush(titulo: "Nova avaliação", corpo: item.tituloExibicao)
            marcarEmAvaliacao(id)
        }

        for item in avaliacoes where item.status == .avaliado {
            guard let id = item.id, !jaNotificadoAvaliado(id) else { continue }
            let valor = Formatters.brl(item.valorEstimado ?? 0)
            adicionar(
                tipo: .avaliado,
                titulo: "Avaliação concluída",
                mensagem: "\(item.tituloExibicao) — estimativa \(valor).",
                referenciaId: id
            )
            enviarPush(titulo: "Avaliação concluída", corpo: "\(item.tituloExibicao): \(valor)")
            marcarAvaliado(id)
        }

        atualizarSugestoes()
    }

    func adicionarRelatorio(_ arquivo: RelatorioArquivo) {
        adicionar(
            tipo: .relatorio,
            titulo: "Relatório mensal gerado",
            mensagem: "PDF disponível na aba Relatórios (\(Formatters.dataCurta.string(from: arquivo.dataGeracao))).",
            referenciaId: arquivo.id
        )
        enviarPush(titulo: "Relatório mensal pronto", corpo: "Confira faturamento, despesas e sugestões.")
    }

    func marcarComoLida(_ id: String) {
        guard let indice = notificacoes.firstIndex(where: { $0.id == id }) else { return }
        notificacoes[indice].lida = true
        persistirNotificacoes()
    }

    func marcarTodasComoLidas() {
        for indice in notificacoes.indices {
            notificacoes[indice].lida = true
        }
        persistirNotificacoes()
    }

    func atualizarSugestoes() {
        sugestoes = RelatorioAnaliseService.gerar().sugestoes
    }

    private func adicionar(tipo: TipoNotificacaoPainel, titulo: String, mensagem: String, referenciaId: String?) {
        let notif = NotificacaoPainel(
            id: UUID().uuidString,
            tipo: tipo,
            titulo: titulo,
            mensagem: mensagem,
            referenciaId: referenciaId,
            data: .now,
            lida: false
        )
        notificacoes.insert(notif, at: 0)
        if notificacoes.count > 50 {
            notificacoes = Array(notificacoes.prefix(50))
        }
        persistirNotificacoes()
    }

    private func enviarPush(titulo: String, corpo: String) {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = titulo
        conteudo.body = corpo
        conteudo.sound = .default

        let gatilho = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let pedido = UNNotificationRequest(
            identifier: "painel-\(UUID().uuidString)",
            content: conteudo,
            trigger: gatilho
        )
        UNUserNotificationCenter.current().add(pedido)
    }

    private func carregarNotificacoes() {
        guard let data = UserDefaults.standard.data(forKey: notificacoesKey),
              let itens = try? JSONDecoder().decode([NotificacaoPainel].self, from: data) else {
            return
        }
        notificacoes = itens
    }

    private func persistirNotificacoes() {
        guard let data = try? JSONEncoder().encode(notificacoes) else { return }
        UserDefaults.standard.set(data, forKey: notificacoesKey)
    }

    private func jaNotificadoEmAvaliacao(_ id: String) -> Bool {
        Set(UserDefaults.standard.stringArray(forKey: emAvaliacaoNotificadosKey) ?? []).contains(id)
    }

    private func marcarEmAvaliacao(_ id: String) {
        var ids = Set(UserDefaults.standard.stringArray(forKey: emAvaliacaoNotificadosKey) ?? [])
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: emAvaliacaoNotificadosKey)
    }

    private func jaNotificadoAvaliado(_ id: String) -> Bool {
        Set(UserDefaults.standard.stringArray(forKey: avaliadoNotificadosKey) ?? []).contains(id)
    }

    private func marcarAvaliado(_ id: String) {
        var ids = Set(UserDefaults.standard.stringArray(forKey: avaliadoNotificadosKey) ?? [])
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: avaliadoNotificadosKey)
    }
}
