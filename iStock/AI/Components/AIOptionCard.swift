//
//  AIOptionCard.swift
//  iStock
//
//  Created by Luan Carlos on 08/07/26.
//

import SwiftUI

struct AIOptionCard: View {

    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
    }

    var body: some View {
        HStack(spacing: 18) {

            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
                .frame(width: 55, height: 55)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
