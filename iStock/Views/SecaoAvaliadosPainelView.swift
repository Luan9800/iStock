//
//  SecaoAvaliadosPainelView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct SecaoAvaliadosPainelView: View {
    @ObservedObject private var service = AvaliacaoService.shared

    @State private var avaliacaoEditando: Avaliacao?
    @State private var avaliacaoExcluindo: Avaliacao?
    @State private var avaliacaoSelecionada: Avaliacao?
    @State private var valorReal: Double = 0

    private let colunas = [GridItem(.adaptive(minimum: 280), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Avaliados — valor estimado")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(Formatters.brl(service.totalEstimadoAvaliadas))
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.azulClaro)
            }

            if service.avaliadasComEstimativa.isEmpty {
                Text("Nenhuma avaliação concluída aguardando definição de venda.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
            } else {
                LazyVGrid(columns: colunas, spacing: 14) {
                    ForEach(service.avaliadasComEstimativa) { item in
                        CartaoAvaliadoPainelView(
                            item: item,
                            onAbrirDetalhes: { avaliacaoSelecionada = item },
                            onRegistrarVenda: {
                                valorReal = item.valorVendaReal ?? item.valorEstimado ?? 0
                                avaliacaoEditando = item
                            },
                            onExcluir: { avaliacaoExcluindo = item }
                        )
                    }
                }
            }
        }
        .sheet(item: $avaliacaoEditando) { item in
            registrarVendaSheet(item)
        }
        .sheet(item: $avaliacaoSelecionada) { item in
            DetalheAvaliacaoView(avaliacao: item)
        }
        .sheet(item: $avaliacaoExcluindo) { item in
            ConfirmarSenhaAdminView(
                titulo: "Excluir avaliação",
                mensagem: "Confirme para excluir \(item.tituloExibicao). Esta ação não pode ser desfeita."
            ) { senha, confirmacao in
                service.removerComAutorizacaoAdmin(item, senha: senha, confirmacaoSenha: confirmacao)
            }
        }
    }

    private func registrarVendaSheet(_ item: Avaliacao) -> some View {
        ZStack {
            FundoTecnologicoView()
            ScrollView {
                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 16) {
                        TituloTelaView(
                            titulo: item.tituloExibicao,
                            subtitulo: "Registrar valor real de venda"
                        )

                        HStack {
                            Text("Estimativa")
                                .foregroundStyle(.white.opacity(0.5))
                            Spacer()
                            Text(Formatters.brl(item.valorEstimado ?? 0))
                                .foregroundStyle(AppTheme.azulClaro)
                        }

                        Text("Valor real vendido")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        TextField("Valor", value: $valorReal, format: .currency(code: "BRL"))
                            .textFieldStyle(.plain)
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                            .padding(12)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

                        if let erro = service.erro {
                            Text(erro).font(.caption).foregroundStyle(.red)
                        }

                        BotaoPrimarioView(titulo: "Salvar valor real", desabilitado: valorReal <= 0) {
                            if service.registrarValorVendaReal(item, valor: valorReal) {
                                avaliacaoEditando = nil
                            }
                        }

                        Button("Cancelar") { avaliacaoEditando = nil }
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.azulClaro)
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CartaoAvaliadoPainelView: View {
    let item: Avaliacao
    let onAbrirDetalhes: () -> Void
    let onRegistrarVenda: () -> Void
    let onExcluir: () -> Void

    private var problemasItem: [ProblemaModelo] {
        if let salvos = item.problemasModelo, !salvos.isEmpty { return salvos }
        return ModeloDefeitosService.buscar(tipo: item.tipoProduto, modelo: item.modelo)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onAbrirDetalhes) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: item.tipoProduto.sfSymbol)
                            .foregroundStyle(AppTheme.azulClaro)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.tituloExibicao)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(item.descricaoCompleta)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.45))
                                .lineLimit(1)
                        }
                        Spacer()
                        BadgeAppView(texto: item.status.rawValue, cor: item.status.cor)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Estimativa de venda")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                            Text(Formatters.brl(item.valorEstimado ?? 0))
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.azulClaro)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Venda real")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                            if item.possuiVendaReal {
                                Text(Formatters.brl(item.valorVendaReal ?? 0))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.green)
                            } else {
                                Text("Não definido")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }

                    if !problemasItem.isEmpty {
                        Label("\(problemasItem.count) alerta(s) de defeito", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }

                    Text("Toque para ver detalhes e alertas")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Button(action: onRegistrarVenda) {
                    Label(item.possuiVendaReal ? "Alterar venda" : "Registrar venda", systemImage: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.gradienteBotao, in: Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onExcluir) {
                    Image(systemName: "trash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.15), in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

struct SecaoLogTransacoesView: View {
    @ObservedObject private var log = TransacaoLogService.shared

    var body: some View {
        CartaoVidroView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Log de transações")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(log.transacoes.count)")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.azulClaro)
                }

                if log.recentes.isEmpty {
                    Text("Nenhuma transação registrada ainda.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                } else {
                    ForEach(log.recentes.prefix(10)) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: item.tipo.icone)
                                .font(.caption)
                                .foregroundStyle(item.tipo.cor)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.titulo)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                if let detalhes = item.detalhes {
                                    Text(detalhes)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.45))
                                }
                                Text(Formatters.dataCurta.string(from: item.data))
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.35))
                            }

                            Spacer()

                            if let valor = item.valor {
                                Text(Formatters.brl(valor))
                                    .font(.caption.bold())
                                    .foregroundStyle(item.tipo.cor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
