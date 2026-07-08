import SwiftUI

struct SuggestionButton: View {

    let icon: String
    let title: String

    var body: some View {

        HStack {

            Image(systemName: icon)
                .font(.title3)

            Text(title)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)

        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}