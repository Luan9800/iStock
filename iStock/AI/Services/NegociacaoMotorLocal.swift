//
//  NegociacaoMotorLocal.swift
//  iStock
//

import Foundation

enum IntencaoNegociacao {
    case desconto
    case troca
    case contraproposta
    case fechamento
    case objeção
    case parcelamento
    case geral
}

struct ContextoNegociacao {
    var produtosEstoque: [Lancamento] = []
}

struct NegociacaoMotorLocal {

    func responder(pergunta: String, contexto: ContextoNegociacao) -> String {
        let texto = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else {
            return mensagemBoasVindas()
        }

        let intencao = detectarIntencao(texto)
        let valores = extrairValores(texto)
        let produtos = detectarProdutos(no: texto, estoque: contexto.produtosEstoque)

        switch intencao {
        case .desconto:
            return respostaDesconto(texto: texto, valores: valores, produtos: produtos)
        case .troca:
            return respostaTroca(texto: texto, valores: valores, produtos: produtos)
        case .contraproposta:
            return respostaContraproposta(texto: texto, valores: valores, produtos: produtos)
        case .fechamento:
            return respostaFechamento(texto: texto, produtos: produtos)
        case .objeção:
            return respostaObjecao(texto: texto, produtos: produtos)
        case .parcelamento:
            return respostaParcelamento(texto: texto, valores: valores, produtos: produtos)
        case .geral:
            return respostaGeral(texto: texto, produtos: produtos)
        }
    }

    func mensagemBoasVindas() -> String {
        """
        Olá! Sou seu assistente de negociação.

        Descreva a situação com o cliente e eu ajudo com estratégia, valores e o que falar.

        Exemplos:
        • "Cliente quer pagar R$ 3.900 no iPhone 15 Pro de R$ 4.500"
        • "Quer trocar um iPhone 13 em um 15 Pro"
        • "Pediu 15% de desconto, como respondo?"
        """
    }

    // MARK: - Detecção

    private func detectarIntencao(_ texto: String) -> IntencaoNegociacao {
        let t = texto.lowercased()

        let regras: [(IntencaoNegociacao, [String])] = [
            (.troca, ["troca", "trocar", "entrada", "dar o meu", "dar meu", "permuta", "usado como entrada", "vale a troca"]),
            (.contraproposta, ["contraproposta", "ofereceu", "propôs", "propos", "quer pagar", "me deu", "me ofereceu", "só tem", "só pode", "no máximo", "no maximo"]),
            (.parcelamento, ["parcel", "vezes", "cartão", "cartao", "credito", "crédito", "financiar", "12x", "10x", "6x"]),
            (.desconto, ["desconto", "abaixar", "abaixa", "mais barato", "baratear", "reduzir", "diminuir preço", "diminuir preco", "% off", "porcentagem"]),
            (.objeção, ["caro", "pensar", "concorrente", "depois volto", "não sei", "nao sei", "vou ver", "preciso consultar", "muito alto"]),
            (.fechamento, ["fechar", "fechamos", "levar", "ficou decidido", "vou levar", "fecha hoje", "garantia", "pix na hora", "fechar negócio", "fechar negocio"]),
        ]

        var pontuacao: [IntencaoNegociacao: Int] = [:]
        for (intencao, palavras) in regras {
            pontuacao[intencao] = palavras.reduce(0) { $0 + (t.contains($1) ? 1 : 0) }
        }

        if let melhor = pontuacao.max(by: { $0.value < $1.value }), melhor.value > 0 {
            return melhor.key
        }

        if extrairValores(texto).count >= 2 {
            return .contraproposta
        }
        if extrairValores(texto).count == 1 && (t.contains("pagar") || t.contains("r$")) {
            return .contraproposta
        }

        return .geral
    }

    func extrairValores(_ texto: String) -> [Double] {
        let padrao = #"(?:r\$\s*)?(\d{1,3}(?:\.\d{3})*(?:,\d{1,2})?|\d+(?:,\d{1,2})?)"#
        guard let regex = try? NSRegularExpression(pattern: padrao, options: .caseInsensitive) else {
            return []
        }

        let faixa = NSRange(texto.startIndex..., in: texto)
        let matches = regex.matches(in: texto, range: faixa)

        return matches.compactMap { match -> Double? in
            guard let range = Range(match.range(at: 1), in: texto) else { return nil }
            var numero = String(texto[range])
            numero = numero.replacingOccurrences(of: ".", with: "")
            numero = numero.replacingOccurrences(of: ",", with: ".")
            return Double(numero)
        }
    }

