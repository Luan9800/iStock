//
//  AssistenteIAView.swift
//  iStock
//

import SwiftUI

struct AssistenteIAView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                FundoTecnologicoView()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        cabecalho
                            .padding(.top, 48)
                            .padding(.bottom, 36)
                        
                        VStack(spacing: 14) {
                            NavigationLink {
                                NegotiationChatView()
                            } label: {
                                AIOptionCard(
                                    icon: "dollarsign",
                                    title: "Assistente de Negociação",
                                    subtitle: "Ajuda em descontos, trocas, contrapropostas e estratégias para fechar vendas.",
                                    color: Color(red: 0.18, green: 0.72, blue: 0.45)
                                    
                                )
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                AppleConsultantView()
                            } label: {
                                AIOptionCard(
                                    icon: "apple.logo",
                                    title: "Consultor Apple",
                                    subtitle: "Argumentos de venda, comparação entre modelos e benefícios do ecossistema Apple.",
                                    color: Color(red: 0.35, green: 0.55, blue: 0.78)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 32)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private var cabecalho: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(AppTheme.azulClaro)
                .padding(.bottom, 4)
            
            Text("Assistente IA")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Escolha como deseja utilizar o assistente.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text("Ele foi desenvolvido para ajudar consultores Apple a vender melhor e explicar os diferenciais dos produtos.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    AssistenteIAView()
}
