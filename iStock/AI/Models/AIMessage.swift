//
//  AIMessage.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import Foundation

struct AIMessage: Identifiable, Hashable {
    enum Role {
        case user
        case assistant
    }
    
    let id = UUID()
    let role: Role
    let text: String
}
