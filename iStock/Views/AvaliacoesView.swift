//
//  AvaliacoesView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct AvaliacoesView: View {
    @ObservedObject private var service = AvaliacaoService.shared

    @State private var filtro: StatusAvaliacao?
    @State private var mostrandoNova = false
    @State private var avaliacaoSelecionada: Avaliacao?

    private let colunas = [GridItem(.adaptive(minimum: 260), spacing: 16)]

    private var listaFiltrada: [Avaliacao] {
        guard let filtro else { return service.avaliacoes }
        return service.avaliacoes.filter { $0.status == filtro }
    }

    var body: some View {
        LayoutTelaView(
            titulo: "Avaliações",
            subtitulo: "\(service.emAvaliacao.count) em análise · \(service.aprovadas.count) aprovadas · \(service.aprovadasSemPagamento.count) pgto pendente",
            trailing: {
                Button {
                    mostrandoNova = true
                } label: {
                    Label("Nova", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.gradienteBotao, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        ) {
            VStack(alignment: .leading, spacing: 16) {
                filtros

                if listaFiltrada.isEmpty {
                    CartaoVidroView {
                        EstadoVazioView(
                            icone: "clock.badge.checkmark",
                            titulo: "Nenhuma avaliação",
                            mensagem: "Cadastre um dispositivo com fotos para iniciar a avaliação."
                        )
                    }
                } else {
                    LazyVGrid(columns: colunas, spacing: 16) {
                        ForEach(listaFiltrada) { item in
                            Button {
                                avaliacaoSelecionada = item
                            } label: {
                                AvaliacaoCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $mostrandoNova) {
            NovaAvaliacaoView()
        }
        .sheet(item: $avaliacaoSelecionada) { item in
            DetalheAvaliacaoView(avaliacao: item)
        }
    }

    private var filtros: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filtroBotao(titulo: "Todas", status: nil)
                ForEach(StatusAvaliacao.allCases) { status in
                    filtroBotao(titulo: status.rawValue, status: status)
                }
            }
        }
    }

    private func filtroBotao(titulo: String, status: StatusAvaliacao?) -> some View {
        Button {
            filtro = status
        } label: {
            Text(titulo)
                .font(.caption.weight(.semibold))
                .foregroundStyle(filtro == status ? .white : .white.opacity(0.55))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    if filtro == status {
                        Capsule().fill(AppTheme.gradienteBotao)
                    } else {
                        Capsule().fill(Color.white.opacity(0.08))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

struct AvaliacaoCardView: View {
    let item: Avaliacao

    private var problemasItem: [ProblemaModelo] {
        if let salvos = item.problemasModelo, !salvos.isEmpty { return salvos }
        return ModeloDefeitosService.buscar(tipo: item.tipoProduto, modelo: item.modelo)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.tipoProduto.sfSymbol)
                    .font(.title2)
                    .foregroundStyle(AppTheme.azulClaro)
                Spacer()
                BadgeAppView(texto: item.status.rawValue, cor: item.status.cor)
                if item.status == .aprovado {
                    BadgeAppView(
                        texto: item.pagamentoAprovado ? "Pago" : "Pgto pendente",
                        cor: item.pagamentoAprovado ? .mint : .orange
                    )
                }
            }

            Text(item.tituloExibicao)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(2)

            if !item.descricaoCompleta.isEmpty {
                Text(item.descricaoCompleta)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }

            if let valor = item.valorEstimado, item.status != .emAvaliacao {
                HStack {
                    Text("Estimativa venda")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                    Spacer()
                    Text(Formatters.brl(valor))
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.azulClaro)
                }
            }

            if item.status == .aprovado, item.valorCompra > 0 {
                HStack {
                    Text("Valor compra")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                    Spacer()
                    Text(Formatters.brl(item.valorCompra))
                        .font(.subheadline.bold())
                        .foregroundStyle(item.pagamentoAprovado ? .mint : .orange)
                }
            }

            if !problemasItem.isEmpty {
                Label("\(problemasItem.count) defeito(s) conhecido(s)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }

            HStack {
                Label("\(item.fotos.count) foto(s)", systemImage: "photo")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
                Spacer()
                Text(Formatters.dataCurta.string(from: item.data))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(14)
        .frame(minHeight: 150)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

#Preview {
    AvaliacoesView()
}
