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
    private static let textoEscuro = CGColor(gray: 0.12, alpha: 1)
    private static let textoCinza = CGColor(gray: 0.45, alpha: 1)

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
        pagina.avancar(20)

        pagina.desenharSecao("Panorama geral")
        pagina.desenharLinha("Receita histórica (vendas)", Formatters.brl(relatorio.panorama.receitaHistorica))
        pagina.desenharLinha("Receita do mês atual", Formatters.brl(relatorio.panorama.receitaMes))
        pagina.desenharLinha("Vendas no mês", "\(relatorio.panorama.vendidosMes)")
        pagina.desenharLinha("Valor em estoque", Formatters.brl(relatorio.valorEstoque))
        pagina.desenharLinha("Custo em estoque", Formatters.brl(relatorio.custoEstoque))
        pagina.desenharLinha("Margem potencial em estoque", Formatters.brl(relatorio.panorama.margemPotencialEstoque))
        pagina.desenharLinha("Itens disponíveis", "\(relatorio.panorama.disponiveis)")
        pagina.desenharLinha("Itens reservados", "\(relatorio.panorama.reservados)")
        pagina.desenharLinha("Produtos parados (+30 dias)", "\(relatorio.produtosParados)")
        pagina.avancar(12)

        pagina.desenharSecao("Período analisado (\(RelatorioAnaliseService.diasPeriodoRelatorio) dias)")
        pagina.desenharLinha("De", Formatters.dataCurta.string(from: relatorio.periodoInicio))
        pagina.desenharLinha("Até", Formatters.dataCurta.string(from: relatorio.periodoFim))
        pagina.avancar(12)

        pagina.desenharSecao("Resumo financeiro do período")
        pagina.desenharLinha("Receita (vendas)", Formatters.brl(relatorio.receitaTotal))
        pagina.desenharLinha("Despesas (compras)", Formatters.brl(relatorio.despesasTotal))
        pagina.desenharLinha("Lucro líquido", Formatters.brl(relatorio.lucroLiquido), negrito: true)
        if let margem = relatorio.margemMediaPercentual {
            pagina.desenharLinha("Margem média nas vendas", String(format: "%.1f%%", margem))
        }
        pagina.desenharLinha("Quantidade de vendas", "\(relatorio.vendasQuantidade)")
        pagina.avancar(12)

        pagina.desenharSecao("Estoque atual")
        pagina.desenharLinha("Total de itens", "\(relatorio.itensEstoque)")
        pagina.desenharLinha("Valor de venda", Formatters.brl(relatorio.valorEstoque))
        pagina.desenharLinha("Custo total", Formatters.brl(relatorio.custoEstoque))
        pagina.desenharLinha("Margem potencial", Formatters.brl(relatorio.panorama.margemPotencialEstoque))
        pagina.avancar(12)

        if !relatorio.estoquePorCategoria.isEmpty {
            pagina.desenharSecao("Estoque por categoria")
            for item in relatorio.estoquePorCategoria {
                pagina.desenharLinha(
                    item.tipo.rawValue,
                    "\(item.quantidade) un. · \(Formatters.brl(item.valor))"
                )
            }
            pagina.avancar(12)
        }

        pagina.desenharSecao("Avaliações e compras")
        pagina.desenharLinha("Em avaliação", "\(relatorio.avaliacoesPendentes)")
        pagina.desenharLinha("Avaliados (aguardando aprovação)", "\(relatorio.avaliacoesAvaliadas)")
        pagina.desenharLinha("Compras aprovadas", "\(relatorio.panorama.avaliacoesAprovadas)")
        pagina.desenharLinha("Já no estoque (via avaliação)", "\(relatorio.panorama.avaliacoesNoEstoque)")
        pagina.desenharLinha("Valor compras aprovadas", Formatters.brl(relatorio.panorama.comprasAprovadas))
        pagina.desenharLinha("Pagamentos pendentes", Formatters.brl(relatorio.pagamentosPendentes))
        pagina.desenharLinha("Compras com pgto pendente", "\(relatorio.panorama.pagamentosPendentesQuantidade)")
        pagina.desenharLinha("Pagamentos aprovados", Formatters.brl(relatorio.panorama.pagamentosAprovados))
        pagina.desenharLinha("Estimativa (avaliados)", Formatters.brl(relatorio.panorama.estimativaAvaliadas))
        pagina.desenharLinha("Venda real (avaliados)", Formatters.brl(relatorio.panorama.vendaRealAvaliadas))
        pagina.avancar(12)

        pagina.desenharSecao("O que melhorar")
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

        private var limiteTopo: CGFloat {
            alturaPagina - margem - alturaRodape
        }

        private var larguraConteudo: CGFloat {
            larguraPagina - margem * 2
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
            let baseCabecalho = yBase(topo: topoCabecalho, altura: alturaCabecalho)

            if let gradiente = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [azulPrimario, azulEscuro] as CFArray,
                locations: [0, 1]
            ) {
                context.drawLinearGradient(
                    gradiente,
                    start: CGPoint(x: 0, y: baseCabecalho),
                    end: CGPoint(x: larguraPagina, y: baseCabecalho + alturaCabecalho),
                    options: []
                )
            } else {
                context.setFillColor(azulPrimario)
                context.fill(CGRect(x: 0, y: baseCabecalho, width: larguraPagina, height: alturaCabecalho))
            }

            if let logo = imagemAppLogo() {
                let tamanho: CGFloat = 52
                desenharImagem(logo, topo: topoCabecalho + 22, esquerda: margem, largura: tamanho, altura: tamanho)
            }

            desenharTexto("iStock", topo: topoCabecalho + 26, esquerda: margem + 64, tamanho: 24, negrito: true, cor: .white)
            desenharTexto(
                "Relatório Financeiro e de Estoque",
                topo: topoCabecalho + 54,
                esquerda: margem + 64,
                tamanho: 12,
                cor: CGColor(gray: 1, alpha: 0.9)
            )

            let periodo = "\(Formatters.dataCurta.string(from: relatorio.periodoInicio)) — \(Formatters.dataCurta.string(from: relatorio.periodoFim))"
            let larguraPeriodo = medirTexto(periodo, tamanho: 10, negrito: false)
            desenharTexto(
                periodo,
                topo: topoCabecalho + 30,
                esquerda: larguraPagina - margem - larguraPeriodo,
                tamanho: 10,
                cor: CGColor(gray: 1, alpha: 0.85)
            )
            let subtitulo = "Panorama completo do inventário Apple"
            desenharTexto(
                subtitulo,
                topo: topoCabecalho + 48,
                esquerda: larguraPagina - margem - medirTexto(subtitulo, tamanho: 9, negrito: false),
                tamanho: 9,
                cor: CGColor(gray: 1, alpha: 0.7)
            )

            let yLinha = yBase(topo: topoCabecalho + alturaCabecalho + 10, altura: 0)
            context.setStrokeColor(CGColor(gray: 0.85, alpha: 1))
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: margem, y: yLinha))
            context.addLine(to: CGPoint(x: larguraPagina - margem, y: yLinha))
            context.strokePath()

            cursorTopo = topoCabecalho + alturaCabecalho + 28
        }

        func desenharSecao(_ titulo: String) {
            verificarQuebra(28)
            desenharTexto(titulo, topo: cursorTopo, esquerda: margem, tamanho: 14, negrito: true, cor: azulEscuro)
            cursorTopo += 22
        }

        func desenharLinha(_ esquerda: String, _ direita: String, negrito: Bool = false) {
            verificarQuebra(20)
            desenharTexto(esquerda, topo: cursorTopo, esquerda: margem, tamanho: 11, negrito: negrito, cor: textoEscuro)
            let larguraDireita = medirTexto(direita, tamanho: 11, negrito: negrito)
            desenharTexto(
                direita,
                topo: cursorTopo,
                esquerda: larguraPagina - margem - larguraDireita,
                tamanho: 11,
                negrito: negrito,
                cor: textoEscuro
            )
            cursorTopo += 18
        }

        func desenharParagrafo(_ texto: String) {
            verificarQuebra(40)
            let altura = desenharTextoMultilinha(
                texto,
                topo: cursorTopo,
                esquerda: margem,
                tamanho: 10,
                largura: larguraConteudo,
                cor: textoCinza
            )
            cursorTopo += altura + 8
        }

        func desenharItemLista(titulo: String, texto: String, prioridade: String) {
            verificarQuebra(52)
            desenharTexto(
                "• \(titulo) [\(prioridade)]",
                topo: cursorTopo,
                esquerda: margem,
                tamanho: 11,
                negrito: true,
                cor: textoEscuro
            )
            cursorTopo += 16
            let altura = desenharTextoMultilinha(
                texto,
                topo: cursorTopo,
                esquerda: margem + 12,
                tamanho: 10,
                largura: larguraConteudo - 12,
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
                tamanho: 12,
                negrito: true,
                cor: azulEscuro
            )
            cursorTopo = margem + 28
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

            let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 52, nil)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: corPlataforma(cgColor: CGColor(gray: 0.3, alpha: 1))
            ]
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
            desenharTexto(gerado, topo: topoRodape + 10, esquerda: margem, tamanho: 9, cor: textoCinza)

            let paginaTexto = "Página \(numero)"
            let larguraPaginaTexto = medirTexto(paginaTexto, tamanho: 9, negrito: false)
            desenharTexto(
                paginaTexto,
                topo: topoRodape + 10,
                esquerda: larguraPagina - margem - larguraPaginaTexto,
                tamanho: 9,
                cor: textoCinza
            )

            let marca = "iStock · Inventário Apple"
            let larguraMarca = medirTexto(marca, tamanho: 9, negrito: true)
            desenharTexto(
                marca,
                topo: topoRodape + 10,
                esquerda: (larguraPagina - larguraMarca) / 2,
                tamanho: 9,
                negrito: true,
                cor: azulPrimario
            )
        }

        private func desenharImagem(_ imagem: CGImage, topo: CGFloat, esquerda: CGFloat, largura: CGFloat, altura: CGFloat) {
            let rect = CGRect(x: esquerda, y: yBase(topo: topo, altura: altura), width: largura, height: altura)
            context.draw(imagem, in: rect)
        }

        @discardableResult
        private func desenharTexto(
            _ texto: String,
            topo: CGFloat,
            esquerda: CGFloat,
            tamanho: CGFloat,
            negrito: Bool = false,
            cor: CGColor = RelatorioPDFGerador.textoEscuro
        ) -> CGFloat {
            let font = CTFontCreateWithName((negrito ? "Helvetica-Bold" : "Helvetica") as CFString, tamanho, nil)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: corPlataforma(cgColor: cor)
            ]
            let attributed = NSAttributedString(string: texto, attributes: attrs)
            let line = CTLineCreateWithAttributedString(attributed)
            let ascent = CTFontGetAscent(font)
            let descent = CTFontGetDescent(font)
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
            cor: CGColor
        ) -> CGFloat {
            let font = CTFontCreateWithName("Helvetica" as CFString, tamanho, nil)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: corPlataforma(cgColor: cor)
            ]
            let attributed = NSAttributedString(string: texto, attributes: attrs)
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

        private func medirTexto(_ texto: String, tamanho: CGFloat, negrito: Bool) -> CGFloat {
            let font = CTFontCreateWithName((negrito ? "Helvetica-Bold" : "Helvetica") as CFString, tamanho, nil)
            let attrs: [NSAttributedString.Key: Any] = [.font: font]
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
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
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
