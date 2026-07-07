//
//  NotificacaoOfertaService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificacaoOfertaService {
    static let shared = NotificacaoOfertaService()

    private init() {}

    func notificarClientesInteressados(por produto: Lancamento) {
        let clientes = ClienteService.shared.clientes.filter {
            $0.ativo && $0.tiposNotificacao.contains(produto.tipoProduto)
        }

        for cliente in clientes {
            enviarNotificacao(cliente: cliente, produto: produto)
        }
    }

    private func enviarNotificacao(cliente: Cliente, produto: Lancamento) {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = "Nova oferta — \(produto.tipoProduto.rawValue)"
        conteudo.body = "\(produto.tituloExibicao) por \(Formatters.brl(produto.valor)). Cliente: \(cliente.nome)"
        conteudo.sound = .default

        let gatilho = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let pedido = UNNotificationRequest(
            identifier: "oferta-\(produto.id ?? UUID().uuidString)-\(cliente.id ?? UUID().uuidString)",
            content: conteudo,
            trigger: gatilho
        )

        UNUserNotificationCenter.current().add(pedido)
    }
}
