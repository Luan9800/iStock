//
//  ListaProdutosView.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Combine
import SwiftUI

struct ListaProdutosView: View {
    @ObservedObject private var service = LancamentoService.shared

    private let colunas = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if service.lancamentos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Nenhum produto cadastrado ainda")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: colunas, spacing: 16) {
                    ForEach(service.lancamentos) { item in
                        ProdutoCardView(item: item)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Produtos Cadastrados")
    }
}

struct ProdutoCardView: View {
    let item: Lancamento

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.tipoProduto.sfSymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                Spacer()
                if item.lacrado {
                    Text("Lacrado")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15), in: Capsule())
                        .foregroundStyle(.green)
                } else if let cond = item.condicaoPercentual {
                    Text("\(cond)% bateria")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.15), in: Capsule())
                        .foregroundStyle(.orange)
                }
            }

            Text(item.nome)
                .font(.headline)
                .lineLimit(2)

            if let serial = item.serial, !serial.isEmpty {
                Text(serial)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            HStack {
                Text(Formatters.brl(item.valor))
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text(Formatters.dataCurta.string(from: item.data))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(height: 150)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    ListaProdutosView()
}
