//
//  BotaoWhatsAppView.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

struct BotaoWhatsAppMensagemView: View {
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            HStack(spacing: 5) {
                Image(systemName: "message.fill")
                    .font(.caption)
                Text("WhatsApp")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.15, green: 0.78, blue: 0.44), in: Capsule())
        }
        .buttonStyle(.plain)
        .help("Abrir conversa na aba Mensagens")
    }
}

#Preview {
    ZStack {
        Color.black
        BotaoWhatsAppMensagemView {}
    }
}