    private func detectarProdutos(no texto: String, estoque: [Lancamento]) -> [Lancamento] {
        let t = texto.lowercased()
        let disponiveis = estoque.filter(\.estaNoEstoque)

        let encontrados = disponiveis.filter { produto in
            let termos = [produto.nome, produto.modelo, produto.tipoProduto.rawValue]
                .compactMap { $0?.lowercased() }
            return termos.contains { termo in
                termo.count >= 4 && t.contains(termo)
            }
        }

        if !encontrados.isEmpty { return encontrados }

        let modelosComuns = ["iphone 16", "iphone 15", "iphone 14", "iphone 13", "iphone 12",
                             "ipad", "macbook", "airpods", "apple watch", "watch"]
        for modelo in modelosComuns where t.contains(modelo) {
            if let match = disponiveis.first(where: {
                ($0.modelo?.lowercased().contains(modelo) ?? false)
                    || $0.nome.lowercased().contains(modelo)
            }) {
                return [match]
            }
        }

        return []
    }

    // MARK: - Respostas

    private func respostaDesconto(texto: String, valores: [Double], produtos: [Lancamento]) -> String {
        let precoVenda = produtos.first?.valor ?? (valores.count >= 2 ? valores[0] : nil)
        let valorPedido = valorOfertado(valores: valores, precoReferencia: produtos.first?.valor)

        var resposta = "📌 **Situação:** pedido de desconto\n\n"

        if let preco = precoVenda, let pedido = valorPedido, pedido < preco {
            let desconto = preco - pedido
            let percentual = (desconto / preco) * 100
            let contraproposta = preco - (desconto * 0.55)

            resposta += """
            💰 **Análise rápida**
            • Preço de venda: \(Formatters.brl(preco))
            • Valor pedido: \(Formatters.brl(pedido))
            • Desconto solicitado: \(Formatters.brl(desconto)) (\(String(format: "%.1f", percentual))%)

            """

            if let margem = produtos.first?.margemPercentual {
                resposta += "• Margem atual: \(String(format: "%.0f", margem))%\n\n"
            }

            if percentual <= 5 {
                resposta += estrategiaFechamentoRapido(valor: pedido)
            } else if percentual <= 10 {
                resposta += """
                💡 **Estratégia**
                Desconto moderado. Tente contrapropor em \(Formatters.brl(contraproposta)) com algo de valor percebido (capa, película ou garantia estendida).

                💬 **Sugestão de fala**
                "Consigo chegar em \(Formatters.brl(contraproposta)) para fecharmos hoje, com película e capa inclusas. Esse é o melhor que consigo autorizar agora."

                """
            } else {
                resposta += """
                ⚠️ **Atenção:** desconto alto. Evite ceder tudo de uma vez.

                💡 **Estratégia**
                1. Ancore o valor do produto (estado, bateria, garantia, acessórios).
                2. Ofereça contraproposta em \(Formatters.brl(contraproposta)).
                3. Se insistir, condicione desconto máximo a pagamento à vista no PIX.

                💬 **Sugestão de fala**
                "Entendo sua proposta. O aparelho está \(produtos.first?.lacrado == true ? "lacrado" : "em excelente estado") e já está com preço competitivo. Consigo \(Formatters.brl(contraproposta)) com pagamento à vista — é o melhor cenário que consigo montar."

                """
            }
        } else {
            resposta += """
            💡 **Estratégia**
            • Pergunte qual valor o cliente tinha em mente.
            • Reforce diferenciais: garantia, revisão, suporte e procedência.
            • Ofereça benefício em vez de desconto bruto (acessório, transferência de dados).

            💬 **Sugestão de fala**
            "Posso verificar uma condição especial para você. Qual valor ficaria confortável para fecharmos hoje?"

            """
        }

        if let produto = produtos.first {
            resposta += contextoProduto(produto)
        }

        return resposta
    }

