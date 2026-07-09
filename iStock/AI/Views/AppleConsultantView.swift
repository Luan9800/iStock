//
//  AppleConsul.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AppleConsultantView: View {
    var body: some View {
        
        List {
            
            Section("Esse atendimento é para") {
                NavigationLink("Meu cliente") {
                    
                    Text("Chat para vendas")
                        .navigationTitle("Consultor Apple")
                    
                }
                
                NavigationLink("Minha dúvida pessoal") {
                    Text("Chat técnico Apple")
                        .navigationTitle("Consultor Apple")
                    
                }
                
            }
            
        }
        .navigationTitle("Consultor Apple")
        
    }
    
}
