//
//  LancamentoService.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import SwiftUI
import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class LancamentoService: ObservableObject {
    static let shared = LancamentoService()

    @Published var lancamentos: [Lancamento] = []
    @Published var erro: String?

    private let colecao = FirestoreProvider.db.collection("lancamentos")
    private var listener: ListenerRegistration?
    private var modoLocal = false

    private init() {}

    // MARK: - Carregamento

    func iniciarListener() {
        guard listener == nil else { return }
        modoLocal = false

        listener = colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
                        self.erro = FirebaseErrorHelper.mensagem(erro)
                        FirebaseSyncCoordinator.shared.registrarErroPermissao(erro)
                        return
                    }
                    self.erro = nil
                    self.lancamentos = resultado?.documents.compactMap {
                        try? $0.data(as: Lancamento.self)
                    } ?? []
                    EstoqueAlertaService.shared.verificarEstoque(self.lancamentos)
                }
            }
    }

    func carregarLocal() {
        pararListener(mantendoDados: false)
        modoLocal = true
        lancamentos = LocalInventoryStore.shared.carregar()
        EstoqueAlertaService.shared.verificarEstoque(lancamentos)
    }

    func pararListener(mantendoDados: Bool = false) {
        listener?.remove()
        listener = nil
        if !mantendoDados {
            lancamentos = []
        }
        erro = nil
        modoLocal = false
    }

    // MARK: - Estatísticas

    var disponiveis: [Lancamento] {
        lancamentos.filter { $0.status == .disponivel }
    }

    var reservados: [Lancamento] {
        lancamentos.filter { $0.status == .reservado }
    }

    var vendidos: [Lancamento] {
        lancamentos.filter { $0.status == .vendido }
    }

    var noEstoque: [Lancamento] {
        lancamentos.filter(\.estaNoEstoque)
    }

    var paradosNoEstoque: [Lancamento] {
        lancamentos.filter(\.estaHaMuitoTempoNoEstoque)
    }

    var valorTotalEstoque: Double {
        noEstoque.reduce(0) { $0 + $1.valor }
    }

    var vendidosNoMes: [Lancamento] {
        let calendario = Calendar.current
        return vendidos.filter { item in
            guard let dataVenda = item.dataVenda else { return false }
            return calendario.isDate(dataVenda, equalTo: .now, toGranularity: .month)
        }
    }

    var receitaMes: Double {
        vendidosNoMes.reduce(0) { $0 + $1.valor }
    }

    var receitaTotalVendida: Double {
        vendidos.reduce(0) { $0 + $1.valor }
    }

    var custoTotalEstoque: Double {
        noEstoque.compactMap(\.custoCompra).reduce(0, +)
    }

    var custoTotalComprado: Double {
        lancamentos.compactMap(\.custoCompra).reduce(0, +)
    }

    func contagem(por tipo: TipoProduto) -> Int {
        noEstoque.filter { $0.tipoProduto == tipo }.count
    }

    // MARK: - CRUD

    @discardableResult
    func salvar(_ item: Lancamento) -> Bool {
        salvarRetornandoID(item) != nil
    }

    func salvarRetornandoID(_ item: Lancamento) -> String? {
        var preparado = item
        if preparado.problemasModelo == nil || preparado.problemasModelo?.isEmpty == true {
            preparado.problemasModelo = ModeloDefeitosService.buscar(
                tipo: preparado.tipoProduto,
                modelo: preparado.modelo
            )
        }
        if AuthService.shared.usandoLoginLocal {
            return salvarLocalRetornandoID(preparado)
        }
        return salvarNuvemRetornandoID(preparado)
    }

    @discardableResult
    func atualizar(_ item: Lancamento) -> Bool {
        if AuthService.shared.usandoLoginLocal {
            return atualizarLocal(item)
        }
        return atualizarNuvem(item)
    }

    func remover(_ item: Lancamento) {
        if AuthService.shared.usandoLoginLocal {
            removerLocal(item)
        } else {
            removerNuvem(item)
        }
    }

    @discardableResult
    func marcarReservado(_ item: Lancamento) -> Bool {
        var atualizado = item
        atualizado.status = .reservado
        return atualizar(atualizado)
    }

    @discardableResult
    func liberarReserva(_ item: Lancamento) -> Bool {
        var atualizado = item
        atualizado.status = .disponivel
        return atualizar(atualizado)
    }

    @discardableResult
    func marcarVendido(_ item: Lancamento, cliente: Cliente?, valorVenda: Double?) -> Bool {
        var atualizado = item
        atualizado.status = .vendido
        atualizado.dataVenda = .now
        atualizado.clienteVendaId = cliente?.id
        atualizado.clienteVendaNome = cliente?.nome
        if let valorVenda { atualizado.valor = valorVenda }
        let ok = atualizar(atualizado)
        if ok {
            TransacaoLogService.shared.registrar(
                tipo: .vendaProduto,
                titulo: "Venda: \(item.tituloExibicao)",
                detalhes: cliente.map { "Cliente: \($0.nome)" },
                valor: atualizado.valor,
                referenciaId: item.id
            )
        }
        return ok
    }

    // MARK: - Nuvem

    @discardableResult
    private func salvarNuvem(_ item: Lancamento) -> Bool {
        salvarNuvemRetornandoID(item) != nil
    }

    private func salvarNuvemRetornandoID(_ item: Lancamento) -> String? {
        guard Auth.auth().currentUser != nil else {
            erro = "Faça login na aba Nuvem para salvar na nuvem."
            return nil
        }

        do {
            if let id = item.id, !id.isEmpty {
                try colecao.document(id).setData(from: item)
                erro = nil
                NotificacaoOfertaService.shared.notificarClientesInteressados(por: item)
                return id
            }

            let ref = try colecao.addDocument(from: item)
            erro = nil
            NotificacaoOfertaService.shared.notificarClientesInteressados(por: item)
            return ref.documentID
        } catch {
            erro = FirebaseErrorHelper.mensagem(error)
            return nil
        }
    }

    @discardableResult
    private func atualizarNuvem(_ item: Lancamento) -> Bool {
        guard Auth.auth().currentUser != nil, let id = item.id else {
            erro = "Produto sem identificador."
            return false
        }

        do {
            try colecao.document(id).setData(from: item)
            erro = nil
            return true
        } catch {
            erro = FirebaseErrorHelper.mensagem(error)
            return false
        }
    }

    private func removerNuvem(_ item: Lancamento) {
        guard let id = item.id else { return }
        colecao.document(id).delete()
    }

    // MARK: - Local

    @discardableResult
    private func salvarLocal(_ item: Lancamento) -> Bool {
        salvarLocalRetornandoID(item) != nil
    }

    private func salvarLocalRetornandoID(_ item: Lancamento) -> String? {
        var novo = item
        if novo.id == nil { novo.id = UUID().uuidString }
        lancamentos.insert(novo, at: 0)
        persistirLocal()
        NotificacaoOfertaService.shared.notificarClientesInteressados(por: novo)
        EstoqueAlertaService.shared.verificarEstoque(lancamentos)
        erro = nil
        return novo.id
    }

    @discardableResult
    private func atualizarLocal(_ item: Lancamento) -> Bool {
        guard let id = item.id,
              let indice = lancamentos.firstIndex(where: { $0.id == id }) else {
            erro = "Produto não encontrado."
            return false
        }
        lancamentos[indice] = item
        persistirLocal()
        EstoqueAlertaService.shared.verificarEstoque(lancamentos)
        erro = nil
        return true
    }

    private func removerLocal(_ item: Lancamento) {
        guard let id = item.id else { return }
        lancamentos.removeAll { $0.id == id }
        persistirLocal()
    }

    private func persistirLocal() {
        LocalInventoryStore.shared.salvar(lancamentos)
    }
}
