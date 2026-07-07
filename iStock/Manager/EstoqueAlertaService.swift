//
//  EstoqueAlertaService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class EstoqueAlertaService: ObservableObject {
    static let shared = EstoqueAlertaService()

    @Published private(set) var permissaoConcedida = false

    private let notificadosKey = "istock.produtos.estoque.notificados"

    private init() {}

    func solicitarPermissao() async {
        let center = UNUserNotificationCenter.current()
        do {
            permissaoConcedida = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            permissaoConcedida = false
        }
    }

    func verificarEstoque(_ lancamentos: [Lancamento]) {
        let parados = lancamentos.filter(\.estaHaMuitoTempoNoEstoque)

        for item in parados {
            guard let id = item.id, !jaNotificado(id) else { continue }
            enviarNotificacao(para: item)
            marcarNotificado(id)
        }
    }

    private func enviarNotificacao(para item: Lancamento) {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = "Alerta de estoque"
        conteudo.body = "\(item.nome) está há \(item.diasNoEstoque) dias no estoque."
        conteudo.sound = .default

        let gatilho = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let pedido = UNNotificationRequest(
            identifier: "estoque-\(item.id ?? UUID().uuidString)",
            content: conteudo,
            trigger: gatilho
        )

        UNUserNotificationCenter.current().add(pedido)
    }

    private func jaNotificado(_ id: String) -> Bool {
        idsNotificados().contains(id)
    }

    private func marcarNotificado(_ id: String) {
        var ids = idsNotificados()
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: notificadosKey)
    }

    private func idsNotificados() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: notificadosKey) ?? [])
    }
}
