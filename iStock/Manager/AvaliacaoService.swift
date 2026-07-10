//
//  AvaliacaoService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class AvaliacaoService: ObservableObject {
    static let shared = AvaliacaoService()

    @Published var avaliacoes: [Avaliacao] = []
    @Published var erro: String?

<<<<<<< HEAD
    private let colecao = Firestore.firestore().collection("avaliacoes")
=======
    private let colecao = FirestoreProvider.db.collection("avaliacoes")
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
    private var listener: ListenerRegistration?

    private init() {}

    var emAvaliacao: [Avaliacao] {
        avaliacoes.filter { $0.status == .emAvaliacao }
    }

    var avaliadas: [Avaliacao] {
        avaliacoes.filter { $0.status == .avaliado }
    }

    var comprasRecusadas: [Avaliacao] {
        avaliacoes.filter { $0.status == .compraRecusada }
    }

    var aprovadas: [Avaliacao] {
        avaliacoes.filter { $0.status == .aprovado }
    }

    var aprovadasSemPagamento: [Avaliacao] {
        aprovadas.filter { !$0.pagamentoAprovado }
    }

    var comPagamentoAprovado: [Avaliacao] {
        avaliacoes.filter { $0.pagamentoAprovado }
    }

    var totalCompradoAprovado: Double {
        aprovadas.reduce(0) { $0 + $1.valorCompra }
    }

    var totalPagamentoPendente: Double {
        aprovadasSemPagamento.reduce(0) { $0 + $1.valorCompra }
    }

    var totalPagamentoAprovado: Double {
        comPagamentoAprovado.reduce(0) { $0 + $1.valorCompra }
    }

    var avaliadasComEstimativa: [Avaliacao] {
        avaliacoes.filter { $0.status == .avaliado && $0.valorEstimado != nil }
    }

    var totalEstimadoAvaliadas: Double {
        avaliadasComEstimativa.reduce(0) { $0 + ($1.valorEstimado ?? 0) }
    }

    var totalVendaRealAvaliadas: Double {
        avaliadasComEstimativa.reduce(0) { $0 + $1.valorVendaExibicao }
    }

    var totalCompraAvaliadas: Double {
        avaliadasComEstimativa.reduce(0) { $0 + $1.valorCompra }
    }

    var avaliacoesComValores: [Avaliacao] {
        avaliacoes.filter {
            $0.valorEstimado != nil
                && $0.status != .emAvaliacao
                && $0.status != .compraRecusada
        }
    }

    func iniciarListener() {
        guard listener == nil else { return }

        listener = colecao.order(by: "data", descending: true)
            .addSnapshotListener { [weak self] resultado, erro in
                Task { @MainActor in
                    guard let self else { return }
                    if let erro {
<<<<<<< HEAD
                        self.erro = erro.localizedDescription
                        return
                    }
                    self.erro = nil
                    self.avaliacoes = resultado?.documents.compactMap {
                        try? $0.data(as: Avaliacao.self)
=======
                        self.erro = FirebaseErrorHelper.mensagem(erro)
                        FirebaseSyncCoordinator.shared.registrarErroPermissao(erro)
                        return
                    }
                    self.erro = nil
                    self.avaliacoes = resultado?.documents.compactMap { doc in
                        do {
                            return try doc.data(as: Avaliacao.self)
                        } catch {
                            print("⚠️ Falha ao decodificar avaliação \(doc.documentID): \(error.localizedDescription)")
                            return nil
                        }
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
                    } ?? []
                    PainelNotificacaoService.shared.verificarAvaliacoes(self.avaliacoes)
                    RelatorioMensalService.shared.atualizarRelatorioAtual()
                }
            }
    }

    func carregarLocal() {
        pararListener(mantendoDados: false)
        avaliacoes = LocalAvaliacaoStore.shared.carregar()
        PainelNotificacaoService.shared.verificarAvaliacoes(avaliacoes)
        RelatorioMensalService.shared.atualizarRelatorioAtual()
    }

    func pararListener(mantendoDados: Bool = false) {
        listener?.remove()
        listener = nil
        if !mantendoDados { avaliacoes = [] }
        erro = nil
    }

    @discardableResult
    func salvar(_ item: Avaliacao) -> Bool {
        salvarRetornandoID(item) != nil
    }

    func salvarRetornandoID(_ item: Avaliacao) -> String? {
        var preparado = item
        preparado.problemasModelo = problemasPara(preparado)
        if AuthService.shared.usandoLoginLocal { return salvarLocalRetornandoID(preparado) }
        return salvarNuvemRetornandoID(preparado)
    }

    @discardableResult
    func atualizar(_ item: Avaliacao) -> Bool {
        if AuthService.shared.usandoLoginLocal { return atualizarLocal(item) }
        return atualizarNuvem(item)
    }

    func remover(_ item: Avaliacao) {
        if AuthService.shared.usandoLoginLocal {
            removerLocal(item)
        } else {
            guard let id = item.id else { return }
            colecao.document(id).delete()
        }
    }

    @discardableResult
    func removerComAutorizacaoAdmin(_ item: Avaliacao, senha: String, confirmacaoSenha: String?) -> Bool {
        let resultado = AdminService.shared.autorizar(senha, confirmacao: confirmacaoSenha)
        switch resultado {
        case .failure(let erro):
<<<<<<< HEAD
            self.erro = erro.localizedDescription
=======
            self.erro = FirebaseErrorHelper.mensagem(erro)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return false
        case .success:
            break
        }

        let titulo = item.tituloExibicao
        remover(item)
        TransacaoLogService.shared.registrar(
            tipo: .avaliacaoExcluida,
            titulo: "Avaliação excluída: \(titulo)",
            detalhes: "Exclusão autorizada por administrador.",
            valor: item.valorVendaExibicao,
            referenciaId: item.id
        )
        erro = nil
        return true
    }

    @discardableResult
    func registrarValorVendaReal(_ item: Avaliacao, valor: Double) -> Bool {
        guard valor > 0 else {
            erro = "Informe um valor de venda válido."
            return false
        }

        var atualizado = item
        let estimativa = item.valorEstimado
        let compra = item.valorCompra
        let anterior = item.valorVendaReal ?? item.valorEstimado
        atualizado.valorVendaReal = valor
        atualizado.dataVendaReal = .now

        guard atualizar(atualizado) else { return false }

        var detalhes = [
            estimativa.map { "Estimativa: \(Formatters.brl($0))" },
            compra > 0 ? "Compra: \(Formatters.brl(compra))" : nil,
            "Real: \(Formatters.brl(valor))"
        ].compactMap { $0 }.joined(separator: " · ")

        if valor == compra && compra > 0 {
            detalhes += " (confirmado no valor da compra)"
        } else if let estimativa, abs(valor - estimativa) < 0.01 {
            detalhes += " (confirmado no valor sugerido)"
        }

        TransacaoLogService.shared.registrar(
            tipo: .valorVendaAtualizado,
            titulo: "Venda real: \(item.tituloExibicao)",
            detalhes: detalhes,
            valor: valor,
            valorAnterior: anterior,
            referenciaId: item.id
        )
        return true
    }

    @discardableResult
    func executarAvaliacao(_ item: Avaliacao) -> Bool {
        guard item.status == .emAvaliacao else { return false }
        let resultado = AvaliacaoPrecificador.estimar(item)

        var atualizado = item
        atualizado.status = .avaliado
        atualizado.valorEstimado = resultado.valorVenda
        atualizado.valorCompraSugerido = resultado.valorCompra
        atualizado.dataAvaliacao = .now
        atualizado.problemasModelo = problemasPara(atualizado)
        let nota = resultado.detalhes
        if let obs = item.observacoes, !obs.isEmpty {
            atualizado.observacoes = obs + "\n" + nota
        } else {
            atualizado.observacoes = nota
        }

        guard atualizar(atualizado) else { return false }
        TransacaoLogService.shared.registrar(
            tipo: .avaliacaoConcluida,
            titulo: "Avaliação: \(item.tituloExibicao)",
            detalhes: "Estimativa de venda registrada.",
            valor: resultado.valorVenda,
            valorAnterior: nil,
            referenciaId: atualizado.id
        )
        return true
    }

    @discardableResult
    func aprovarCompra(_ item: Avaliacao) -> Bool {
        guard item.status == .avaliado else { return false }

        var atualizado = item
        atualizado.status = .aprovado
        atualizado.dataAprovacao = .now
        guard atualizar(atualizado) else { return false }
        TransacaoLogService.shared.registrar(
            tipo: .compraAprovada,
            titulo: "Compra aprovada: \(item.tituloExibicao)",
            valor: item.valorCompra,
            referenciaId: item.id
        )
        return true
    }

    @discardableResult
    func recusarCompra(_ item: Avaliacao, justificativa: String) -> Bool {
        let texto = justificativa.trimmingCharacters(in: .whitespacesAndNewlines)
        guard item.status == .avaliado else { return false }
        guard !texto.isEmpty else {
            erro = "Informe a justificativa para não aprovar a compra."
            return false
        }

        var atualizado = item
        atualizado.status = .compraRecusada
        atualizado.justificativaRecusa = texto
        atualizado.dataRecusa = .now
        guard atualizar(atualizado) else { return false }

        TransacaoLogService.shared.registrar(
            tipo: .compraRecusada,
            titulo: "Compra não aprovada: \(item.tituloExibicao)",
            detalhes: texto,
            valor: item.valorCompra,
            referenciaId: item.id
        )
        erro = nil
        return true
    }

    @discardableResult
    func aprovarPagamento(_ item: Avaliacao) -> Bool {
        guard item.status == .aprovado, !item.pagamentoAprovado else { return false }

        var atualizado = item
        atualizado.pagamentoAprovado = true
        atualizado.dataPagamento = .now
        guard atualizar(atualizado) else { return false }
        TransacaoLogService.shared.registrar(
            tipo: .pagamentoAprovado,
            titulo: "Pagamento aprovado: \(item.tituloExibicao)",
            valor: item.valorCompra,
            referenciaId: item.id
        )
        return true
    }

    @discardableResult
    func registrarRetirada(
        _ item: Avaliacao,
        nomeRecebedor: String,
        documentoRecebedor: String?,
        observacoes: String?,
        fotoData: Data?
    ) async -> Bool {
        let nome = nomeRecebedor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard item.status == .aprovado else { return false }
        guard item.retirada == nil else {
            erro = "A retirada deste produto já foi registrada."
            return false
        }
        guard !nome.isEmpty else {
            erro = "Informe quem recebeu o produto."
            return false
        }

        var fotoSalva: FotoAvaliacao?
        if let fotoData, let id = item.id {
            fotoSalva = await adicionarFotoRetirada(fotoData, avaliacaoId: id)
        }

        let documento = documentoRecebedor?.trimmingCharacters(in: .whitespacesAndNewlines)
        let observacoesLimpa = observacoes?.trimmingCharacters(in: .whitespacesAndNewlines)

        var atualizado = item
        atualizado.retirada = RetiradaProduto(
            nomeRecebedor: nome,
            documentoRecebedor: documento?.isEmpty == false ? documento : nil,
            observacoes: observacoesLimpa?.isEmpty == false ? observacoesLimpa : nil,
            foto: fotoSalva,
            data: .now,
            registradoPor: AuthService.shared.nomeOuEmail
        )
        guard atualizar(atualizado) else { return false }

        var detalhes = "Recebido por \(nome)"
        if let documento = atualizado.retirada?.documentoRecebedor {
            detalhes += " · Doc. \(documento)"
        }
        if fotoSalva != nil {
            detalhes += " · Com foto"
        }

        TransacaoLogService.shared.registrar(
            tipo: .retiradaRegistrada,
            titulo: "Retirada: \(item.tituloExibicao)",
            detalhes: detalhes,
            referenciaId: item.id
        )
        erro = nil
        return true
    }

    @discardableResult
    func converterParaEstoque(_ item: Avaliacao) -> Bool {
        guard item.status == .aprovado, item.pagamentoAprovado else {
            if item.status == .aprovado && !item.pagamentoAprovado {
                erro = "Aprove o pagamento antes de adicionar ao estoque."
            }
            return false
        }

        guard item.retirada != nil else {
            erro = "Registre a retirada do produto antes de adicionar ao estoque."
            return false
        }

        let valorVenda = item.valorVendaReal ?? item.valorEstimado ?? 0
        guard valorVenda > 0 else {
            erro = "Informe o valor de venda antes de adicionar ao estoque."
            return false
        }

        var lancamento = item.paraLancamento(valorVenda: valorVenda)
        if AuthService.shared.usandoLoginLocal {
            lancamento.id = UUID().uuidString
        }

        guard let lancamentoId = LancamentoService.shared.salvarRetornandoID(lancamento) else {
            erro = LancamentoService.shared.erro ?? "Não foi possível adicionar ao estoque."
            return false
        }

        var atualizado = item
        atualizado.status = .noEstoque
        atualizado.lancamentoId = lancamentoId
        guard atualizar(atualizado) else { return false }

        TransacaoLogService.shared.registrar(
            tipo: .adicionadoEstoque,
            titulo: "No estoque: \(item.tituloExibicao)",
            valor: valorVenda,
            referenciaId: lancamentoId
        )
        return true
    }

    func adicionarFoto(_ data: Data, avaliacaoId: String) async -> FotoAvaliacao? {
        let comprimida = ImageCompressor.compressJPEG(data) ?? data

        if AuthService.shared.usandoLoginLocal {
            return salvarFotoLocal(comprimida, avaliacaoId: avaliacaoId, subpasta: nil)
        }

        let path = "avaliacoes/\(avaliacaoId)/\(UUID().uuidString).jpg"
        do {
            let url = try await ImageStorageService.shared.upload(data: comprimida, path: path)
            return FotoAvaliacao(url: url.absoluteString, path: path)
        } catch {
<<<<<<< HEAD
            self.erro = error.localizedDescription
=======
            self.erro = FirebaseErrorHelper.mensagem(error)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return nil
        }
    }

    func adicionarFotoRetirada(_ data: Data, avaliacaoId: String) async -> FotoAvaliacao? {
        let comprimida = ImageCompressor.compressJPEG(data) ?? data

        if AuthService.shared.usandoLoginLocal {
            return salvarFotoLocal(comprimida, avaliacaoId: avaliacaoId, subpasta: "retirada")
        }

        let path = "avaliacoes/\(avaliacaoId)/retirada/\(UUID().uuidString).jpg"
        do {
            let url = try await ImageStorageService.shared.upload(data: comprimida, path: path)
            return FotoAvaliacao(url: url.absoluteString, path: path)
        } catch {
<<<<<<< HEAD
            self.erro = error.localizedDescription
=======
            self.erro = FirebaseErrorHelper.mensagem(error)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return nil
        }
    }

    // MARK: - Nuvem

    @discardableResult
    private func salvarNuvem(_ item: Avaliacao) -> Bool {
        salvarNuvemRetornandoID(item) != nil
    }

    @discardableResult
    private func salvarNuvemRetornandoID(_ item: Avaliacao) -> String? {
        guard Auth.auth().currentUser != nil else {
            erro = "Faça login na aba Nuvem para salvar na nuvem."
            return nil
        }
        do {
            let ref = try colecao.addDocument(from: item)
            erro = nil
            TransacaoLogService.shared.registrar(
                tipo: .avaliacaoCriada,
                titulo: "Nova avaliação: \(item.tituloExibicao)",
                referenciaId: ref.documentID
            )
            return ref.documentID
        } catch {
<<<<<<< HEAD
            erro = error.localizedDescription
=======
            erro = FirebaseErrorHelper.mensagem(error)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return nil
        }
    }

    @discardableResult
    private func atualizarNuvem(_ item: Avaliacao) -> Bool {
        guard Auth.auth().currentUser != nil, let id = item.id else {
            erro = "Avaliação sem identificador."
            return false
        }
        do {
            try colecao.document(id).setData(from: item)
            erro = nil
            return true
        } catch {
<<<<<<< HEAD
            erro = error.localizedDescription
=======
            erro = FirebaseErrorHelper.mensagem(error)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return false
        }
    }

    // MARK: - Local

    @discardableResult
    private func salvarLocal(_ item: Avaliacao) -> Bool {
        salvarLocalRetornandoID(item) != nil
    }

    func salvarLocalRetornandoID(_ item: Avaliacao) -> String? {
        var novo = item
        if novo.id == nil { novo.id = UUID().uuidString }
        avaliacoes.insert(novo, at: 0)
        persistirLocal()
        erro = nil
        TransacaoLogService.shared.registrar(
            tipo: .avaliacaoCriada,
            titulo: "Nova avaliação: \(novo.tituloExibicao)",
            referenciaId: novo.id
        )
        return novo.id
    }

    private func atualizarLocal(_ item: Avaliacao) -> Bool {
        guard let id = item.id,
              let indice = avaliacoes.firstIndex(where: { $0.id == id }) else {
            erro = "Avaliação não encontrada."
            return false
        }
        avaliacoes[indice] = item
        persistirLocal()
        erro = nil
        return true
    }

    private func removerLocal(_ item: Avaliacao) {
        guard let id = item.id else { return }
        avaliacoes.removeAll { $0.id == id }
        persistirLocal()
    }

    private func persistirLocal() {
        LocalAvaliacaoStore.shared.salvar(avaliacoes)
    }

    private func problemasPara(_ item: Avaliacao) -> [ProblemaModelo] {
        ModeloDefeitosService.buscar(tipo: item.tipoProduto, modelo: item.modelo)
    }

    private func salvarFotoLocal(_ data: Data, avaliacaoId: String, subpasta: String?) -> FotoAvaliacao? {
        var diretorio = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avaliacoes/\(avaliacaoId)", isDirectory: true)
        if let subpasta {
            diretorio = diretorio.appendingPathComponent(subpasta, isDirectory: true)
        }

        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let nome = "\(UUID().uuidString).jpg"
            let arquivo = diretorio.appendingPathComponent(nome)
            try data.write(to: arquivo)
            return FotoAvaliacao(url: arquivo.absoluteString, path: arquivo.path)
        } catch {
<<<<<<< HEAD
            self.erro = error.localizedDescription
=======
            self.erro = FirebaseErrorHelper.mensagem(error)
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
            return nil
        }
    }
}
