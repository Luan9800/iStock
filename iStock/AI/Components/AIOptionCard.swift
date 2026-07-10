//
//  AIOptionCard.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AIOptionCard: View {
<<<<<<< HEAD

    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
    }

    var body: some View {
        HStack(spacing: 18) {

            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
                .frame(width: 55, height: 55)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
=======
    let icon: String
    let corFundoIcone: Color
    let titulo: String
    let descricao: String
    var iconeBranco = true

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(corFundoIcone)
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconeBranco ? .white : corFundoIcone)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(descricao)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.gradienteFundo.ignoresSafeArea()

        VStack(spacing: 14) {
            AIOptionCard(
                icon: "dollarsign",
                corFundoIcone: Color(red: 0.18, green: 0.72, blue: 0.45),
                titulo: "Assistente de Negociação",
                descricao: "Ajuda em descontos, trocas, contrapropostas e estratégias para fechar vendas."
            )

            AIOptionCard(
                icon: "apple.logo",
                corFundoIcone: Color(red: 0.35, green: 0.55, blue: 0.78),
                titulo: "Consultor Apple",
                descricao: "Argumentos de venda, comparação entre modelos e benefícios do ecossistema Apple."
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
>>>>>>> bfbd1e0 (Atualiza sincronização Firebase (banco istock) e FirestoreProvider)
