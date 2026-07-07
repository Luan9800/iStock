//
//  SelecaoNotificacaoView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct SelecaoNotificacaoView: View {
    @Binding var selecionados: Set<TipoProduto>

    private let colunas = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notificações de ofertas")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Selecione os produtos sobre os quais o cliente deseja receber ofertas.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

            LazyVGrid(columns: colunas, spacing: 12) {
                ForEach(TipoProduto.allCases) { tipo in
                    Button {
                        if selecionados.contains(tipo) {
                            selecionados.remove(tipo)
                        } else {
                            selecionados.insert(tipo)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: tipo.sfSymbol)
                                    .font(.system(size: 28))
                                    .foregroundStyle(selecionados.contains(tipo) ? AppTheme.azulClaro : .white.opacity(0.7))
                                if selecionados.contains(tipo) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.azulClaro)
                                        .offset(x: 8, y: -8)
                                }
                            }
                            Text(tipo.rawValue)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selecionados.contains(tipo) ? AppTheme.azulPrimario.opacity(0.2) : Color.white.opacity(0.06),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selecionados.contains(tipo) ? AppTheme.azulClaro : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