    private func respostaTroca(texto: String, valores: [Double], produtos: [Lancamento]) -> String {
        var resposta = "📌 **Situação:** negociação com troca/entrada\n\n"

        resposta += """
        💡 **Passo a passo**
        1. **Avalie o usado:** bateria, tela, funcionais, IMEI e histórico.
        2. **Precifique conservadoramente** — margem de revenda precisa caber.
        3. **Calcule a diferença:** preço do novo − valor da entrada.
        4. **Apresente 2 cenários:** troca simples e troca + pequeno desconto à vista.

        💬 **Sugestão de fala**
        "Fazemos a avaliação do seu aparelho agora. Com base no estado e na demanda, calculo a entrada e te mostro a diferença para o upgrade."

        """

        if let produto = produtos.first {
            let preco = produto.valor
            if let entrada = valores.first, entrada < preco {
                let diferenca = preco - entrada
                resposta += """

                💰 **Simulação**
                • Produto desejado: \(produto.tituloExibicao) — \(Formatters.brl(preco))
                • Entrada estimada: \(Formatters.brl(entrada))
                • Diferença a pagar: **\(Formatters.brl(diferenca))**

                💬 **Para fechar**
                "Com sua entrada de \(Formatters.brl(entrada)), a diferença fica \(Formatters.brl(diferenca)). Consigo melhorar um pouco se fecharmos hoje no PIX."

                """
            }
            resposta += contextoProduto(produto)
        } else if valores.count >= 2 {
            let diferenca = abs(valores[1] - valores[0])
            resposta += "\n💰 Diferença entre os valores citados: **\(Formatters.brl(diferenca))**\n"
        }

        return resposta
    }

    private func respostaContraproposta(texto: String, valores: [Double], produtos: [Lancamento]) -> String {
        let preco = produtos.first?.valor ?? (valores.count >= 2 ? valores[0] : nil)
        let oferta = valorOfertado(valores: valores, precoReferencia: preco)

        var resposta = "📌 **Situação:** contraproposta do cliente\n\n"

        if let preco, let oferta, oferta < preco {
            let gap = preco - oferta
            let meioTermo = preco - (gap * 0.45)

            resposta += """
            💰 **Análise**
            • Seu preço: \(Formatters.brl(preco))
            • Oferta do cliente: \(Formatters.brl(oferta))
            • Distância: \(Formatters.brl(gap))

            💡 **Estratégia**
            Não aceite nem recuse de imediato. Proponha **\(Formatters.brl(meioTermo))** como ponto de equilíbrio.

            💬 **Sugestão de fala**
            "Sua proposta está abaixo do que consigo, mas quero fechar com você. Em \(Formatters.brl(meioTermo)) no PIX eu libero hoje com garantia e suporte."

            🎯 **Técnica:** silêncio após a contraproposta — deixe o cliente reagir.

            """
        } else {
            resposta += """
            💡 **Estratégia**
            • Confirme o valor exato que o cliente ofereceu.
            • Compare com seu preço mínimo (custo + margem mínima).
            • Use ancoragem: mostre o que está incluso no preço cheio.

            💬 **Sugestão de fala**
            "Entendi. Para esse valor preciso verificar com meu gerente — qual seria sua forma de pagamento se eu conseguir aprovar?"

            """
        }

        if let produto = produtos.first {
            resposta += contextoProduto(produto)
        }

        return resposta
    }

    private func respostaFechamento(texto: String, produtos: [Lancamento]) -> String {
        var resposta = """
        📌 **Situação:** momento de fechamento

        💡 **Gatilhos que funcionam**
        • **Urgência suave:** "Tenho mais um cliente interessado neste aparelho."
        • **Escassez real:** destaque unidades disponíveis no estoque.
        • **Benefício imediato:** transferência de dados, capa e película na hora.
        • **Facilite o pagamento:** PIX com desconto ou parcelamento estratégico.

        💬 **Frases de fechamento**
        • "Se fecharmos agora, já deixo tudo configurado para você sair usando."
        • "Consigo manter essa condição só até o final do dia — posso reservar?"
        • "Prefere PIX com desconto ou parcelamos no cartão?"

        """

        if let produto = produtos.first {
            resposta += "\n" + contextoProduto(produto)
            if produto.estaHaMuitoTempoNoEstoque {
                resposta += "\n⏱ Produto há \(produto.diasNoEstoque) dias no estoque — boa oportunidade para condição especial controlada.\n"
            }
        }

        return resposta
    }

