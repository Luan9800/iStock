//
//  AIChatView.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AIChatView: View {
    @State private var text = ""
    @State private var loading = false
    @State private var messages: [AIMessage] = []
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12) {
                    
                    ForEach(messages) { message in
                        
                        HStack {
                            
                            if message.role == .assistant {
                                
                                Text("🤖")
                            }
                            
                            Text(message.text)
                                .padding(10)
                                .background(
                                    message.role == .user
                                    ? Color.blue.opacity(0.15)
                                    : Color.gray.opacity(0.15)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                
                TextField("Pergunte alguma coisa...", text: $text)
                
                Button("Enviar") {
                    
                    send()
                    
                }
                .disabled(text.isEmpty || loading)
                
            }
            .padding()
        }
        .navigationTitle("Assistente IA")
    }
    
    private func send() {
        
        let question = text
        
        messages.append(
            AIMessage(
                role: .user,
                text: question
            )
        )
        
        text = ""
        
        loading = true
        
        Task {
            
            let answer = await AIService.shared.send(question)
            
            messages.append(
                AIMessage(
                    role: .assistant,
                    text: answer
                )
            )
            
            loading = false
        }
    }
}
