//
//  DigimonCardView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct DigimonCardView: View {
    let digimon: DigimonSummary

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            RemoteImageView(url: digimon.imageURL, height: 92)
                .frame(width: 100)

            VStack(alignment: .leading, spacing: 6) {
                Text(digimon.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("ID: #\(digimon.id)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let detailURL = digimon.detailURL {
                    Text(detailURL.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
