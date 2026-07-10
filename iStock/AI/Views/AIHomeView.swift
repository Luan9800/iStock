//
//  AIHomeView.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AIHomeView: View {
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 12) {
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 70))
                            .foregroundStyle(AppTheme.azulClaro)
                        
                        Text("Assistente IA")
                            .font(.largeTitle.bold())
                        
                        Text("""
Escolha como deseja utilizar o assistente.

Ele foi desenvolvido para ajudar consultores Apple a vender melhor e explicar os diferenciais dos produtos.
""")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        
                    }
                    .padding(.top,40)
                    
                    NavigationLink {
                        NegotiationChatView()
                        
                    } label: {
                        AIOptionCard(
                            icon: "dollarsign.circle.fill",
                            title: "Assistente de Negociação",
                            subtitle: "Ajuda em descontos, trocas, contrapropostas e estratégias para fechar vendas.",
                            color: .green
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
                            color: AppTheme.azulClaro
                        )
                        
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                }
                .padding()
            }
            .navigationTitle("Assistente IA")
        }
    }
}
