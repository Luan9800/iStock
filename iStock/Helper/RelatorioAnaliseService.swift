//
//  RelatorioAnaliseService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum RelatorioAnaliseService {
    static let diasPeriodoRelatorio = 30

    @MainActor
    static func gerar(
        periodoFim: Date = .now,
        lancamentos: [Lancamento]? = nil,
        avaliacoes: [Avaliacao]? = nil
    ) -> RelatorioFinanceiro {
        let lancamentos = lancamentos ?? LancamentoService.shared.lancamentos
        let avaliacoes = avaliacoes ?? AvaliacaoService.shared.avaliacoes
        let calendario = Calendar.current
        let periodoInicio = calendario.date(byAdding: .day, value: -diasPeriodoRelatorio, to: periodoFim) ?? periodoFim

        let vendidosPeriodo = lancamentos.filter { item in
            guard item.status == .vendido, let dataVenda = item.dataVenda else { return false }
            return dataVenda >= periodoInicio && dataVenda <= periodoFim
        }

        let receita = vendidosPeriodo.reduce(0) { $0 + $1.valor }
        let custoVendidos = vendidosPeriodo.compactMap(\.custoCompra).reduce(0, +)

        let despesasAvaliacoes = avaliacoes.filter { item in
            guard item.pagamentoAprovado, let data = item.dataPagamento else { return false }
            return data >= periodoInicio && data <= periodoFim
        }.reduce(0) { $0 + $1.valorCompra }

        let despesasEstoque = lancamentos
            .filter { $0.estaNoEstoque }
            .compactMap(\.custoCompra)
            .reduce(0, +)

        let despesasTotal = despesasAvaliacoes + custoVendidos
        let lucro = receita - despesasTotal

        let noEstoque = lancamentos.filter(\.estaNoEstoque)
        let parados = lancamentos.filter(\.estaHaMuitoTempoNoEstoque)

        var margens: [Double] = []
        for item in vendidosPeriodo {
            if let custo = item.custoCompra, custo > 0 {
                margens.append(((item.valor - custo) / custo) * 100)
            }
        }
        let margemMedia = margens.isEmpty ? nil : margens.reduce(0, +) / Double(margens.count)

        let estoquePorCategoria = TipoProduto.allCases.compactMap { tipo -> (TipoProduto, Int, Double)? in
            let itens = noEstoque.filter { $0.tipoProduto == tipo }
            guard !itens.isEmpty else { return nil }
            return (tipo, itens.count, itens.reduce(0) { $0 + $1.valor })
        }

        let recusasNoPeriodo: [RecusaCompraRegistro] = avaliacoes.compactMap { item in
            guard item.status == .compraRecusada,
                  let data = item.dataRecusa,
                  data >= periodoInicio,
                  data <= periodoFim,
                  let justificativa = item.justificativaRecusa else { return nil }
            return RecusaCompraRegistro(
                id: item.id ?? UUID().uuidString,
                titulo: item.tituloExibicao,
                justificativa: justificativa,
                data: data,
                valorEstimado: item.valorEstimado
            )
        }.sorted { $0.data > $1.data }

        let sugestoes = montarSugestoes(
            receita: receita,
            despesas: despesasTotal,
            lucro: lucro,
            parados: parados.count,
            emAvaliacao: avaliacoes.filter { $0.status == .emAvaliacao }.count,
            avaliadas: avaliacoes.filter { $0.status == .avaliado }.count,
            pagamentosPendentes: avaliacoes.filter { $0.status == .aprovado && !$0.pagamentoAprovado }.count,
            comprasRecusadasPeriodo: recusasNoPeriodo.count,
            margemMedia: margemMedia,
            estoqueVazio: noEstoque.isEmpty
        )

        let valorEstoque = noEstoque.reduce(0) { $0 + $1.valor }
        let custoEstoque = despesasEstoque

        let avaliacoesComValores = avaliacoes.filter {
            $0.valorEstimado != nil
                && $0.status != .emAvaliacao
                && $0.status != .compraRecusada
        }
        let avaliacoesValores: [AvaliacaoValorResumo] = avaliacoesComValores.map { item in
            AvaliacaoValorResumo(
                id: item.id ?? UUID().uuidString,
                titulo: item.tituloExibicao,
                estimativa: item.valorEstimado ?? 0,
                compra: item.valorCompra,
                vendaReal: item.valorVendaReal
            )
        }.sorted { $0.titulo < $1.titulo }

        let estimativaAvaliadas = avaliacoesComValores.reduce(0) { $0 + ($1.valorEstimado ?? 0) }
        let compraAvaliadas = avaliacoesComValores.reduce(0) { $0 + $1.valorCompra }
        let vendaRealAvaliadas = avaliacoesComValores.reduce(0) { $0 + $1.valorVendaExibicao }

        let panorama = PanoramaRelatorio(
            disponiveis: lancamentos.filter { $0.status == .disponivel }.count,
            reservados: lancamentos.filter { $0.status == .reservado }.count,
            vendidosMes: LancamentoService.shared.vendidosNoMes.count,
            receitaMes: LancamentoService.shared.receitaMes,
            receitaHistorica: LancamentoService.shared.receitaTotalVendida,
            comprasAprovadas: AvaliacaoService.shared.totalCompradoAprovado,
            pagamentosAprovados: AvaliacaoService.shared.totalPagamentoAprovado,
            pagamentosPendentesQuantidade: AvaliacaoService.shared.aprovadasSemPagamento.count,
            avaliacoesAprovadas: avaliacoes.filter { $0.status == .aprovado }.count,
            avaliacoesNoEstoque: avaliacoes.filter { $0.status == .noEstoque }.count,
            estimativaAvaliadas: estimativaAvaliadas,
            compraAvaliadas: compraAvaliadas,
            vendaRealAvaliadas: vendaRealAvaliadas,
            margemPotencialEstoque: valorEstoque - custoEstoque,
            comprasRecusadasTotal: avaliacoes.filter { $0.status == .compraRecusada }.count
        )

        return RelatorioFinanceiro(
            periodoInicio: periodoInicio,
            periodoFim: periodoFim,
            receitaTotal: receita,
            despesasTotal: despesasTotal,
            lucroLiquido: lucro,
            itensEstoque: noEstoque.count,
            valorEstoque: valorEstoque,
            custoEstoque: custoEstoque,
            vendasQuantidade: vendidosPeriodo.count,
            produtosParados: parados.count,
            avaliacoesPendentes: avaliacoes.filter { $0.status == .emAvaliacao }.count,
            avaliacoesAvaliadas: avaliacoes.filter { $0.status == .avaliado }.count,
            pagamentosPendentes: avaliacoes.filter { $0.status == .aprovado && !$0.pagamentoAprovado }
                .reduce(0) { $0 + $1.valorCompra },
            margemMediaPercentual: margemMedia,
            sugestoes: sugestoes,
            estoquePorCategoria: estoquePorCategoria,
            panorama: panorama,
            comprasRecusadas: recusasNoPeriodo.count,
            recusasNoPeriodo: recusasNoPeriodo,
            avaliacoesValores: avaliacoesValores
        )
    }

    static func montarSugestoes(
        receita: Double,
        despesas: Double,
        lucro: Double,
        parados: Int,
        emAvaliacao: Int,
        avaliadas: Int,
        pagamentosPendentes: Int,
        comprasRecusadasPeriodo: Int,
        margemMedia: Double?,
        estoqueVazio: Bool
    ) -> [SugestaoPainel] {
        var lista: [SugestaoPainel] = []

        if lucro < 0 {
            lista.append(SugestaoPainel(
                id: "lucro-negativo",
                titulo: "Despesas acima da receita",
                mensagem: "O período fechou com prejuízo de \(Formatters.brl(abs(lucro))). Revise preços de venda e custos de compra.",
                prioridade: .alta
            ))
        }

        if parados > 0 {
            lista.append(SugestaoPainel(
                id: "estoque-parado",
                titulo: "\(parados) produto(s) parado(s)",
                mensagem: "Há itens há mais de \(Lancamento.diasLimiteEstoque) dias sem vender. Considere promoções ou ajuste de preço.",
                prioridade: parados >= 3 ? .alta : .media
            ))
        }

        if emAvaliacao > 0 {
            lista.append(SugestaoPainel(
                id: "avaliacoes-pendentes",
                titulo: "\(emAvaliacao) avaliação(ões) aguardando",
                mensagem: "Conclua as avaliações para não perder oportunidades de compra.",
                prioridade: .media
            ))
        }

        if avaliadas > 0 {
            lista.append(SugestaoPainel(
                id: "avaliacoes-concluidas",
                titulo: "\(avaliadas) avaliado(s) sem aprovação",
                mensagem: "Aprove a compra ou registre o valor real de venda nas avaliações concluídas.",
                prioridade: .media
            ))
        }

        if comprasRecusadasPeriodo > 0 {
            lista.append(SugestaoPainel(
                id: "compras-recusadas",
                titulo: "\(comprasRecusadasPeriodo) compra(s) não aprovada(s)",
                mensagem: "Revise as justificativas registradas e ajuste critérios de precificação se necessário.",
                prioridade: .media
            ))
        }

        if pagamentosPendentes > 0 {
            lista.append(SugestaoPainel(
                id: "pagamentos-pendentes",
                titulo: "Pagamentos pendentes",
                mensagem: "\(pagamentosPendentes) compra(s) aprovada(s) aguardam confirmação de pagamento.",
                prioridade: .alta
            ))
        }

        if let margem = margemMedia, margem < 15 {
            lista.append(SugestaoPainel(
                id: "margem-baixa",
                titulo: "Margem média baixa (\(String(format: "%.0f", margem))%)",
                mensagem: "Aumente a margem mínima ou negocie melhores custos de compra.",
                prioridade: .media
            ))
        }

        if estoqueVazio {
            lista.append(SugestaoPainel(
                id: "estoque-vazio",
                titulo: "Estoque vazio",
                mensagem: "Cadastre novos produtos ou converta avaliações aprovadas em estoque.",
                prioridade: .alta
            ))
        }

        if receita == 0 && !estoqueVazio {
            lista.append(SugestaoPainel(
                id: "sem-vendas",
                titulo: "Nenhuma venda no período",
                mensagem: "Divulgue o estoque, entre em contato com clientes interessados e revise preços.",
                prioridade: .media
            ))
        }

        if lista.isEmpty {
            lista.append(SugestaoPainel(
                id: "tudo-ok",
                titulo: "Operação saudável",
                mensagem: "Indicadores dentro do esperado. Continue monitorando vendas e avaliações.",
                prioridade: .baixa
            ))
        }

        return lista.sorted { $0.prioridade > $1.prioridade }
    }
}
