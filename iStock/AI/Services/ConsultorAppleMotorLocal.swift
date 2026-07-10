//
//  ConsultorAppleMotorLocal.swift
//  iStock
//

import Foundation

struct ConsultorAppleMotorLocal {

    private static let catalogo: [(chave: String, modelo: ModeloAppleDetectado)] = [
        ("iphone 16 pro max", ModeloAppleDetectado(
            chave: "iphone 16 pro max", nomeExibicao: "iPhone 16 Pro Max",
            geracao: 16, tier: .proMax,
            destaques: ["Tela maior de 6,9\"", "Chip A18 Pro", "Botão Captura", "Titânio", "Zoom óptico avançado"],
            argumentosVenda: ["Máxima autonomia da linha", "Melhor câmera para quem grava muito", "Tela ProMotion 120 Hz"]
        )),
        ("iphone 16 pro", ModeloAppleDetectado(
            chave: "iphone 16 pro", nomeExibicao: "iPhone 16 Pro",
            geracao: 16, tier: .pro,
            destaques: ["Chip A18 Pro", "Botão Captura", "Titânio", "USB-C 3", "Apple Intelligence"],
            argumentosVenda: ["Equilíbrio ideal entre tamanho e performance", "Câmera Pro com zoom óptico", "Acabamento premium em titânio"]
        )),
        ("iphone 16", ModeloAppleDetectado(
            chave: "iphone 16", nomeExibicao: "iPhone 16",
            geracao: 16, tier: .regular,
            destaques: ["Chip A18", "Botão Ação", "Câmera de 48 MP", "USB-C"],
            argumentosVenda: ["Geração atual com ótimo custo-benefício", "Novos recursos sem pagar linha Pro", "Excelente para upgrade de modelos antigos"]
        )),
        ("iphone 15 pro max", ModeloAppleDetectado(
            chave: "iphone 15 pro max", nomeExibicao: "iPhone 15 Pro Max",
            geracao: 15, tier: .proMax,
            destaques: ["Chip A17 Pro", "Titânio", "Zoom 5x", "USB-C 3", "Tela 6,7\""],
            argumentosVenda: ["Preço mais acessível que o 16 Pro Max", "Câmera teleobjetiva de altíssima qualidade", "Ótimo para criadores de conteúdo"]
        )),
        ("iphone 15 pro", ModeloAppleDetectado(
            chave: "iphone 15 pro", nomeExibicao: "iPhone 15 Pro",
            geracao: 15, tier: .pro,
            destaques: ["Chip A17 Pro", "Titânio", "Botão Ação", "USB-C 3"],
            argumentosVenda: ["Performance de ponta ainda muito atual", "Tamanho confortável para uso com uma mão", "Excelente revenda e durabilidade"]
        )),
        ("iphone 15 plus", ModeloAppleDetectado(
            chave: "iphone 15 plus", nomeExibicao: "iPhone 15 Plus",
            geracao: 15, tier: .plus,
            destaques: ["Tela grande 6,7\"", "Chip A16", "Ótima bateria", "USB-C"],
            argumentosVenda: ["Grande tela sem preço Pro", "Autonomia superior para quem usa muito", "Ideal para consumo de mídia"]
        )),
        ("iphone 15", ModeloAppleDetectado(
            chave: "iphone 15", nomeExibicao: "iPhone 15",
            geracao: 15, tier: .regular,
            destaques: ["Chip A16", "Câmera 48 MP", "Ilha Dinâmica", "USB-C"],
            argumentosVenda: ["Primeiro iPhone com USB-C na linha regular", "Salto grande vindo do 12/13", "Design com cores vibrantes e vidro fosco"]
        )),
        ("iphone 14 pro max", ModeloAppleDetectado(
            chave: "iphone 14 pro max", nomeExibicao: "iPhone 14 Pro Max",
            geracao: 14, tier: .proMax,
            destaques: ["Dynamic Island", "Chip A16", "Always-On Display", "Câmera 48 MP"],
            argumentosVenda: ["Excelente custo-benefício seminovo", "Tela ProMotion ainda muito competitiva", "Câmera Pro com modo ação"]
        )),
        ("iphone 14 pro", ModeloAppleDetectado(
            chave: "iphone 14 pro", nomeExibicao: "iPhone 14 Pro",
            geracao: 14, tier: .pro,
            destaques: ["Dynamic Island", "Chip A16", "Always-On", "Câmera 48 MP"],
            argumentosVenda: ["Pro com preço menor que gerações novas", "Compacto com tela premium", "Ainda recebe atualizações por muitos anos"]
        )),
        ("iphone 14 plus", ModeloAppleDetectado(
            chave: "iphone 14 plus", nomeExibicao: "iPhone 14 Plus",
            geracao: 14, tier: .plus,
            destaques: ["Tela 6,7\"", "Chip A15", "Bateria de longa duração"],
            argumentosVenda: ["Tela grande com preço acessível", "Bateria que dura o dia todo", "Ótimo para quem não precisa de câmera Pro"]
        )),
        ("iphone 14", ModeloAppleDetectado(
            chave: "iphone 14", nomeExibicao: "iPhone 14",
            geracao: 14, tier: .regular,
            destaques: ["Chip A15", "Câmera dupla", "Detecção de acidente", "eSIM"],
            argumentosVenda: ["Entrada acessível na linha atual", "Segurança com detecção de acidente", "Performance sólida para uso cotidiano"]
        )),
        ("iphone 13 pro max", ModeloAppleDetectado(
            chave: "iphone 13 pro max", nomeExibicao: "iPhone 13 Pro Max",
            geracao: 13, tier: .proMax,
            destaques: ["Chip A15", "ProMotion 120 Hz", "Bateria excelente", "Macro"],
            argumentosVenda: ["Seminovo com ótimo preço", "Bateria ainda muito respeitada", "ProMotion faz diferença no dia a dia"]
        )),
        ("iphone 13 pro", ModeloAppleDetectado(
            chave: "iphone 13 pro", nomeExibicao: "iPhone 13 Pro",
            geracao: 13, tier: .pro,
            destaques: ["Chip A15", "ProMotion", "Modo Cinema", "Macro"],
            argumentosVenda: ["Custo-benefício forte no seminovo", "Câmera tripla ainda excelente", "Tamanho ideal para quem quer Pro compacto"]
        )),
        ("iphone 13", ModeloAppleDetectado(
            chave: "iphone 13", nomeExibicao: "iPhone 13",
            geracao: 13, tier: .regular,
            destaques: ["Chip A15", "Bateria melhorada", "Modo Cinema", "5G"],
            argumentosVenda: ["Um dos melhores seminovos do mercado", "Performance ainda atual", "Ótimo para quem quer economizar sem sacrificar muito"]
        )),
        ("iphone se", ModeloAppleDetectado(
            chave: "iphone se", nomeExibicao: "iPhone SE",
            geracao: 12, tier: .se,
            destaques: ["Touch ID", "Chip A15", "Design compacto", "Preço menor"],
            argumentosVenda: ["Melhor porta de entrada Apple", "Ideal para quem prefere botão Home", "Compacto e prático"]
        )),
        ("ipad pro", ModeloAppleDetectado(
            chave: "ipad pro", nomeExibicao: "iPad Pro",
            geracao: 0, tier: .regular,
            destaques: ["Chip M-series", "Apple Pencil Pro", "Tela Liquid Retina XDR", "Magic Keyboard"],
            argumentosVenda: ["Substitui notebook para muitos perfis", "Criadores e profissionais", "Integração total com iPhone"]
        )),
        ("ipad air", ModeloAppleDetectado(
            chave: "ipad air", nomeExibicao: "iPad Air",
            geracao: 0, tier: .regular,
            destaques: ["Chip M1/M2", "Apple Pencil", "Tela 11\"/13\"", "Leve e versátil"],
            argumentosVenda: ["Meio-termo perfeito entre iPad e Pro", "Estudantes e profissionais", "Ótimo para desenho e produtividade"]
        )),
        ("macbook air", ModeloAppleDetectado(
            chave: "macbook air", nomeExibicao: "MacBook Air",
            geracao: 0, tier: .regular,
            destaques: ["Chip M-series", "Sem ventoinha", "Ultrafino", "Bateria de dia inteiro"],
            argumentosVenda: ["Portátil silencioso e leve", "Ideal para estudo e trabalho", "Ecossistema com iPhone"]
        )),
        ("macbook pro", ModeloAppleDetectado(
            chave: "macbook pro", nomeExibicao: "MacBook Pro",
            geracao: 0, tier: .pro,
            destaques: ["Chip M Pro/Max", "Tela XDR", "Portas Pro", "Performance profissional"],
            argumentosVenda: ["Para edição, código e tarefas pesadas", "Investimento de longo prazo", "Continuidade com iPhone e iPad"]
        )),
        ("airpods pro", ModeloAppleDetectado(
            chave: "airpods pro", nomeExibicao: "AirPods Pro",
            geracao: 0, tier: .pro,
            destaques: ["Cancelamento ativo de ruído", "Áudio espacial", "Case com localização"],
            argumentosVenda: ["Experiência premium com iPhone", "Chamadas e reuniões com qualidade", "Troca automática entre dispositivos Apple"]
        )),
        ("airpods", ModeloAppleDetectado(
            chave: "airpods", nomeExibicao: "AirPods",
            geracao: 0, tier: .regular,
            destaques: ["Pareamento instantâneo", "Áudio espacial", "Case compacto"],
            argumentosVenda: ["Acessório que completa o ecossistema", "Conforto para uso diário", "Integração perfeita com Siri"]
        )),
        ("apple watch", ModeloAppleDetectado(
            chave: "apple watch", nomeExibicao: "Apple Watch",
            geracao: 0, tier: .regular,
            destaques: ["Saúde e fitness", "Notificações no pulso", "Desbloqueio do Mac", "ECG e oxímetro"],
            argumentosVenda: ["Complemento ideal do iPhone", "Motivação para saúde", "Segurança com detecção de queda e acidente"]
        )),
    ]

