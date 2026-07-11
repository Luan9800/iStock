//
//  AIOptionCard.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AIOptionCard: View {

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

            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 55, height: 55)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(color)
                    .symbolRenderingMode(.monochrome)
            }

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

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

enum ModoAssistenteIA: String, CaseIterable, Identifiable {
    case negociacao
    case consultorVendas
    case consultorTecnico

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .negociacao: return "Assistente de Negociação"
        case .consultorVendas: return "Consultor Apple — Meu cliente"
        case .consultorTecnico: return "Consultor Apple — Minha dúvida"
        }
    }

    var descricao: String {
        switch self {
        case .negociacao:
            return "Analise ofertas, descontos, trocas e contrapropostas com seus critérios."
        case .consultorVendas:
            return "Roteiro de vendas, argumentos e sugestões do seu estoque."
        case .consultorTecnico:
            return "Diagnóstico técnico, defeitos conhecidos e checklist de inspeção."
        }
    }

    var icone: String {
        switch self {
        case .negociacao: return "dollarsign.circle.fill"
        case .consultorVendas: return "bag.fill"
        case .consultorTecnico: return "wrench.and.screwdriver.fill"
        }
    }

    var cor: Color {
        switch self {
        case .negociacao: return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .consultorVendas: return AppTheme.azulPrimario
        case .consultorTecnico: return AppTheme.azulClaro
        }
    }

    var sugestoes: [String] {
        switch self {
        case .negociacao:
            return SugestaoRapidaNegociacao.textosNegociacao
        case .consultorVendas:
            return ModoConsultorApple.cliente.sugestoesChat
        case .consultorTecnico:
            return ModoConsultorApple.pessoal.sugestoesChat
        }
    }
}

