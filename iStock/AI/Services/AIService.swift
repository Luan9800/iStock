//
//  AIService.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import Combine
import Foundation

@MainActor
final class AIService: ObservableObject {
    static let shared = AIService()
    
    private init() {}
    func send(_ message: String) async -> String {
        
        try? await Task.sleep(for: .seconds(1))
        
        return """
            
            Recebi sua mensagem:
            
            "\(message)"
            
            Nesta primeira etapa ainda estou funcionando em modo de teste.
            
            """
        
    }
}
