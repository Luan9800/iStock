//
//  SocialLoginCard.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

enum ProvedorSocial {
    case google
    case apple

    var titulo: String {
        switch self {
        case .google: return "Google"
        case .apple: return "Apple"
        }
    }

    var icone: String {
        switch self {
        case .google: return "g.circle.fill"
        case .apple: return "apple.logo"
        }
    }

    var corIcone: Color {
        switch self {
        case .google: return AppTheme.azulClaro
        case .apple: return .white
        }
    }

    var corFundo: Color {
        switch self {
        case .google: return Color.white.opacity(0.08)
        case .apple: return Color.black.opacity(0.55)
        }
    }

    var corTexto: Color {
        .white
    }

    var corBorda: Color {
        switch self {
        case .google: return AppTheme.azulClaro.opacity(0.25)
        case .apple: return Color.white.opacity(0.12)
        }
    }
}

struct SocialLoginCard: View {
    let provedor: ProvedorSocial
    var compacto = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if compacto {
                conteudoCompacto
            } else {
                conteudoPadrao
            }
        }
        .buttonStyle(.plain)
    }

    private var conteudoCompacto: some View {
        HStack(spacing: 10) {
            Image(systemName: provedor.icone)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(provedor.corIcone)

            Text(provedor.titulo)
                .font(.caption.weight(.bold))
                .foregroundStyle(provedor.corTexto)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(provedor.corFundo, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(provedor.corBorda, lineWidth: 1)
        }
    }

    private var conteudoPadrao: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(provedor.corIcone.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: provedor.icone)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(provedor.corIcone)
            }

            Text(provedor.titulo)
                .font(.caption.weight(.bold))
                .foregroundStyle(provedor.corTexto)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background(provedor.corFundo, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(provedor.corBorda, lineWidth: 1)
        }
    }
}

struct SocialLoginCardsView: View {
    let onGoogle: () -> Void
    let onApple: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SocialLoginCard(provedor: .google, compacto: true, action: onGoogle)
                .frame(maxWidth: .infinity)

            #if os(iOS)
            SocialLoginCard(provedor: .apple, compacto: true, action: onApple)
                .frame(maxWidth: .infinity)
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct DivisorLoginView: View {
    var body: some View {
        HStack(spacing: 14) {
            linha
            Text("ou continue com e-mail")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            linha
        }
    }

    private var linha: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.2), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

#Preview {
    ZStack {
        AppTheme.gradienteFundo.ignoresSafeArea()
        SocialLoginCardsView(onGoogle: {}, onApple: {})
            .padding()
    }
}
