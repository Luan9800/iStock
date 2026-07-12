//
//  ModeloDefeitosService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation

enum ModeloDefeitosService {
    private struct Entrada {
        let padroes: [String]
        let tipos: [TipoProduto]?
        let problemas: [ProblemaModelo]
    }

    private static let base: [Entrada] = [
        Entrada(
            padroes: ["iphone 6 plus", "6 plus"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "touch-disease", titulo: "Touch Disease", descricao: "Linha cinza no topo da tela e perda de toque por flexão da placa.", gravidade: .alto),
                ProblemaModelo(id: "bateria-6plus", titulo: "Bateria inchada", descricao: "Modelos antigos com risco de deformação da carcaça.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["iphone 6", "iphone 6s"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "touch-6", titulo: "Falhas de toque", descricao: "Solda da placa lógica pode causar toque intermitente.", gravidade: .alto),
                ProblemaModelo(id: "botao-6", titulo: "Botão Home", descricao: "Desgaste do botão Home em unidades muito usadas.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["iphone x", "iphone xs", "iphone xs max"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "boot-x", titulo: "Boot loop", descricao: "Algumas unidades reiniciam em loop após atualizações ou queda.", gravidade: .alto),
                ProblemaModelo(id: "oled-x", titulo: "Burn-in OLED", descricao: "Retenção de imagem em telas com uso prolongado.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["iphone 11"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "tela-11", titulo: "Troca de tela", descricao: "Mensagem de peça desconhecida em telas não originais.", gravidade: .leve),
                ProblemaModelo(id: "audio-11", titulo: "Microfone", descricao: "Relatos de áudio abafado em chamadas em alguns lotes.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["iphone 12", "iphone 12 mini"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "5g-12", titulo: "Consumo 5G", descricao: "Autonomia reduzida com 5G sempre ativo.", gravidade: .leve),
                ProblemaModelo(id: "tela-12", titulo: "Peça de display", descricao: "Verificar se há alerta de display não original.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["iphone 13"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "pink-13", titulo: "Tom rosado", descricao: "Modelo rosa pode apresentar descoloração em algumas unidades.", gravidade: .leve),
                ProblemaModelo(id: "face-13", titulo: "Face ID", descricao: "Testar Face ID após queda ou troca de tela frontal.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["iphone 14 pro", "iphone 14 pro max"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "camera-14pro", titulo: "Ruído na câmera", descricao: "Algumas unidades apresentam chiado ao gravar vídeo.", gravidade: .moderado),
                ProblemaModelo(id: "always-14pro", titulo: "Always-On", descricao: "Consumo elevado com tela sempre ativa.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["iphone 15 pro", "iphone 15 pro max", "iphone 15"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "heat-15", titulo: "Aquecimento", descricao: "Primeiros lotes relataram aquecimento em jogos e carga rápida.", gravidade: .moderado),
                ProblemaModelo(id: "titanium-15", titulo: "Acabamento titânio", descricao: "Verificar riscos e quedas de tinta nas bordas.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["iphone se"],
            tipos: [.iphone],
            problemas: [
                ProblemaModelo(id: "bateria-se", titulo: "Autonomia", descricao: "Bateria pequena; desgaste acentuado em uso intenso.", gravidade: .moderado),
                ProblemaModelo(id: "touch-se", titulo: "Touch ID", descricao: "Botão Home integrado — verificar desgaste e umidade.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["ipad pro"],
            tipos: [.ipad],
            problemas: [
                ProblemaModelo(id: "bend-ipad", titulo: "Flexão da carcaça", descricao: "Modelos finos podem entortar em mochilas apertadas.", gravidade: .moderado),
                ProblemaModelo(id: "pencil-ipad", titulo: "Apple Pencil", descricao: "Confirmar geração compatível do Pencil.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["ipad air"],
            tipos: [.ipad],
            problemas: [
                ProblemaModelo(id: "display-air", titulo: "Display", descricao: "Verificar manchas ou dead pixels em telas usadas.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["macbook pro"],
            tipos: [.macbook],
            problemas: [
                ProblemaModelo(id: "keyboard-butterfly", titulo: "Teclado butterfly", descricao: "Modelos 2016–2019: teclas travando ou repetindo.", gravidade: .alto),
                ProblemaModelo(id: "flexgate", titulo: "Flexgate", descricao: "Cabo da tela pode falhar — brilho irregular ou apagão.", gravidade: .alto),
                ProblemaModelo(id: "bateria-mbp", titulo: "Bateria", descricao: "Verificar ciclos e inchamento em modelos antigos.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["macbook air"],
            tipos: [.macbook],
            problemas: [
                ProblemaModelo(id: "fan-air", titulo: "Ventoinha", descricao: "Modelos Intel podem ficar ruidosos com poeira.", gravidade: .leve),
                ProblemaModelo(id: "m1-air", titulo: "M1/M2", descricao: "Sem ventoinha — monitorar thermal throttling em cargas longas.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["airpods pro"],
            tipos: [.airpods],
            problemas: [
                ProblemaModelo(id: "crackle-app", titulo: "Chiado / estalo", descricao: "Programa de substituição Apple para unidades até out/2020.", gravidade: .alto),
                ProblemaModelo(id: "anc-app", titulo: "ANC enfraquecido", descricao: "Cancelamento de ruído pode degradar com o tempo.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["airpods"],
            tipos: [.airpods],
            problemas: [
                ProblemaModelo(id: "bateria-ap", titulo: "Bateria dos fones", descricao: "Autonomia cai bastante após 2–3 anos de uso.", gravidade: .moderado),
                ProblemaModelo(id: "case-ap", titulo: "Case", descricao: "Verificar se o case carrega e pareia corretamente.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["apple watch series 0", "series 1", "series 2", "series 3"],
            tipos: [.appleWatch, .watch],
            problemas: [
                ProblemaModelo(id: "battery-watch", titulo: "Bateria inchada", descricao: "Modelos antigos com risco de tela elevada.", gravidade: .alto)
            ]
        ),
        Entrada(
            padroes: ["apple watch"],
            tipos: [.appleWatch, .watch],
            problemas: [
                ProblemaModelo(id: "screen-watch", titulo: "Tela", descricao: "Verificar riscos e touch após impactos.", gravidade: .moderado),
                ProblemaModelo(id: "digital-crown", titulo: "Digital Crown", descricao: "Coroa pode endurecer com sujeira ou umidade.", gravidade: .leve)
            ]
        ),
        Entrada(
            padroes: ["apple tv"],
            tipos: [.appleTV],
            problemas: [
                ProblemaModelo(id: "remote-atv", titulo: "Controle remoto", descricao: "Verificar botões e bateria do Siri Remote.", gravidade: .leve),
                ProblemaModelo(id: "hdmi-atv", titulo: "HDMI / rede", descricao: "Testar saída 4K e conexão Wi‑Fi estável.", gravidade: .moderado)
            ]
        ),
        Entrada(
            padroes: ["magic mouse"],
            tipos: [.mouse],
            problemas: [
                ProblemaModelo(id: "scroll-mouse", titulo: "Scroll", descricao: "Superfície de scroll pode falhar com desgaste.", gravidade: .moderado),
                ProblemaModelo(id: "charge-mouse", titulo: "Carga inferior", descricao: "Modelo Lightning não pode ser usado durante a carga.", gravidade: .leve)
            ]
        )
    ]

    static func buscar(tipo: TipoProduto, modelo: String?) -> [ProblemaModelo] {
        guard let modelo, !modelo.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let texto = modelo.lowercased()
        var encontrados: [ProblemaModelo] = []
        var ids = Set<String>()

        for entrada in base {
            if let tipos = entrada.tipos, !tipos.contains(tipo) { continue }
            let combina = entrada.padroes.contains { padrao in
                texto.contains(padrao) || padrao.contains(texto)
            }
            guard combina else { continue }
            for problema in entrada.problemas where ids.insert(problema.id).inserted {
                encontrados.append(problema)
            }
        }

        if encontrados.isEmpty {
            encontrados = problemasGenericos(para: tipo)
        }

        return encontrados.sorted { $0.gravidade.rawValue > $1.gravidade.rawValue }
    }

    static func resumo(_ problemas: [ProblemaModelo]) -> String? {
        guard !problemas.isEmpty else { return nil }
        return problemas.map { "• \($0.titulo): \($0.descricao)" }.joined(separator: "\n")
    }

    struct ResultadoPesquisa {
        let modeloIdentificado: String?
        let numeracaoIdentificada: String?
        let tipoProduto: TipoProduto?
        let problemas: [ProblemaModelo]
        let encontrouCorrespondencia: Bool

        var temResultado: Bool {
            encontrouCorrespondencia && !problemas.isEmpty
        }
    }

    static func pesquisar(tipo: TipoProduto?, modelo: String?, numeracao: String?) -> ResultadoPesquisa {
        let modeloTexto = modelo?.trimmingCharacters(in: .whitespacesAndNewlines)
        let numeroTexto = numeracao?.trimmingCharacters(in: .whitespacesAndNewlines)

        let modeloVazio = modeloTexto?.isEmpty != false
        let numeroVazio = numeroTexto?.isEmpty != false

        guard !modeloVazio || !numeroVazio else {
            return ResultadoPesquisa(
                modeloIdentificado: nil,
                numeracaoIdentificada: nil,
                tipoProduto: tipo,
                problemas: [],
                encontrouCorrespondencia: false
            )
        }

        var tipoResolvido = tipo
        var nomeModelo = modeloVazio ? nil : modeloTexto
        var codigoResolvido: String?

        if let numeroTexto, !numeroVazio {
            let codigo = normalizarNumeracao(numeroTexto)
            if let mapeado = mapeamentoNumeracao[codigo] {
                codigoResolvido = codigo
                if nomeModelo == nil { nomeModelo = mapeado.nome }
                if tipoResolvido == nil { tipoResolvido = mapeado.tipo }
            } else if codigo.hasPrefix("A"), codigo.count >= 4 {
                codigoResolvido = codigo
            }
        }

        let tipoFinal = tipoResolvido ?? .iphone
        var problemas: [ProblemaModelo] = []
        var encontrou = false

        if let nomeModelo, !nomeModelo.isEmpty {
            problemas = buscar(tipo: tipoFinal, modelo: nomeModelo)
            encontrou = !problemas.isEmpty
        }

        if problemas.isEmpty, let codigoResolvido, let mapeado = mapeamentoNumeracao[codigoResolvido] {
            nomeModelo = mapeado.nome
            tipoResolvido = mapeado.tipo
            problemas = buscar(tipo: mapeado.tipo, modelo: mapeado.nome)
            encontrou = !problemas.isEmpty
        }

        if problemas.isEmpty, let tipoResolvido {
            problemas = problemasGenericos(para: tipoResolvido)
            encontrou = !modeloVazio || codigoResolvido != nil
        }

        return ResultadoPesquisa(
            modeloIdentificado: nomeModelo,
            numeracaoIdentificada: codigoResolvido ?? (numeroVazio ? nil : normalizarNumeracao(numeroTexto ?? "")),
            tipoProduto: tipoResolvido ?? tipoFinal,
            problemas: problemas,
            encontrouCorrespondencia: encontrou
        )
    }

    static func sugestoesModelo() -> [String] {
        [
            "iPhone 15 Pro",
            "iPhone 14 Pro",
            "iPhone 13",
            "iPhone 11",
            "iPhone X",
            "MacBook Pro",
            "AirPods Pro",
            "Apple Watch"
        ]
    }

    private struct MapeamentoNumeracao {
        let nome: String
        let tipo: TipoProduto
    }

    private static let mapeamentoNumeracao: [String: MapeamentoNumeracao] = [
        "A2849": .init(nome: "iPhone 15 Pro Max", tipo: .iphone),
        "A3105": .init(nome: "iPhone 15 Pro Max", tipo: .iphone),
        "A3106": .init(nome: "iPhone 15 Pro Max", tipo: .iphone),
        "A2848": .init(nome: "iPhone 15 Pro", tipo: .iphone),
        "A3101": .init(nome: "iPhone 15 Pro", tipo: .iphone),
        "A3102": .init(nome: "iPhone 15 Pro", tipo: .iphone),
        "A2847": .init(nome: "iPhone 15 Plus", tipo: .iphone),
        "A2846": .init(nome: "iPhone 15", tipo: .iphone),
        "A3089": .init(nome: "iPhone 15", tipo: .iphone),
        "A2651": .init(nome: "iPhone 14 Pro Max", tipo: .iphone),
        "A2893": .init(nome: "iPhone 14 Pro Max", tipo: .iphone),
        "A2650": .init(nome: "iPhone 14 Pro", tipo: .iphone),
        "A2889": .init(nome: "iPhone 14 Pro", tipo: .iphone),
        "A2632": .init(nome: "iPhone 14 Plus", tipo: .iphone),
        "A2649": .init(nome: "iPhone 14", tipo: .iphone),
        "A2484": .init(nome: "iPhone 13 Pro Max", tipo: .iphone),
        "A2641": .init(nome: "iPhone 13 Pro Max", tipo: .iphone),
        "A2483": .init(nome: "iPhone 13 Pro", tipo: .iphone),
        "A2638": .init(nome: "iPhone 13 Pro", tipo: .iphone),
        "A2482": .init(nome: "iPhone 13", tipo: .iphone),
        "A2342": .init(nome: "iPhone 12 Pro Max", tipo: .iphone),
        "A2341": .init(nome: "iPhone 12 Pro", tipo: .iphone),
        "A2403": .init(nome: "iPhone 12", tipo: .iphone),
        "A2161": .init(nome: "iPhone 11 Pro Max", tipo: .iphone),
        "A2160": .init(nome: "iPhone 11 Pro", tipo: .iphone),
        "A2221": .init(nome: "iPhone 11", tipo: .iphone),
        "A1865": .init(nome: "iPhone X", tipo: .iphone),
        "A1901": .init(nome: "iPhone X", tipo: .iphone),
        "A1920": .init(nome: "iPhone XS", tipo: .iphone),
        "A1921": .init(nome: "iPhone XS Max", tipo: .iphone),
        "A1984": .init(nome: "iPhone XR", tipo: .iphone),
        "A2595": .init(nome: "iPhone SE", tipo: .iphone),
        "A2275": .init(nome: "iPhone SE", tipo: .iphone),
        "A1522": .init(nome: "iPhone 6 Plus", tipo: .iphone),
        "A1549": .init(nome: "iPhone 6", tipo: .iphone),
        "A2918": .init(nome: "MacBook Pro 14", tipo: .macbook),
        "A2991": .init(nome: "MacBook Pro 16", tipo: .macbook),
        "A2681": .init(nome: "MacBook Air", tipo: .macbook),
        "A2436": .init(nome: "iPad Pro 12.9", tipo: .ipad),
        "A2931": .init(nome: "AirPods Pro", tipo: .airpods),
        "A2698": .init(nome: "AirPods Pro", tipo: .airpods),
        "A2978": .init(nome: "Apple Watch Series 9", tipo: .appleWatch)
    ]

    private static func normalizarNumeracao(_ texto: String) -> String {
        let limpo = texto.uppercased().replacingOccurrences(of: " ", with: "")
        if let faixa = limpo.range(of: "A[0-9]{4}", options: .regularExpression) {
            return String(limpo[faixa])
        }
        return limpo
    }

    private static func problemasGenericos(para tipo: TipoProduto) -> [ProblemaModelo] {
        switch tipo {
        case .iphone, .ipad:
            return [
                ProblemaModelo(id: "gen-bateria", titulo: "Bateria", descricao: "Verificar saúde da bateria e ciclos de carga.", gravidade: .moderado),
                ProblemaModelo(id: "gen-tela", titulo: "Tela e Face ID", descricao: "Testar display, toque e biometria após quedas.", gravidade: .moderado)
            ]
        case .macbook, .iMac:
            return [
                ProblemaModelo(id: "gen-ssd", titulo: "Armazenamento", descricao: "Rodar diagnóstico de disco e SMART se disponível.", gravidade: .moderado),
                ProblemaModelo(id: "gen-teclado", titulo: "Teclado e trackpad", descricao: "Testar todas as teclas e cliques.", gravidade: .leve)
            ]
        case .airpods:
            return [
                ProblemaModelo(id: "gen-ap", titulo: "Áudio e bateria", descricao: "Ouvir chiados e testar autonomia real dos fones.", gravidade: .moderado)
            ]
        case .appleWatch, .watch:
            return [
                ProblemaModelo(id: "gen-watch", titulo: "Bateria e sensores", descricao: "Verificar saúde da bateria e sensores de frequência.", gravidade: .moderado)
            ]
        default:
            return [
                ProblemaModelo(id: "gen-geral", titulo: "Inspeção geral", descricao: "Testar funções principais, portas e conectividade.", gravidade: .leve)
            ]
        }
    }
}
