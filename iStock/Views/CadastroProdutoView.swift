//
//  CadastroProdutoView.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//


import SwiftUI
import Combine
import Foundation

struct CadastroProdutoView: View {
    @ObservedObject private var service = LancamentoService.shared
    @ObservedObject private var auth = AuthService.shared

    @State private var nome = ""
    @State private var tipoProduto: TipoProduto = .iphone
    @State private var lacrado = false
    @State private var condicaoPercentual: Double = 100
    @State private var valor: Double = 0
    @State private var salvo = false
    @State private var salvando = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Cadastrar Produto")
                    .font(.largeTitle.bold())

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(TipoProduto.allCases) { tipo in
                        Button {
                            tipoProduto = tipo
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tipo.sfSymbol)
                                    .font(.system(size: 30))
                                Text(tipo.rawValue).font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                tipoProduto == tipo ? Color.blue.opacity(0.15) : Color.gray.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(tipoProduto == tipo ? Color.blue : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                GaleriaModeloView(tipo: tipoProduto, criadoPor: auth.nomeOuEmail)

                TextField("Nome / descrição do produto", text: $nome)
                    .textFieldStyle(.roundedBorder)

                Toggle("Lacrado", isOn: $lacrado)

                if !lacrado {
                    Text("Condição: \(Int(condicaoPercentual))%")
                    Slider(value: $condicaoPercentual, in: 1...100, step: 1)
                }

                HStack {
                    Text("Valor")
                    TextField("R$ 0,00", value: $valor, format: .currency(code: "BRL"))
                        .textFieldStyle(.roundedBorder)
                }

                if salvo {
                    Label("Produto salvo!", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                Button("Salvar Produto") {
                    salvar()
                }
                .buttonStyle(.borderedProminent)
                .disabled(nome.isEmpty || valor <= 0 || salvando)
            }
            .padding(24)
        }
        .overlay {
            if salvando {
                ProgressView("Salvando...")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func salvar() {
        salvando = true
        let item = Lancamento(
            nome: nome,
            tipoProduto: tipoProduto,
            lacrado: lacrado,
            condicaoPercentual: lacrado ? nil : Int(condicaoPercentual),
            valor: valor,
            criadoPor: auth.nomeOuEmail
        )

        service.salvar(item)
        nome = ""
        lacrado = false
        condicaoPercentual = 100
        valor = 0
        salvando = false
        salvo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { salvo = false }
    }
}

#Preview {
    CadastroProdutoView()
}
