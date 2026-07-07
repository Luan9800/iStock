//
//  DetalheProdutoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct DetalheProdutoView: View {
    let produto: Lancamento

    @ObservedObject private var service = LancamentoService.shared
    @ObservedObject private var auth = AuthService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var editando = false
    @State private var dados = DadosProdutoFormulario()
    @State private var mostrandoVenda = false
    @State private var mostrandoExclusao = false
    @State private var salvando = false

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        TituloTelaView(titulo: produto.tituloExibicao, subtitulo: produto.tipoProduto.rawValue)
                        Spacer()
                        BadgeAppView(texto: produto.status.rawValue, cor: produto.status.cor)
                    }

                    CartaoVidroView {
                        if editando {
                            formularioEdicao
                        } else {
                            detalhesVisualizacao
                        }
                    }

                    if !editando {
                        acoesProduto
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { dados = DadosProdutoFormulario(de: produto) }
        .sheet(isPresented: $mostrandoVenda) {
            VendaProdutoView(produto: produtoAtual)
        }
        .alert("Excluir produto?", isPresented: $mostrandoExclusao) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                service.remover(produtoAtual)
                dismiss()
            }
        } message: {
            Text("Esta ação não pode ser desfeita.")
        }
    }

    private var produtoAtual: Lancamento {
        service.lancamentos.first { $0.id == produto.id } ?? produto
    }

    @ViewBuilder
    private var detalhesVisualizacao: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let id = produtoAtual.id {
                GaleriaModeloView(
                    cadastroId: id,
                    tipo: produtoAtual.tipoProduto,
                    criadoPor: auth.nomeOuEmail
                )
            }

            linhaDetalhe(icone: "tag", titulo: "Nome", valor: produtoAtual.nome)

            if let modelo = produtoAtual.modelo, !modelo.isEmpty {
                linhaDetalhe(icone: "iphone", titulo: "Modelo", valor: modelo)
            }
            if let capacidade = produtoAtual.capacidade, !capacidade.isEmpty {
                linhaDetalhe(icone: "internaldrive", titulo: "Capacidade", valor: capacidade)
            }
            if let cor = produtoAtual.cor, !cor.isEmpty {
                linhaDetalhe(icone: "paintpalette", titulo: "Cor", valor: cor)
            }
            if let serial = produtoAtual.serial, !serial.isEmpty {
                linhaDetalhe(icone: "barcode", titulo: "Serial / IMEI", valor: serial)
            }
            if let telefone = produtoAtual.telefone, !telefone.isEmpty {
                linhaDetalhe(icone: "phone", titulo: "Contato", valor: telefone)
            }

            linhaDetalhe(
                icone: produtoAtual.lacrado ? "seal.fill" : "battery.100",
                titulo: produtoAtual.lacrado ? "Condição" : "Bateria",
                valor: produtoAtual.lacrado ? "Lacrado" : "\(produtoAtual.condicaoPercentual ?? 0)%"
            )

            linhaDetalhe(icone: "brazilianrealsign.circle", titulo: "Preço", valor: Formatters.brl(produtoAtual.valor))

            if let custo = produtoAtual.custoCompra {
                linhaDetalhe(icone: "cart", titulo: "Custo", valor: Formatters.brl(custo))
                if let margem = produtoAtual.margem {
                    linhaDetalhe(icone: "chart.line.uptrend.xyaxis", titulo: "Margem", valor: Formatters.brl(margem))
                }
            }

            linhaDetalhe(icone: "calendar", titulo: "Entrada", valor: Formatters.dataCurta.string(from: produtoAtual.data))
            linhaDetalhe(icone: "clock", titulo: "Dias no estoque", valor: "\(produtoAtual.diasNoEstoque)")

            if produtoAtual.estaHaMuitoTempoNoEstoque {
                Label("Parado há mais de \(Lancamento.diasLimiteEstoque) dias", systemImage: "exclamationmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }

            if produtoAtual.status == .vendido {
                if let cliente = produtoAtual.clienteVendaNome {
                    linhaDetalhe(icone: "person", titulo: "Vendido para", valor: cliente)
                }
                if let dataVenda = produtoAtual.dataVenda {
                    linhaDetalhe(icone: "bag", titulo: "Data da venda", valor: Formatters.dataCurta.string(from: dataVenda))
                }
            }

            if let obs = produtoAtual.observacoes, !obs.isEmpty {
                linhaDetalhe(icone: "note.text", titulo: "Observações", valor: obs)
            }

            if !problemasExibicao.isEmpty {
                Divider().overlay(Color.white.opacity(0.1))
                SecaoProblemasModeloView(problemas: problemasExibicao)
            }
        }
    }

    private var problemasExibicao: [ProblemaModelo] {
        if let salvos = produtoAtual.problemasModelo, !salvos.isEmpty { return salvos }
        return ModeloDefeitosService.buscar(tipo: produtoAtual.tipoProduto, modelo: produtoAtual.modelo)
    }

    private var formularioEdicao: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormularioProdutoView(
                dados: $dados,
                cadastroId: produtoAtual.id ?? UUID().uuidString,
                criadoPor: auth.nomeOuEmail,
                mostrarGaleria: false
            )

            HStack(spacing: 12) {
                BotaoSecundarioView(titulo: "Cancelar") {
                    dados = DadosProdutoFormulario(de: produtoAtual)
                    editando = false
                }
                Spacer()
                BotaoPrimarioView(titulo: "Salvar", desabilitado: !dados.valido || salvando) {
                    salvarEdicao()
                }
                .frame(maxWidth: 160)
            }
        }
    }

    @ViewBuilder
    private var acoesProduto: some View {
        VStack(spacing: 10) {
            if produtoAtual.status != .vendido {
                HStack(spacing: 10) {
                    if produtoAtual.status == .disponivel {
                        botaoAcao(titulo: "Reservar", icone: "clock", cor: .orange) {
                            service.marcarReservado(produtoAtual)
                        }
                    }
                    if produtoAtual.status == .reservado {
                        botaoAcao(titulo: "Liberar", icone: "arrow.uturn.backward", cor: AppTheme.azulClaro) {
                            service.liberarReserva(produtoAtual)
                        }
                    }
                    botaoAcao(titulo: "Vender", icone: "bag.fill", cor: .green) {
                        mostrandoVenda = true
                    }
                }

                Button {
                    editando = true
                } label: {
                    Label("Editar produto", systemImage: "pencil")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.azulClaro)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Button {
                mostrandoExclusao = true
            } label: {
                Label("Excluir produto", systemImage: "trash")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }

    private func linhaDetalhe(icone: String, titulo: String, valor: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icone)
                .foregroundStyle(AppTheme.azulClaro)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
                Text(valor)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
    }

    private func botaoAcao(titulo: String, icone: String, cor: Color, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            Label(titulo, systemImage: icone)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(cor.opacity(0.25), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func salvarEdicao() {
        salvando = true
        var atualizado = dados.paraLancamento(
            id: produtoAtual.id,
            status: produtoAtual.status,
            criadoPor: produtoAtual.criadoPor
        )
        atualizado.data = produtoAtual.data
        atualizado.clienteVendaId = produtoAtual.clienteVendaId
        atualizado.clienteVendaNome = produtoAtual.clienteVendaNome
        atualizado.dataVenda = produtoAtual.dataVenda

        if service.atualizar(atualizado) {
            editando = false
        }
        salvando = false
    }
}