    func responder(pergunta: String, contexto: ContextoConsultorApple) -> String {
        let texto = pergunta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return mensagemBoasVindas(modo: contexto.modo) }

        let intencao = detectarIntencao(texto)
        let modelos = detectarModelos(no: texto)
        let produtosEstoque = detectarProdutosEstoque(no: texto, estoque: contexto.produtosEstoque)

        switch intencao {
        case .comparacao:
            return respostaComparacao(texto: texto, modelos: modelos, modo: contexto.modo, estoque: produtosEstoque)
        case .argumentos:
            return respostaArgumentos(modelos: modelos, modo: contexto.modo, estoque: produtosEstoque)
        case .ecossistema:
            return respostaEcossistema(texto: texto, modelos: modelos, modo: contexto.modo)
        case .especificacoes:
            return respostaEspecificacoes(modelos: modelos, modo: contexto.modo)
        case .geral:
            return respostaGeral(texto: texto, modelos: modelos, modo: contexto.modo, estoque: produtosEstoque)
        }
    }

    func mensagemBoasVindas(modo: ModoConsultorApple) -> String {
        switch modo {
        case .cliente:
            return """
            Olá! Sou seu Consultor Apple para vendas.

            Posso ajudar com:
            • **Argumentos de venda** para qualquer modelo
            • **Comparação** entre iPhones, iPads e Macs
            • **Benefícios do ecossistema** Apple

            Descreva o cliente ou a dúvida dele. Exemplo:
            "Cliente está em dúvida entre iPhone 14 e 15 Pro"
            """
        case .pessoal:
            return """
            Olá! Modo consulta técnica e comercial.

            Pergunte sobre diferenças entre modelos, argumentos de venda ou como o ecossistema Apple se integra.

            Exemplo:
            "Quais as vantagens do iPhone 15 Pro sobre o 14?"
            """
        }
    }

    // MARK: - Detecção

    private func detectarIntencao(_ texto: String) -> IntencaoConsultorApple {
        let t = texto.lowercased()

        let regras: [(IntencaoConsultorApple, [String])] = [
            (.comparacao, ["comparar", "comparação", "comparacao", "diferença", "diferenca", " vs ", " versus ", " ou ", "melhor que", "vale a pena", "qual escolher", "entre o", "entre a"]),
            (.ecossistema, ["ecossistema", "icloud", "airdrop", "continuidade", "handoff", "integração", "integracao", "já tem mac", "ja tem mac", "já tem ipad", "universal clipboard", "ecossistema apple"]),
            (.argumentos, ["argumento", "argumentos", "vender", "convencer", "por que comprar", "porque comprar", "diferencial", "vantagem", "como vender", "pitch", "falar para o cliente"]),
            (.especificacoes, ["bateria", "câmera", "camera", "tela", "chip", "especificação", "especificacao", "quantos gb", "armazenamento", "desempenho"]),
        ]

        var pontuacao: [IntencaoConsultorApple: Int] = [:]
        for (intencao, palavras) in regras {
            pontuacao[intencao] = palavras.reduce(0) { $0 + (t.contains($1) ? 1 : 0) }
        }

        if detectarModelos(no: texto).count >= 2 {
            return .comparacao
        }

        if let melhor = pontuacao.max(by: { $0.value < $1.value }), melhor.value > 0 {
            return melhor.key
        }

        return detectarModelos(no: texto).isEmpty ? .geral : .argumentos
    }

    func detectarModelos(no texto: String) -> [ModeloAppleDetectado] {
        let t = texto.lowercased()
        var encontrados: [ModeloAppleDetectado] = []
        var chavesUsadas: Set<String> = []

        for (chave, modelo) in Self.catalogo {
            if t.contains(chave), !chavesUsadas.contains(chave) {
                if chave == "airpods", t.contains("airpods pro") { continue }
                if chave == "iphone 15", t.contains("iphone 15 pro") || t.contains("iphone 15 plus") { continue }
                if chave == "iphone 14", t.contains("iphone 14 pro") || t.contains("iphone 14 plus") { continue }
                if chave == "iphone 13", t.contains("iphone 13 pro") { continue }
                if chave == "iphone 16", t.contains("iphone 16 pro") { continue }
                encontrados.append(modelo)
                chavesUsadas.insert(chave)
            }
        }

        return encontrados.sorted { $0.geracao > $1.geracao }
    }

    private func detectarProdutosEstoque(no texto: String, estoque: [Lancamento]) -> [Lancamento] {
        let t = texto.lowercased()
        return estoque.filter { produto in
            guard produto.estaNoEstoque else { return false }
            let termos = [produto.modelo, produto.nome, produto.tipoProduto.rawValue]
                .compactMap { $0?.lowercased() }
            return termos.contains { $0.count >= 4 && t.contains($0) }
        }
    }

    // MARK: - Respostas

    private func respostaComparacao(
        texto: String,
        modelos: [ModeloAppleDetectado],
        modo: ModoConsultorApple,
        estoque: [Lancamento]
    ) -> String {
        guard modelos.count >= 2 else {
            return respostaComparacaoGenerica(texto: texto, modelos: modelos, modo: modo)
        }

        let a = modelos[0]
        let b = modelos[1]

        var resposta = "📌 **Comparação:** \(a.nomeExibicao) vs \(b.nomeExibicao)\n\n"

        resposta += "⚖️ **Diferenças principais**\n"
        resposta += compararModelos(a, b)

        resposta += "\n💡 **Para quem é cada um**\n"
        resposta += "• **\(a.nomeExibicao):** \(perfilCliente(para: a))\n"
        resposta += "• **\(b.nomeExibicao):** \(perfilCliente(para: b))\n\n"

        resposta += fraseVenda(
            modo: modo,
            texto: """
            "Se você quer \(resumoEscolha(a)), o \(a.nomeExibicao) é a melhor escolha. Se prefere \(resumoEscolha(b)), o \(b.nomeExibicao) entrega mais valor para o seu uso."
            """
        )

        if !estoque.isEmpty {
            resposta += "\n\n" + contextoEstoque(estoque)
        }

        return resposta
    }

    private func respostaComparacaoGenerica(texto: String, modelos: [ModeloAppleDetectado], modo: ModoConsultorApple) -> String {
        if let modelo = modelos.first {
            return respostaArgumentos(modelos: [modelo], modo: modo, estoque: [])
        }

        return """
        📌 **Comparação de modelos**

        Me diga quais dois modelos comparar. Exemplos:
        • iPhone 14 vs iPhone 15
        • iPhone 15 vs 15 Pro
        • iPhone 13 vs iPhone 15

        💡 **Regra rápida**
        • **Regular** → melhor custo-benefício
        • **Plus** → tela grande e bateria
        • **Pro** → câmera, tela 120 Hz e chip top
        • **Pro Max** → tudo máximo + bateria campeã

        \(fraseVenda(modo: modo, texto: "\"Qual seu uso principal: fotos, jogos, trabalho ou redes sociais? Assim indico o modelo certo.\""))
        """
    }

    private func respostaArgumentos(
        modelos: [ModeloAppleDetectado],
        modo: ModoConsultorApple,
        estoque: [Lancamento]
    ) -> String {
        let modelo = modelos.first

        guard let modelo else {
            return """
            📌 **Argumentos de venda**

            Qual produto você quer vender? Informe o modelo (ex: iPhone 15 Pro) e monto os argumentos.

            💡 **Argumentos universais Apple**
            • Atualizações por 5+ anos
            • Revenda com valor residual alto
            • Privacidade e segurança integradas
            • Ecossistema que funciona junto

            \(fraseVenda(modo: modo, texto: "\"Apple não é só aparelho — é experiência que dura e vale na troca futura.\""))
            """
        }

        var resposta = "📌 **Argumentos para \(modelo.nomeExibicao)**\n\n"

        resposta += "✨ **Destaques do produto**\n"
        for destaque in modelo.destaques {
            resposta += "• \(destaque)\n"
        }

        resposta += "\n🎯 **Por que o cliente deve levar**\n"
        for argumento in modelo.argumentosVenda {
            resposta += "• \(argumento)\n"
        }

        resposta += "\n" + argumentosPorTier(modelo)

        resposta += "\n" + fraseVenda(
            modo: modo,
            texto: fraseArgumentoPronta(para: modelo)
        )

        if !estoque.isEmpty {
            resposta += "\n\n" + contextoEstoque(estoque)
        }

        return resposta
    }

    private func respostaEcossistema(texto: String, modelos: [ModeloAppleDetectado], modo: ModoConsultorApple) -> String {
        let t = texto.lowercased()
        var resposta = "📌 **Ecossistema Apple**\n\n"

        if t.contains("mac") || modelos.contains(where: { $0.chave.contains("macbook") }) {
            resposta += blocoEcossistemaMac
        } else if t.contains("ipad") || modelos.contains(where: { $0.chave.contains("ipad") }) {
            resposta += blocoEcossistemaIPad
        } else if t.contains("watch") || t.contains("relógio") || t.contains("relogio") {
            resposta += blocoEcossistemaWatch
        } else if t.contains("airpods") {
            resposta += blocoEcossistemaAirPods
        } else {
            resposta += blocoEcossistemaGeral
        }

        resposta += "\n" + fraseVenda(
            modo: modo,
            texto: """
            "Quanto mais dispositivos Apple você usa, mais tudo se conecta — fotos, senhas, chamadas e arquivos fluem sem você perder tempo configurando."
            """
        )

        return resposta
    }

    private func respostaEspecificacoes(modelos: [ModeloAppleDetectado], modo: ModoConsultorApple) -> String {
        guard let modelo = modelos.first else {
            return "Informe o modelo para eu detalhar especificações. Ex: iPhone 15 Pro"
        }

        var resposta = "📌 **\(modelo.nomeExibicao) — especificações-chave**\n\n"
        for destaque in modelo.destaques {
            resposta += "• \(destaque)\n"
        }

        if modelo.geracao > 0 {
            resposta += "\n📱 Geração \(modelo.geracao) — ainda recebe atualizações iOS por vários anos.\n"
        }

        resposta += "\n" + fraseVenda(
            modo: modo,
            texto: "\"Na prática, o que importa é como isso melhora seu dia a dia — quer que eu compare com outro modelo?\""
        )

        return resposta
    }

    private func respostaGeral(
        texto: String,
        modelos: [ModeloAppleDetectado],
        modo: ModoConsultorApple,
        estoque: [Lancamento]
    ) -> String {
        if modelos.count >= 2 {
            return respostaComparacao(texto: texto, modelos: modelos, modo: modo, estoque: estoque)
        }
        if let modelo = modelos.first {
            return respostaArgumentos(modelos: [modelo], modo: modo, estoque: estoque)
        }

        return """
        Posso ajudar de três formas:

        🔹 **Argumentos de venda** — diga o modelo
        🔹 **Comparação** — ex: "iPhone 14 ou 15 Pro?"
        🔹 **Ecossistema** — integração iPhone + Mac + iPad + Watch

        \(fraseVenda(modo: modo, texto: "\"O que o cliente mais valoriza: câmera, bateria, tamanho de tela ou orçamento?\""))
        """
    }

    // MARK: - Comparação

    private func compararModelos(_ a: ModeloAppleDetectado, _ b: ModeloAppleDetectado) -> String {
        var linhas: [String] = []

        if a.geracao != b.geracao {
            linhas.append("• Geração: \(a.nomeExibicao) (\(a.geracao)) é mais recente que \(b.nomeExibicao) (\(b.geracao))")
        }

        if a.tier != b.tier {
            linhas.append("• Linha: \(a.nomeExibicao) é \(rotuloTier(a.tier)), \(b.nomeExibicao) é \(rotuloTier(b.tier))")
        }

        let exclusivosA = a.destaques.filter { !b.destaques.contains($0) }.prefix(2)
        let exclusivosB = b.destaques.filter { !a.destaques.contains($0) }.prefix(2)

        if !exclusivosA.isEmpty {
            linhas.append("• Só no \(a.nomeExibicao): \(exclusivosA.joined(separator: ", "))")
        }
        if !exclusivosB.isEmpty {
            linhas.append("• Só no \(b.nomeExibicao): \(exclusivosB.joined(separator: ", "))")
        }

        if linhas.isEmpty {
            linhas.append("• Modelos muito próximos — diferencie pelo preço, estado e garantia oferecida")
        }

        return linhas.joined(separator: "\n") + "\n"
    }

    private func perfilCliente(para modelo: ModeloAppleDetectado) -> String {
        switch modelo.tier {
        case .se: return "quem quer entrar no ecossistema gastando menos"
        case .regular: return "uso cotidiano com ótimo equilíbrio"
        case .plus: return "tela grande e bateria sem pagar linha Pro"
        case .pro: return "câmera avançada e performance máxima em tamanho compacto"
        case .proMax: return "tudo ao máximo — tela, câmera e autonomia"
        }
    }

    private func resumoEscolha(_ modelo: ModeloAppleDetectado) -> String {
        switch modelo.tier {
        case .se: return "simplicidade e preço"
        case .regular: return "equilíbrio"
        case .plus: return "tela grande"
        case .pro: return "câmera e performance Pro"
        case .proMax: return "o melhor disponível"
        }
    }

    private func rotuloTier(_ tier: ModeloAppleDetectado.TierIPhone) -> String {
        switch tier {
        case .se: return "linha SE (compacto)"
        case .regular: return "linha regular"
        case .plus: return "linha Plus"
        case .pro: return "linha Pro"
        case .proMax: return "linha Pro Max"
        }
    }

    // MARK: - Argumentos

    private func argumentosPorTier(_ modelo: ModeloAppleDetectado) -> String {
        switch modelo.tier {
        case .pro, .proMax:
            return """
            
            🏆 **Diferencial Pro**
            • Tela ProMotion 120 Hz — navegação muito mais fluida
            • Câmeras com zoom óptico e modo ProRAW
            • Chip mais potente para jogos e edição de vídeo
            • Materiais premium (aço inox / titânio)

            """
        case .plus:
            return """
            
            📱 **Diferencial Plus**
            • Tela grande ideal para vídeos e leitura
            • Bateria superior à linha regular
            • Mesma experiência iOS sem complexidade Pro

            """
        case .regular:
            return """
            
            ✅ **Diferencial Regular**
            • Melhor relação preço x recursos
            • Performance excelente para 95% dos usuários
            • Cores e design atraentes

            """
        case .se:
            return """
            
            💰 **Diferencial SE**
            • Menor investimento para ecossistema Apple
            • Touch ID preferido por muitos clientes
            • Compacto e resistente

            """
        }
    }

    private func fraseArgumentoPronta(para modelo: ModeloAppleDetectado) -> String {
        "\"O \(modelo.nomeExibicao) é ideal se você busca \(perfilCliente(para: modelo)). Além disso, com Apple você tem atualizações por anos e excelente valor na hora da troca.\""
    }

    // MARK: - Ecossistema

    private var blocoEcossistemaGeral: String {
        """
        🔗 **Integração entre dispositivos**
        • **AirDrop** — envie fotos e arquivos instantaneamente
        • **Handoff** — comece no iPhone, continue no Mac/iPad
        • **Clipboard Universal** — copie em um, cole em outro
        • **iCloud** — fotos, backup e senhas sincronizados
        • **Continuidade** — atenda chamadas do iPhone no Mac/iPad
        • **AirPods** — troca automática entre dispositivos logados

        👨‍👩‍👧 **Família**
        • Compartilhamento de compras, iCloud+ e localização com Família

        """
    }

    private var blocoEcossistemaMac: String {
        blocoEcossistemaGeral + """
        💻 **iPhone + Mac**
        • Desbloqueie o Mac com Apple Watch ou iPhone
        • Fotos do iPhone aparecem no Fotos do Mac via iCloud
        • Sidecar: use o iPad como segunda tela do Mac
        • AirDrop para transferir arquivos sem cabo

        """
    }

    private var blocoEcossistemaIPad: String {
        blocoEcossistemaGeral + """
        📱 **iPhone + iPad**
        • Mesmas apps otimizadas — experiência consistente
        • Universal Clipboard entre os dois
        • iPad como tela auxiliar (Sidecar com Mac)
        • Apple Pencil para anotações que sincronizam

        """
    }

    private var blocoEcossistemaWatch: String {
        """
        ⌚ **iPhone + Apple Watch**
        • Notificações e chamadas no pulso
        • Desbloqueio automático do Mac e iPhone
        • Saúde integrada: ECG, sono, atividade
        • Find My para localizar dispositivos

        """
    }

    private var blocoEcossistemaAirPods: String {
        """
        🎧 **AirPods + iPhone**
        • Pareamento instantâneo com chip H-series
        • Troca automática entre iPhone, iPad e Mac
        • "Ei Siri" e áudio espacial
        • Localização precisa no Buscar

        """
    }

    // MARK: - Auxiliares

    private func fraseVenda(modo: ModoConsultorApple, texto: String) -> String {
        switch modo {
        case .cliente: return "💬 **Sugestão de fala**\n\(texto)"
        case .pessoal: return "💡 **Resumo**\n\(texto)"
        }
    }

    private func contextoEstoque(_ produtos: [Lancamento]) -> String {
        var info = "📦 **Disponível na sua loja**\n"
        for produto in produtos.prefix(3) {
            info += "• \(produto.tituloExibicao) — \(Formatters.brl(produto.valor))"
            if produto.lacrado { info += " (lacrado)" }
            info += "\n"
        }
        return info
    }
}
