//
//  RelatorioPDFGerador.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import CoreGraphics
import CoreText
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum RelatorioPDFGerador {
    private static let larguraPagina: CGFloat = 595
    private static let alturaPagina: CGFloat = 842
    private static let margem: CGFloat = 48
    private static let alturaRodape: CGFloat = 36
    private static let alturaCabecalho: CGFloat = 96

    private static let azulPrimario = CGColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1)
    private static let azulEscuro = CGColor(red: 0.0, green: 0.318, blue: 0.835, alpha: 1)
    private static let textoEscuro = CGColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    private static let textoCinza = CGColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 1)

    // MARK: - Tipografia Apple (SF Pro / SF Rounded / SF Mono)

    private enum PDFFonteApple {
        enum Peso {
            case regular, medium, semibold, bold
        }

        enum Familia {
            case texto
            case display
            case arredondada
            case mono
        }

        private static func plataforma(tamanho: CGFloat, peso: Peso = .regular, familia: Familia = .texto) -> PlatformFont {
            let weight = pesoPlataforma(peso)
            switch familia {
            case .arredondada:
                return fonteArredondada(tamanho: tamanho, peso: weight)
            case .mono:
                return fonteMono(tamanho: tamanho, peso: weight)
            case .display:
                return fonteDisplay(tamanho: tamanho, peso: weight)
            case .texto:
                return fonteTexto(tamanho: tamanho, peso: weight)
            }
        }

        static func ctFont(tamanho: CGFloat, peso: Peso = .regular, familia: Familia = .texto) -> CTFont {
            let font = plataforma(tamanho: tamanho, peso: peso, familia: familia)
            return CTFontCreateWithFontDescriptor(font.fontDescriptor as CTFontDescriptor, tamanho, nil)
        }

        static func atributos(
            tamanho: CGFloat,
            peso: Peso = .regular,
            familia: Familia = .texto,
            cor: CGColor,
            kern: CGFloat = 0
        ) -> [NSAttributedString.Key: Any] {
            var attrs: [NSAttributedString.Key: Any] = [
                .font: plataforma(tamanho: tamanho, peso: peso, familia: familia),
                .foregroundColor: corPlataforma(cgColor: cor)
            ]
            if kern != 0 {
                attrs[.kern] = kern
            }
            return attrs
        }

        #if os(macOS)
        private typealias PlatformFont = NSFont

        private static func pesoPlataforma(_ peso: Peso) -> NSFont.Weight {
            switch peso {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }

        private static func fonteTexto(tamanho: CGFloat, peso: NSFont.Weight) -> NSFont {
            NSFont.systemFont(ofSize: tamanho, weight: peso)
        }

        private static func fonteDisplay(tamanho: CGFloat, peso: NSFont.Weight) -> NSFont {
            if let descriptor = NSFont.systemFont(ofSize: tamanho, weight: peso).fontDescriptor.withDesign(.default) {
                return NSFont(descriptor: descriptor, size: tamanho) ?? NSFont.systemFont(ofSize: tamanho, weight: peso)
            }
            return NSFont.systemFont(ofSize: tamanho, weight: peso)
        }

        private static func fonteArredondada(tamanho: CGFloat, peso: NSFont.Weight) -> NSFont {
            let base = NSFont.systemFont(ofSize: tamanho, weight: peso)
            if let rounded = base.fontDescriptor.withDesign(.rounded) {
                return NSFont(descriptor: rounded, size: tamanho) ?? base
            }
            return base
        }

        private static func fonteMono(tamanho: CGFloat, peso: NSFont.Weight) -> NSFont {
            NSFont.monospacedDigitSystemFont(ofSize: tamanho, weight: peso)
        }
        #else
        private typealias PlatformFont = UIFont

        private static func pesoPlataforma(_ peso: Peso) -> UIFont.Weight {
            switch peso {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }

        private static func fonteTexto(tamanho: CGFloat, peso: UIFont.Weight) -> UIFont {
            UIFont.systemFont(ofSize: tamanho, weight: peso)
        }

        private static func fonteDisplay(tamanho: CGFloat, peso: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: tamanho, weight: peso)
            if let descriptor = base.fontDescriptor.withDesign(.default) {
                return UIFont(descriptor: descriptor, size: tamanho)
            }
            return base
        }

        private static func fonteArredondada(tamanho: CGFloat, peso: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: tamanho, weight: peso)
            if let rounded = base.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: rounded, size: tamanho)
            }
            return base
        }

        private static func fonteMono(tamanho: CGFloat, peso: UIFont.Weight) -> UIFont {
            UIFont.monospacedDigitSystemFont(ofSize: tamanho, weight: peso)
        }
        #endif
    }

    private static let corReceita = CGColor(red: 0.18, green: 0.78, blue: 0.44, alpha: 1)
    private static let corDespesa = CGColor(red: 1.0, green: 0.58, blue: 0.2, alpha: 1)
    private static let corLucro = CGColor(red: 0.0, green: 0.62, blue: 0.95, alpha: 1)
    private static let corAlerta = CGColor(red: 0.95, green: 0.3, blue: 0.28, alpha: 1)
    private static let corFundoSecao = CGColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
    private static let corBordaSecao = CGColor(red: 0.88, green: 0.89, blue: 0.92, alpha: 1)

    private static let paletaGrafico: [CGColor] = [
        azulPrimario,
        corReceita,
        corDespesa,
        CGColor(red: 0.55, green: 0.45, blue: 0.95, alpha: 1),
        CGColor(red: 0.95, green: 0.75, blue: 0.2, alpha: 1),
        corLucro
    ]

    static func gerar(_ relatorio: RelatorioFinanceiro) -> Data? {
        var mediaBox = CGRect(x: 0, y: 0, width: larguraPagina, height: alturaPagina)
        let pdfData = NSMutableData()

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        let pagina = PaginaPDF(context: context, relatorio: relatorio)
        pagina.iniciar()
        pagina.desenharCabecalho()
        pagina.avancar(16)

        // MARK: Seção 1 — Panorama
        pagina.iniciarSecao(1, titulo: "Panorama Geral", subtitulo: "Visão consolidada do inventário Apple")
        pagina.desenharCardsMetricas([
            ("Receita histórica", Formatters.brl(relatorio.panorama.receitaHistorica), corReceita),
            ("Em estoque", Formatters.brl(relatorio.valorEstoque), azulPrimario),
            ("Itens ativos", "\(relatorio.itensEstoque)", corLucro)
        ])
        pagina.desenharGraficoComparativoReceita(
            mes: relatorio.panorama.receitaMes,
            historico: relatorio.panorama.receitaHistorica
        )
        pagina.desenharLinha("Receita do mês", Formatters.brl(relatorio.panorama.receitaMes))
        pagina.desenharLinha("Vendas no mês", "\(relatorio.panorama.vendidosMes)")
        pagina.desenharLinha("Custo em estoque", Formatters.brl(relatorio.custoEstoque))
        pagina.desenharLinha("Margem potencial", Formatters.brl(relatorio.panorama.margemPotencialEstoque))
        pagina.desenharLinha("Disponíveis / Reservados", "\(relatorio.panorama.disponiveis) / \(relatorio.panorama.reservados)")
        pagina.desenharLinha("Produtos parados (+30 dias)", "\(relatorio.produtosParados)")
        pagina.finalizarSecao()

        // MARK: Seção 2 — Financeiro
        pagina.iniciarSecao(
            2,
            titulo: "Financeiro do Período",
            subtitulo: "\(RelatorioAnaliseService.diasPeriodoRelatorio) dias · \(Formatters.dataCurta.string(from: relatorio.periodoInicio)) a \(Formatters.dataCurta.string(from: relatorio.periodoFim))"
        )
        pagina.desenharGraficoBarrasFinanceiro(
            receita: relatorio.receitaTotal,
            despesas: relatorio.despesasTotal,
            lucro: relatorio.lucroLiquido
        )
        pagina.desenharLinha("Receita (vendas)", Formatters.brl(relatorio.receitaTotal))
        pagina.desenharLinha("Despesas (compras)", Formatters.brl(relatorio.despesasTotal))
        pagina.desenharLinha("Lucro líquido", Formatters.brl(relatorio.lucroLiquido), negrito: true)
        if let margem = relatorio.margemMediaPercentual {
            pagina.desenharLinha("Margem média", String(format: "%.1f%%", margem))
        }
        pagina.desenharLinha("Vendas realizadas", "\(relatorio.vendasQuantidade)")
        pagina.finalizarSecao()

        // MARK: Seção 3 — Estoque
        pagina.iniciarSecao(3, titulo: "Estoque", subtitulo: "Composição e valor por categoria")
        pagina.desenharGraficoRoscaEstoque(
            disponiveis: relatorio.panorama.disponiveis,
            reservados: relatorio.panorama.reservados,
            parados: relatorio.produtosParados
        )
        pagina.desenharLinha("Total de itens", "\(relatorio.itensEstoque)")
        pagina.desenharLinha("Valor de venda", Formatters.brl(relatorio.valorEstoque))
        pagina.desenharLinha("Custo total", Formatters.brl(relatorio.custoEstoque))
        if !relatorio.estoquePorCategoria.isEmpty {
            pagina.avancar(8)
            pagina.desenharSubtitulo("Valor por categoria")
            pagina.desenharGraficoBarrasHorizontais(
                itens: relatorio.estoquePorCategoria.map { ($0.tipo.rawValue, $0.valor) }
            )
            for item in relatorio.estoquePorCategoria {
                pagina.desenharLinha(
                    item.tipo.rawValue,
                    "\(item.quantidade) un. · \(Formatters.brl(item.valor))"
                )
            }
        }
        pagina.finalizarSecao()

        // MARK: Seção 4 — Avaliações
        pagina.iniciarSecao(4, titulo: "Avaliações e Compras", subtitulo: "Pipeline de aquisição e pagamentos")
        pagina.desenharGraficoPipelineAvaliacoes(
            emAvaliacao: relatorio.avaliacoesPendentes,
            avaliados: relatorio.avaliacoesAvaliadas,
            aprovados: relatorio.panorama.avaliacoesAprovadas,
            noEstoque: relatorio.panorama.avaliacoesNoEstoque,
            recusados: relatorio.panorama.comprasRecusadasTotal
        )
        pagina.desenharLinha("Em avaliação", "\(relatorio.avaliacoesPendentes)")
        pagina.desenharLinha("Avaliados", "\(relatorio.avaliacoesAvaliadas)")
        pagina.desenharLinha("Compras aprovadas", Formatters.brl(relatorio.panorama.comprasAprovadas))
        pagina.desenharLinha("Pagamentos pendentes", Formatters.brl(relatorio.pagamentosPendentes))
        pagina.desenharLinha("Pagamentos aprovados", Formatters.brl(relatorio.panorama.pagamentosAprovados))
        pagina.desenharLinha("Estimativa avaliados", Formatters.brl(relatorio.panorama.estimativaAvaliadas))
        pagina.desenharLinha("Compras recusadas", "\(relatorio.comprasRecusadas) no período")
        pagina.finalizarSecao()

        // MARK: Seção 5 — Recusas
        if !relatorio.recusasNoPeriodo.isEmpty {
            pagina.iniciarSecao(5, titulo: "Compras Não Aprovadas", subtitulo: "Justificativas registradas no período")
            for recusa in relatorio.recusasNoPeriodo {
                let valor = recusa.valorEstimado.map { Formatters.brl($0) } ?? "—"
                pagina.desenharItemLista(
                    titulo: "\(recusa.titulo) · \(valor) · \(Formatters.dataCurta.string(from: recusa.data))",
                    texto: recusa.justificativa,
                    prioridade: "Recusada"
                )
            }
            pagina.finalizarSecao()
        }

        // MARK: Seção 6 — Recomendações
        let numeroSugestoes = relatorio.recusasNoPeriodo.isEmpty ? 5 : 6
        pagina.iniciarSecao(numeroSugestoes, titulo: "Recomendações", subtitulo: "O que melhorar na operação")
        if relatorio.sugestoes.isEmpty {
            pagina.desenharParagrafo("Nenhuma sugestão no momento.")
        } else {
            for sugestao in relatorio.sugestoes {
                pagina.desenharItemLista(
                    titulo: sugestao.titulo,
                    texto: sugestao.mensagem,
                    prioridade: rotuloPrioridade(sugestao.prioridade)
                )
            }
        }
        pagina.finalizarSecao()

        pagina.finalizar()
        context.closePDF()
        return pdfData as Data
    }

    // MARK: - Página (coordenadas PDF nativas: origem no canto inferior esquerdo)

    private final class PaginaPDF {
        let context: CGContext
        let relatorio: RelatorioFinanceiro
        var numero = 1
        var cursorTopo: CGFloat = 0
        private var secaoInicioTopo: CGFloat?
        private var indentacaoConteudo: CGFloat = 0
        private let paddingSecao: CGFloat = 12

        private var limiteTopo: CGFloat {
            alturaPagina - margem - alturaRodape
        }

        private var larguraConteudo: CGFloat {
            larguraPagina - margem * 2
        }

        private var margemTexto: CGFloat {
            margem + indentacaoConteudo
        }

        private var larguraTexto: CGFloat {
            larguraConteudo - indentacaoConteudo
        }

        init(context: CGContext, relatorio: RelatorioFinanceiro) {
            self.context = context
            self.relatorio = relatorio
        }

        func iniciar() {
            novaPagina()
        }

        func finalizar() {
            desenharRodape()
            context.endPDFPage()
        }

        func avancar(_ valor: CGFloat) {
            cursorTopo += valor
        }

        func desenharCabecalho() {
            let topoCabecalho = cursorTopo

            if let logo = imagemAppLogo() {
                let tamanho: CGFloat = 52
                desenharLogoApp(logo, topo: topoCabecalho + 22, esquerda: margem, largura: tamanho, altura: tamanho)
            }

            desenharTexto(
                "iStock",
                topo: topoCabecalho + 24,
                esquerda: margem + 64,
                tamanho: 26,
                peso: .bold,
                familia: .arredondada,
                cor: textoEscuro,
                kern: 0.6
            )
            desenharTexto(
                "Relatório Financeiro e de Estoque",
                topo: topoCabecalho + 54,
                esquerda: margem + 64,
                tamanho: 13,
                peso: .medium,
                familia: .texto,
                cor: textoCinza
            )

            let periodo = "\(Formatters.dataCurta.string(from: relatorio.periodoInicio)) — \(Formatters.dataCurta.string(from: relatorio.periodoFim))"
            let larguraPeriodo = medirTexto(periodo, tamanho: 11, peso: .medium, familia: .texto)
            desenharTexto(
                periodo,
                topo: topoCabecalho + 28,
                esquerda: larguraPagina - margem - larguraPeriodo,
                tamanho: 11,
                peso: .medium,
                familia: .texto,
                cor: textoEscuro
            )
            let subtitulo = "Panorama completo do inventário Apple"
            desenharTexto(
                subtitulo,
                topo: topoCabecalho + 46,
                esquerda: larguraPagina - margem - medirTexto(subtitulo, tamanho: 10, peso: .regular, familia: .texto),
                tamanho: 10,
                peso: .regular,
                familia: .texto,
                cor: textoCinza
            )

            let yLinha = yBase(topo: topoCabecalho + alturaCabecalho, altura: 0)
            context.setStrokeColor(azulPrimario)
            context.setLineWidth(1.5)
            context.move(to: CGPoint(x: margem, y: yLinha))
            context.addLine(to: CGPoint(x: larguraPagina - margem, y: yLinha))
            context.strokePath()

            cursorTopo = topoCabecalho + alturaCabecalho + 28
        }

        func iniciarSecao(_ numero: Int, titulo: String, subtitulo: String?) {
            verificarQuebra(80)
            avancar(6)
            secaoInicioTopo = cursorTopo

            let badge: CGFloat = 28
            let rectBadge = CGRect(
                x: margem,
                y: yBase(topo: cursorTopo, altura: badge),
                width: badge,
                height: badge
            )
            context.setFillColor(corFundoSecao)
            context.fill(CGRect(
                x: margem - 4,
                y: rectBadge.minY - 4,
                width: larguraConteudo + 8,
                height: 44
            ))
            context.setFillColor(azulPrimario)
            context.fillEllipse(in: rectBadge)

            let num = String(format: "%02d", numero)
            let larguraNum = medirTexto(num, tamanho: 11, peso: .bold, familia: .mono)
            desenharTexto(
                num,
                topo: cursorTopo + 7,
                esquerda: margem + (badge - larguraNum) / 2,
                tamanho: 11,
                peso: .bold,
                familia: .mono,
                cor: .white
            )

            let tituloX = margem + badge + 12
            desenharTexto(
                titulo,
                topo: cursorTopo + 2,
                esquerda: tituloX,
                tamanho: 15,
                peso: .semibold,
                familia: .display,
                cor: textoEscuro
            )
            if let subtitulo {
                desenharTexto(
                    subtitulo,
                    topo: cursorTopo + 20,
                    esquerda: tituloX,
                    tamanho: 10,
                    peso: .regular,
                    familia: .texto,
                    cor: textoCinza
                )
                cursorTopo += 40
            } else {
                cursorTopo += 34
            }

            indentacaoConteudo = 10
            avancar(4)
        }

        func finalizarSecao() {
            if let inicio = secaoInicioTopo {
                let alturaBloco = cursorTopo - inicio + paddingSecao
                let rect = CGRect(
                    x: margem - 4,
                    y: yBase(topo: inicio - 4, altura: alturaBloco + 8),
                    width: larguraConteudo + 8,
                    height: alturaBloco + 8
                )
                context.setStrokeColor(corBordaSecao)
                context.setLineWidth(0.75)
                context.stroke(rect)

                context.setFillColor(azulPrimario)
                context.fill(CGRect(x: margem - 4, y: rect.minY, width: 3, height: rect.height))
            }

            indentacaoConteudo = 0
            secaoInicioTopo = nil
            avancar(20)
        }

        func desenharSubtitulo(_ texto: String) {
            verificarQuebra(24)
            desenharTexto(
                texto,
                topo: cursorTopo,
                esquerda: margemTexto,
                tamanho: 11,
                peso: .semibold,
                familia: .texto,
                cor: azulEscuro
            )
            cursorTopo += 18
        }

        func desenharSecao(_ titulo: String) {
            verificarQuebra(30)
            desenharTexto(
                titulo.uppercased(),
                topo: cursorTopo,
                esquerda: margem,
                tamanho: 12,
                peso: .semibold,
                familia: .texto,
                cor: azulEscuro,
                kern: 0.8
            )
            cursorTopo += 24
        }

        func desenharLinha(_ esquerda: String, _ direita: String, negrito: Bool = false) {
            verificarQuebra(22)
            let peso: PDFFonteApple.Peso = negrito ? .semibold : .regular
            desenharTexto(
                esquerda,
                topo: cursorTopo,
                esquerda: margemTexto,
                tamanho: 11,
                peso: peso,
                familia: .texto,
                cor: textoEscuro
            )
            let larguraDireita = medirTexto(direita, tamanho: 11, peso: negrito ? .semibold : .medium, familia: .mono)
            desenharTexto(
                direita,
                topo: cursorTopo,
                esquerda: larguraPagina - margem - larguraDireita,
                tamanho: 11,
                peso: negrito ? .semibold : .medium,
                familia: .mono,
                cor: textoEscuro
            )
            cursorTopo += 20
        }

        func desenharCardsMetricas(_ cards: [(String, String, CGColor)]) {
            verificarQuebra(72)
            let gap: CGFloat = 10
            let larguraCard = (larguraTexto - gap * CGFloat(cards.count - 1)) / CGFloat(cards.count)
            let alturaCard: CGFloat = 54
            let topo = cursorTopo

            for (indice, card) in cards.enumerated() {
                let x = margemTexto + CGFloat(indice) * (larguraCard + gap)
                let rect = CGRect(
                    x: x,
                    y: yBase(topo: topo, altura: alturaCard),
                    width: larguraCard,
                    height: alturaCard
                )
                context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
                context.fill(rect)
                context.setStrokeColor(corBordaSecao)
                context.setLineWidth(0.5)
                context.stroke(rect)

                context.setFillColor(card.2)
                context.fill(CGRect(x: x, y: rect.minY, width: larguraCard, height: 3))

                desenharTexto(
                    card.1,
                    topo: topo + 14,
                    esquerda: x + 8,
                    tamanho: 12,
                    peso: .semibold,
                    familia: .mono,
                    cor: textoEscuro
                )
                desenharTexto(
                    card.0,
                    topo: topo + 32,
                    esquerda: x + 8,
                    tamanho: 8.5,
                    peso: .medium,
                    familia: .texto,
                    cor: textoCinza
                )
            }
            cursorTopo = topo + alturaCard + 12
        }

        func desenharGraficoComparativoReceita(mes: Double, historico: Double) {
            verificarQuebra(130)
            desenharSubtitulo("Receita: mês vs histórico")
            desenharGraficoBarrasVerticais(
                itens: [
                    ("Mês atual", mes, corLucro),
                    ("Histórico", historico, corReceita)
                ],
                alturaGrafico: 80
            )
        }

        func desenharGraficoBarrasFinanceiro(receita: Double, despesas: Double, lucro: Double) {
            verificarQuebra(150)
            desenharSubtitulo("Receita · Despesas · Lucro")
            desenharGraficoBarrasVerticais(
                itens: [
                    ("Receita", receita, corReceita),
                    ("Despesas", despesas, corDespesa),
                    ("Lucro", max(lucro, 0), lucro >= 0 ? corLucro : corAlerta)
                ],
                alturaGrafico: 90
            )
        }

        func desenharGraficoBarrasVerticais(
            itens: [(String, Double, CGColor)],
            alturaGrafico: CGFloat
        ) {
            guard !itens.isEmpty else { return }
            let topo = cursorTopo
            let maxValor = itens.map(\.1).max() ?? 1
            let base = max(maxValor, 1)
            let larguraBarra: CGFloat = min(56, (larguraTexto - 40) / CGFloat(itens.count) - 16)
            let inicioX = margemTexto + 20
            let baseY = topo + alturaGrafico + 18

            context.setStrokeColor(corBordaSecao)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: margemTexto, y: yBase(topo: baseY, altura: 0)))
            context.addLine(to: CGPoint(x: larguraPagina - margem, y: yBase(topo: baseY, altura: 0)))
            context.strokePath()

            for (indice, item) in itens.enumerated() {
                let proporcao = CGFloat(item.1 / base)
                let alturaBar = max(4, alturaGrafico * proporcao)
                let x = inicioX + CGFloat(indice) * (larguraBarra + 28)
                let rect = CGRect(
                    x: x,
                    y: yBase(topo: baseY - alturaBar, altura: alturaBar),
                    width: larguraBarra,
                    height: alturaBar
                )
                context.setFillColor(item.2)
                context.fill(rect)

                let valor = item.1 >= 1000 ? Formatters.brl(item.1) : (item.1 == floor(item.1) ? "\(Int(item.1))" : String(format: "%.1f", item.1))
                let lw = medirTexto(valor, tamanho: 8, peso: .medium, familia: .mono)
                desenharTexto(
                    valor,
                    topo: baseY - alturaBar - 12,
                    esquerda: x + (larguraBarra - lw) / 2,
                    tamanho: 8,
                    peso: .medium,
                    familia: .mono,
                    cor: textoEscuro
                )
                let tw = medirTexto(item.0, tamanho: 8, peso: .regular, familia: .texto)
                desenharTexto(
                    item.0,
                    topo: baseY + 4,
                    esquerda: x + (larguraBarra - tw) / 2,
                    tamanho: 8,
                    peso: .regular,
                    familia: .texto,
                    cor: textoCinza
                )
            }
            cursorTopo = baseY + 28
        }

        func desenharGraficoRoscaEstoque(disponiveis: Int, reservados: Int, parados: Int) {
            verificarQuebra(150)
            desenharSubtitulo("Status do estoque")
            let segmentos: [(Double, CGColor, String)] = [
                (Double(disponiveis), corReceita, "Disponíveis"),
                (Double(reservados), corDespesa, "Reservados"),
                (Double(parados), corAlerta, "Parados")
            ].filter { $0.0 > 0 }

            guard !segmentos.isEmpty else {
                desenharParagrafo("Sem itens em estoque para exibir.")
                return
            }

            let tamanho: CGFloat = 88
            let centroX = margemTexto + tamanho / 2 + 8
            let centroY = yBase(topo: cursorTopo + tamanho / 2, altura: 0)
            let raioExterno = tamanho / 2
            let raioInterno = raioExterno * 0.55
            let total = segmentos.reduce(0) { $0 + $1.0 }
            var angulo = -CGFloat.pi / 2

            for segmento in segmentos {
                let sweep = CGFloat((segmento.0 / total) * 2 * .pi)
                context.setFillColor(segmento.1)
                context.move(to: CGPoint(x: centroX, y: centroY))
                context.addArc(
                    center: CGPoint(x: centroX, y: centroY),
                    radius: raioExterno,
                    startAngle: angulo,
                    endAngle: angulo + sweep,
                    clockwise: false
                )
                context.closePath()
                context.fillPath()
                angulo += sweep
            }

            context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            context.fillEllipse(in: CGRect(
                x: centroX - raioInterno,
                y: centroY - raioInterno,
                width: raioInterno * 2,
                height: raioInterno * 2
            ))

            let legendaX = margemTexto + tamanho + 28
            var legendaY = cursorTopo + 8
            for segmento in segmentos {
                context.setFillColor(segmento.1)
                context.fill(CGRect(
                    x: legendaX,
                    y: yBase(topo: legendaY + 8, altura: 8),
                    width: 8,
                    height: 8
                ))
                desenharTexto(
                    "\(segmento.2): \(Int(segmento.0))",
                    topo: legendaY,
                    esquerda: legendaX + 14,
                    tamanho: 10,
                    peso: .medium,
                    familia: .texto,
                    cor: textoEscuro
                )
                legendaY += 22
            }
            cursorTopo += tamanho + 16
        }

        func desenharGraficoBarrasHorizontais(itens: [(String, Double)]) {
            verificarQuebra(CGFloat(itens.count) * 24 + 20)
            let maxValor = itens.map(\.1).max() ?? 1
            let base = max(maxValor, 1)
            let larguraMax = larguraTexto - 120

            for (indice, item) in itens.enumerated() {
                let topo = cursorTopo + CGFloat(indice) * 24
                let larguraBar = larguraMax * CGFloat(item.1 / base)
                let cor = RelatorioPDFGerador.paletaGrafico[indice % RelatorioPDFGerador.paletaGrafico.count]
                context.setFillColor(cor)
                context.fill(CGRect(
                    x: margemTexto + 110,
                    y: yBase(topo: topo + 10, altura: 10),
                    width: max(larguraBar, 4),
                    height: 10
                ))
                desenharTexto(
                    item.0,
                    topo: topo,
                    esquerda: margemTexto,
                    tamanho: 9,
                    peso: .regular,
                    familia: .texto,
                    cor: textoEscuro
                )
                desenharTexto(
                    Formatters.brl(item.1),
                    topo: topo,
                    esquerda: margemTexto + 110 + larguraBar + 6,
                    tamanho: 8,
                    peso: .medium,
                    familia: .mono,
                    cor: textoCinza
                )
            }
            cursorTopo += CGFloat(itens.count) * 24 + 8
        }

        func desenharGraficoPipelineAvaliacoes(
            emAvaliacao: Int,
            avaliados: Int,
            aprovados: Int,
            noEstoque: Int,
            recusados: Int
        ) {
            verificarQuebra(150)
            desenharSubtitulo("Pipeline de avaliações")
            let itens: [(String, Double, CGColor)] = [
                ("Em avaliação", Double(emAvaliacao), corDespesa),
                ("Avaliados", Double(avaliados), azulPrimario),
                ("Aprovados", Double(aprovados), corReceita),
                ("No estoque", Double(noEstoque), corLucro),
                ("Recusados", Double(recusados), corAlerta)
            ].filter { $0.1 > 0 }

            if itens.isEmpty {
                desenharParagrafo("Nenhuma avaliação registrada.")
                return
            }
            desenharGraficoBarrasVerticais(itens: itens, alturaGrafico: 85)
        }

        func desenharParagrafo(_ texto: String) {
            verificarQuebra(40)
            let altura = desenharTextoMultilinha(
                texto,
                topo: cursorTopo,
                esquerda: margemTexto,
                tamanho: 10.5,
                largura: larguraTexto,
                peso: .regular,
                cor: textoCinza
            )
            cursorTopo += altura + 8
        }

        func desenharItemLista(titulo: String, texto: String, prioridade: String) {
            verificarQuebra(52)
            desenharTexto(
                "• \(titulo) [\(prioridade)]",
                topo: cursorTopo,
                esquerda: margemTexto,
                tamanho: 11,
                peso: .semibold,
                familia: .texto,
                cor: textoEscuro
            )
            cursorTopo += 17
            let altura = desenharTextoMultilinha(
                texto,
                topo: cursorTopo,
                esquerda: margemTexto + 12,
                tamanho: 10.5,
                largura: larguraTexto - 12,
                peso: .regular,
                cor: textoCinza
            )
            cursorTopo += altura + 10
        }

        private func novaPagina() {
            context.beginPDFPage(nil)
            desenharMarcaDagua()
        }

        private func verificarQuebra(_ alturaNecessaria: CGFloat) {
            guard cursorTopo + alturaNecessaria > limiteTopo else { return }

            desenharRodape()
            context.endPDFPage()

            numero += 1
            novaPagina()

            desenharTexto(
                "iStock — Relatório (continuação)",
                topo: margem,
                esquerda: margem,
                tamanho: 13,
                peso: .semibold,
                familia: .display,
                cor: azulEscuro
            )
            cursorTopo = margem + 30
        }

        private func desenharMarcaDagua() {
            context.saveGState()
            context.translateBy(x: larguraPagina / 2, y: alturaPagina / 2)
            context.rotate(by: .pi / 7)
            context.setAlpha(0.055)

            let lado: CGFloat = 110
            if let apple = imagemAppleLogo(tamanho: 120) {
                context.draw(
                    apple,
                    in: CGRect(x: -lado / 2, y: -lado / 2 - 20, width: lado, height: lado)
                )
            }

            let attrs = PDFFonteApple.atributos(
                tamanho: 48,
                peso: .semibold,
                familia: .arredondada,
                cor: CGColor(gray: 0.3, alpha: 1),
                kern: 1.2
            )
            let attributed = NSAttributedString(string: "iStock", attributes: attrs)
            let line = CTLineCreateWithAttributedString(attributed)
            let largura = CTLineGetTypographicBounds(line, nil, nil, nil)
            context.textPosition = CGPoint(x: -largura / 2, y: lado / 2 - 10)
            CTLineDraw(line, context)

            context.restoreGState()
            context.setAlpha(1)
        }

        private func desenharRodape() {
            let topoRodape = alturaPagina - alturaRodape
            let yLinha = yBase(topo: topoRodape, altura: 0)

            context.setStrokeColor(CGColor(gray: 0.88, alpha: 1))
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: margem, y: yLinha))
            context.addLine(to: CGPoint(x: larguraPagina - margem, y: yLinha))
            context.strokePath()

            let gerado = "Gerado em \(Formatters.dataCompleta.string(from: .now))"
            desenharTexto(gerado, topo: topoRodape + 10, esquerda: margem, tamanho: 9, peso: .regular, familia: .texto, cor: textoCinza)

            let paginaTexto = "Página \(numero)"
            let larguraPaginaTexto = medirTexto(paginaTexto, tamanho: 9, peso: .regular, familia: .texto)
            desenharTexto(
                paginaTexto,
                topo: topoRodape + 10,
                esquerda: larguraPagina - margem - larguraPaginaTexto,
                tamanho: 9,
                peso: .regular,
                familia: .texto,
                cor: textoCinza
            )

            let marca = "iStock · Inventário Apple"
            let larguraMarca = medirTexto(marca, tamanho: 9, peso: .semibold, familia: .arredondada)
            desenharTexto(
                marca,
                topo: topoRodape + 10,
                esquerda: (larguraPagina - larguraMarca) / 2,
                tamanho: 9,
                peso: .semibold,
                familia: .arredondada,
                cor: azulPrimario
            )
        }

        private func desenharImagem(_ imagem: CGImage, topo: CGFloat, esquerda: CGFloat, largura: CGFloat, altura: CGFloat) {
            let rect = CGRect(x: esquerda, y: yBase(topo: topo, altura: altura), width: largura, height: altura)
            context.draw(imagem, in: rect)
        }

        private func desenharLogoApp(_ imagem: CGImage, topo: CGFloat, esquerda: CGFloat, largura: CGFloat, altura: CGFloat) {
            let rect = CGRect(x: esquerda, y: yBase(topo: topo, altura: altura), width: largura, height: altura)
            let raio = largura * 0.2237

            context.saveGState()
            context.addPath(CGPath(roundedRect: rect, cornerWidth: raio, cornerHeight: raio, transform: nil))
            context.clip()
            context.interpolationQuality = .high
            context.draw(imagem, in: rect)
            context.restoreGState()
        }

        @discardableResult
        private func desenharTexto(
            _ texto: String,
            topo: CGFloat,
            esquerda: CGFloat,
            tamanho: CGFloat,
            peso: PDFFonteApple.Peso = .regular,
            familia: PDFFonteApple.Familia = .texto,
            cor: CGColor = RelatorioPDFGerador.textoEscuro,
            kern: CGFloat = 0
        ) -> CGFloat {
            let attrs = PDFFonteApple.atributos(
                tamanho: tamanho,
                peso: peso,
                familia: familia,
                cor: cor,
                kern: kern
            )
            let attributed = NSAttributedString(string: texto, attributes: attrs)
            let line = CTLineCreateWithAttributedString(attributed)
            let ctFont = PDFFonteApple.ctFont(tamanho: tamanho, peso: peso, familia: familia)
            let ascent = CTFontGetAscent(ctFont)
            let descent = CTFontGetDescent(ctFont)
            context.textPosition = CGPoint(x: esquerda, y: yBase(topo: topo, altura: ascent + descent) + descent)
            CTLineDraw(line, context)
            return ascent + descent
        }

        @discardableResult
        private func desenharTextoMultilinha(
            _ texto: String,
            topo: CGFloat,
            esquerda: CGFloat,
            tamanho: CGFloat,
            largura: CGFloat,
            peso: PDFFonteApple.Peso = .regular,
            cor: CGColor
        ) -> CGFloat {
            let attrs = PDFFonteApple.atributos(
                tamanho: tamanho,
                peso: peso,
                familia: .texto,
                cor: cor
            )
            let paragrafo = NSMutableParagraphStyle()
            paragrafo.lineSpacing = 2
            var attrsComParagrafo = attrs
            attrsComParagrafo[.paragraphStyle] = paragrafo

            let attributed = NSAttributedString(string: texto, attributes: attrsComParagrafo)
            let framesetter = CTFramesetterCreateWithAttributedString(attributed)
            let sugestaoAltura = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRange(location: 0, length: attributed.length),
                nil,
                CGSize(width: largura, height: .greatestFiniteMagnitude),
                nil
            )
            let altura = sugestaoAltura.height + 4
            let rect = CGRect(x: esquerda, y: yBase(topo: topo, altura: altura), width: largura, height: altura)
            let path = CGPath(rect: rect, transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
            CTFrameDraw(frame, context)
            return altura
        }

        private func medirTexto(
            _ texto: String,
            tamanho: CGFloat,
            peso: PDFFonteApple.Peso,
            familia: PDFFonteApple.Familia
        ) -> CGFloat {
            let attrs = PDFFonteApple.atributos(tamanho: tamanho, peso: peso, familia: familia, cor: textoEscuro)
            return NSAttributedString(string: texto, attributes: attrs).size().width
        }

        /// Converte distância do topo da página para coordenada Y inferior do retângulo (sistema PDF).
        private func yBase(topo: CGFloat, altura: CGFloat) -> CGFloat {
            alturaPagina - topo - altura
        }
    }

    // MARK: - Imagens

    private static func imagemAppLogo() -> CGImage? {
        #if os(macOS)
        guard let image = NSImage(named: "AppLogo") else { return nil }
        guard let rep = image.representations
            .compactMap({ $0 as? NSBitmapImageRep })
            .first(where: { $0.hasAlpha }) ?? image.representations.compactMap({ $0 as? NSBitmapImageRep }).first
        else {
            var rect = CGRect(origin: .zero, size: image.size)
            return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        }
        return rep.cgImage
        #else
        guard let image = UIImage(named: "AppLogo") else { return nil }
        return image.cgImage
        #endif
    }

    private static func imagemAppleLogo(tamanho: CGFloat) -> CGImage? {
        #if os(macOS)
        let config = NSImage.SymbolConfiguration(pointSize: tamanho, weight: .thin)
        guard let image = NSImage(systemSymbolName: "apple.logo", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) else { return nil }
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #else
        let config = UIImage.SymbolConfiguration(pointSize: tamanho, weight: .thin)
        guard let image = UIImage(systemName: "apple.logo", withConfiguration: config) else { return nil }
        return image.cgImage
        #endif
    }

    private static func corPlataforma(cgColor: CGColor) -> Any {
        #if os(macOS)
        return NSColor(cgColor: cgColor) ?? NSColor.black
        #else
        return UIColor(cgColor: cgColor) ?? UIColor.black
        #endif
    }

    private static func rotuloPrioridade(_ prioridade: SugestaoPainel.PrioridadeSugestao) -> String {
        switch prioridade {
        case .alta: return "Alta"
        case .media: return "Média"
        case .baixa: return "Baixa"
        }
    }
}
