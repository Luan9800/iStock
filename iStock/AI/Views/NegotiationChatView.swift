import SwiftUI

struct NegotiationChatView: View {

    var body: some View {

        VStack(spacing: 30) {

            Spacer()

            Image(systemName: "handshake.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Assistente de Negociação")
                .font(.largeTitle.bold())

            Text("""
Descreva a negociação normalmente.

Exemplo:

• Cliente quer pagar R$ 3.900.

• Cliente quer trocar um iPhone 13 em um 15 Pro.

• Cliente pediu desconto.
""")
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Spacer()

        }
        .padding()
        .navigationTitle("Negociação")
    }

}