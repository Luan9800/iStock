//
//  SecaoProblemasModeloView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct SecaoProblemasModeloView: View {
    let problemas: [ProblemaModelo]
    var titulo = "Problemas conhecidos do modelo"

    var body: some View {
        if !problemas.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label(titulo, systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                Text("Com base no modelo informado — verifique estes pontos na inspeção.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))

                ForEach(problemas) { problema in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(problema.gravidade.cor)
                            .frame(width: 8, height: 8)
                            .padding(.top, 5)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(problema.titulo)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(problema.gravidade.rawValue)
                                    .font(.caption2.bold())
                                    .foregroundStyle(problema.gravidade.cor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(problema.gravidade.cor.opacity(0.15), in: Capsule())
                            }
                            Text(problema.descricao)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
