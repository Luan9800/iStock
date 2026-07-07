//
//  DetalheAvaliacaoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct DetalheAvaliacaoView: View {
    let avaliacao: Avaliacao

    @ObservedObject private var service = AvaliacaoService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var processando = false
    @State private var valorAjustado: Double = 0

    private var atual: Avaliacao {
        service.avaliacoes.first { $0.id == avaliacao.id } ?? avaliacao
    }

    private var problemasExibicao: [ProblemaModelo] {
        if let salvos = atual.problemasModelo, !salvos.isEmpty { return salvos }
        return ModeloDefeitosService.buscar(tipo: atual.tipoProduto, modelo: atual.modelo)
    }

    private let colunasFotos = [GridItem(.adaptive(minimum: 110), spacing: 12)]

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        TituloTelaView(
                            titulo: atual.tituloExibicao,
                            subtitulo: atual.tipoProduto.rawValue
                        )
                        Spacer()
                        BadgeAppView(texto: atual.status.rawValue, cor: atual.status.cor)
                    }

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 14) {
                            if !atual.fotos.isEmpty {
                                LazyVGrid(columns: colunasFotos, spacing: 12) {
                                    ForEach(atual.fotos) { foto in
                                        FotoAvaliacaoThumbnail(foto: foto)
                                    }
                                }
                            }

                            infoLinha("Modelo", atual.modelo ?? "—")
                            infoLinha("Capacidade", atual.capacidade ?? "—")
                            infoLinha("Cor", atual.cor ?? "—")
                            infoLinha("Serial", atual.serial ?? "—")
                            infoLinha("Contato", atual.telefone ?? "—")
                            infoLinha(
                                "Condição",
                                atual.lacrado ? "Lacrado" : "\(atual.condicaoPercentual ?? 0)%"
                            )
                            infoLinha("Cadastro", Formatters.dataCurta.string(from: atual.data))

                            if let obs = atual.observacoes, !obs.isEmpty {
                                Text(obs)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                        }
                    }

                    if !problemasExibicao.isEmpty {
                        CartaoVidroView {
                            SecaoProblemasModeloView(problemas: problemasExibicao)
                        }
                    }

                    if atual.status != .emAvaliacao {
                        previaValor
                    }

                    acoes
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            valorAjustado = atual.valorEstimado ?? 0
        }
        .onChange(of: atual.valorEstimado) { _, novo in
            if let novo { valorAjustado = novo }
        }
    }

    @ViewBuilder
    private var previaValor: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 14) {
                Label("Prévia de valor", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Venda sugerida")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                        if atual.status == .avaliado || atual.status == .aprovado {
                            TextField("Valor", value: $valorAjustado, format: .currency(code: "BRL"))
                                .textFieldStyle(.plain)
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.azulClaro)
                        } else {
                            Text(Formatters.brl(atual.valorEstimado ?? 0))
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.azulClaro)
                        }
                    }
                    Spacer()
                    if let compra = atual.valorCompraSugerido {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Compra sugerida")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.45))
                            Text(Formatters.brl(compra))
                                .font(.subheadline.bold())
                                .foregroundStyle(.green)
                        }
                    }
                }

                if atual.status == .avaliado || atual.status == .aprovado,
                   let compra = atual.valorCompraSugerido {
                    let margem = valorAjustado - compra
                    Text("Margem estimada: \(Formatters.brl(margem))")
                        .font(.caption)
                        .foregroundStyle(margem >= 0 ? AppTheme.azulClaro : .red)
                }

                if let data = atual.dataAvaliacao {
                    Text("Avaliado em \(Formatters.dataCurta.string(from: data))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }

                if let data = atual.dataAprovacao {
                    Text("Compra aprovada em \(Formatters.dataCurta.string(from: data))")
                        .font(.caption2)
                        .foregroundStyle(.green.opacity(0.8))
                }

                if atual.pagamentoAprovado, let data = atual.dataPagamento {
                    Label("Pagamento aprovado em \(Formatters.dataCurta.string(from: data))", systemImage: "banknote.fill")
                        .font(.caption2)
                        .foregroundStyle(.mint)
                } else if atual.status == .aprovado {
                    Label("Pagamento pendente", systemImage: "clock.badge.exclamationmark")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    @ViewBuilder
    private var acoes: some View {
        VStack(spacing: 10) {
            if atual.status == .emAvaliacao {
                BotaoPrimarioView(titulo: "Concluir avaliação", desabilitado: processando) {
                    processando = true
                    if service.executarAvaliacao(atual) {
                        valorAjustado = service.avaliacoes
                            .first { $0.id == atual.id }?.valorEstimado ?? 0
                    }
                    processando = false
                }
            }

            if atual.status == .avaliado {
                BotaoPrimarioView(titulo: "Aprovar compra", desabilitado: processando || valorAjustado <= 0) {
                    aprovarCompra()
                }
            }

            if atual.status == .aprovado && !atual.pagamentoAprovado {
                BotaoPrimarioView(titulo: "Aprovar pagamento", desabilitado: processando) {
                    processando = true
                    _ = service.aprovarPagamento(atual)
                    processando = false
                }
            }

            if atual.status == .aprovado && atual.pagamentoAprovado {
                BotaoPrimarioView(titulo: "Adicionar ao estoque", desabilitado: processando || valorAjustado <= 0) {
                    adicionarAoEstoque()
                }
            }

            if atual.status == .noEstoque {
                Label("Dispositivo já incluído no estoque", systemImage: "checkmark.seal.fill")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }

            if let erro = service.erro {
                Text(erro)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.9))
            }

            Button("Fechar") { dismiss() }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.azulClaro)
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
        }
    }

    private func infoLinha(_ titulo: String, _ valor: String) -> some View {
        HStack {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
            Text(valor)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }

    private func aprovarCompra() {
        processando = true
        var item = atual
        item.valorEstimado = valorAjustado

        guard service.atualizar(item) else {
            processando = false
            return
        }
        let atualizado = service.avaliacoes.first { $0.id == item.id } ?? item
        _ = service.aprovarCompra(atualizado)
        processando = false
    }

    private func adicionarAoEstoque() {
        processando = true
        var item = service.avaliacoes.first { $0.id == atual.id } ?? atual
        item.valorEstimado = valorAjustado

        if service.atualizar(item) && service.converterParaEstoque(item) {
            dismiss()
        }
        processando = false
    }
}

struct FotoAvaliacaoThumbnail: View {
    let foto: FotoAvaliacao

    var body: some View {
        Group {
            if let url = URL(string: foto.url) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    DetalheAvaliacaoView(avaliacao: Avaliacao(
        tipoProduto: .iphone,
        nome: "iPhone usado",
        modelo: "iPhone 14 Pro",
        capacidade: "256GB",
        lacrado: false,
        condicaoPercentual: 87,
        fotos: [],
        criadoPor: "Vendedor"
    ))
}
