//
//  VendaProdutoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct VendaProdutoView: View {
    let produto: Lancamento

    @ObservedObject private var service = LancamentoService.shared
    @ObservedObject private var clienteService = ClienteService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var clienteSelecionado: Cliente?
    @State private var valorVenda: Double
    @State private var salvando = false

    init(produto: Lancamento) {
        self.produto = produto
        _valorVenda = State(initialValue: produto.valor)
    }

    var body: some View {
        ZStack {
            FundoTecnologicoView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TituloTelaView(
                        titulo: "Registrar venda",
                        subtitulo: produto.tituloExibicao
                    )

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Valor da venda")
                                    .foregroundStyle(.white.opacity(0.8))
                                TextField("R$ 0,00", value: $valorVenda, format: .currency(code: "BRL"))
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .foregroundStyle(.white)
                            }

                            if let custo = produto.custoCompra, custo > 0 {
                                let lucro = valorVenda - custo
                                Label(
                                    "Lucro: \(Formatters.brl(lucro))",
                                    systemImage: "chart.line.uptrend.xyaxis"
                                )
                                .font(.caption)
                                .foregroundStyle(lucro >= 0 ? .green : .red)
                            }

                            Text("Cliente (opcional)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))

                            if clienteService.clientes.isEmpty {
                                Text("Nenhum cliente cadastrado.")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.45))
                            } else {
                                ForEach(clienteService.clientes) { cliente in
                                    Button {
                                        clienteSelecionado = clienteSelecionado?.id == cliente.id ? nil : cliente
                                    } label: {
                                        HStack {
                                            Text(cliente.nome)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            if clienteSelecionado?.id == cliente.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(AppTheme.azulClaro)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            clienteSelecionado?.id == cliente.id
                                                ? AppTheme.azulPrimario.opacity(0.2)
                                                : Color.white.opacity(0.05),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            if let erro = service.erro {
                                Text(erro)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                            }

                            BotaoPrimarioView(
                                titulo: "Confirmar venda",
                                desabilitado: valorVenda <= 0 || salvando
                            ) {
                                confirmarVenda()
                            }

                            Button("Cancelar") { dismiss() }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.azulClaro)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func confirmarVenda() {
        salvando = true
        if service.marcarVendido(produto, cliente: clienteSelecionado, valorVenda: valorVenda) {
            dismiss()
        }
        salvando = false
    }
}