    private func respostaObjecao(texto: String, produtos: [Lancamento]) -> String {
        let t = texto.lowercased()

        if t.contains("concorrente") {
            return """
            📌 **Objeção:** concorrência

            💡 **Estratégia**
            Não ataque o concorrente. Compare o que você entrega a mais: garantia, revisão, suporte e procedência.

            💬 **Sugestão de fala**
            "O preço é importante, mas o pós-venda também. Aqui você tem garantia, aparelho revisado e suporte direto comigo. Isso faz diferença no dia a dia."

            """ + (produtos.first.map { "\n" + contextoProduto($0) } ?? "")
        }

        if t.contains("pensar") || t.contains("depois") || t.contains("vou ver") {
            return """
            📌 **Objeção:** cliente quer pensar

            💡 **Estratégia**
            • Valide a decisão sem pressionar.
            • Crie motivo legítimo para retorno rápido (unidade, promoção, entrada de troca).
            • Agende follow-up com data e hora.

            💬 **Sugestão de fala**
            "Claro, é uma decisão importante. Posso reservar o aparelho por 24h para você? Assim você decide com calma sem correr o risco de perder essa unidade."

            """
        }

        return """
        📌 **Objeção:** preço alto

        💡 **Estratégia**
        • Quebre o valor em benefícios (custo por dia de uso, garantia, estado do aparelho).
        • Compare com modelo anterior ou novo — mostre custo-benefício.
        • Ofereça alternativa de modelo ou capacidade.

        💬 **Sugestão de fala**
        "Entendo. Este aparelho está \(produtos.first?.lacrado == true ? "lacrado" : "seminovo revisado") com garantia. Posso te mostrar uma opção que cabe melhor no seu orçamento sem perder qualidade."

        """ + (produtos.first.map { "\n" + contextoProduto($0) } ?? "")
    }

    private func respostaParcelamento(texto: String, valores: [Double], produtos: [Lancamento]) -> String {
        let valor = produtos.first?.valor ?? valores.first ?? 0
        let parcelas = detectarParcelas(texto) ?? 12
        let valorParcela = valor / Double(parcelas)

        return """
        📌 **Situação:** negociação de parcelamento

        💰 **Simulação** (\(parcelas)x sem juros estimado)
        • Valor: \(Formatters.brl(valor))
        • Parcela aproximada: **\(Formatters.brl(valorParcela))**

        💡 **Estratégia**
        • Ofereça desconto para PIX à vista antes de parcelar.
        • Se parcelar, use como ferramenta de fechamento, não como primeira opção.
        • Confirme taxas reais da maquininha antes de prometer.

        💬 **Sugestão de fala**
        "No PIX consigo um valor melhor. Se preferir parcelar, fica \(parcelas)x de aproximadamente \(Formatters.brl(valorParcela)) — posso reservar para você agora."

        """ + (produtos.first.map { "\n" + contextoProduto($0) } ?? "")
    }

    private func respostaGeral(texto: String, produtos: [Lancamento]) -> String {
        var resposta = """
        Entendi. Para te ajudar melhor, me conte:

        • Qual produto está em negociação?
        • Qual o preço de venda e o que o cliente ofereceu?
        • É desconto, troca ou objeção?

        Enquanto isso, aqui vão caminhos comuns:

        💡 **Desconto** → ancore valor, contrapropõe no meio-termo.
        💡 **Troca** → avalie o usado antes de falar diferença.
        💡 **Fechamento** → PIX com benefício ou reserva por 24h.

        """

        if let produto = produtos.first {
            resposta += contextoProduto(produto)
        }

        return resposta
    }

    // MARK: - Auxiliares

    private func estrategiaFechamentoRapido(valor: Double) -> String {
        """
        ✅ **Desconto pequeno — bom para fechar rápido.**

        💬 **Sugestão de fala**
        "Consigo fechar em \(Formatters.brl(valor)) para você levar hoje. Vou incluir a configuração básica sem custo."

        """
    }

    private func contextoProduto(_ produto: Lancamento) -> String {
        var info = """

        📦 **Produto no estoque**
        • \(produto.tituloExibicao) — \(Formatters.brl(produto.valor))
        • Status: \(produto.status.rawValue)
        """

        if let margem = produto.margemPercentual {
            info += "\n• Margem: \(String(format: "%.0f", margem))%"
        }
        if let custo = produto.custoCompra {
            let minimo = custo * 1.08
            info += "\n• Piso sugerido (custo + 8%): \(Formatters.brl(minimo))"
        }

        return info
    }

    private func detectarParcelas(_ texto: String) -> Int? {
        let padrao = #"(\d{1,2})\s*x"#
        guard let regex = try? NSRegularExpression(pattern: padrao, options: .caseInsensitive),
              let match = regex.firstMatch(in: texto, range: NSRange(texto.startIndex..., in: texto)),
              let range = Range(match.range(at: 1), in: texto),
              let parcelas = Int(texto[range]) else {
            return nil
        }
        return (2...24).contains(parcelas) ? parcelas : nil
    }

    private func valorOfertado(valores: [Double], precoReferencia: Double?) -> Double? {
        if valores.count >= 2 { return valores[1] }
        guard valores.count == 1 else { return nil }
        let valor = valores[0]
        if let preco = precoReferencia, valor < preco { return valor }
        if precoReferencia == nil { return valor }
        return nil
    }
}
