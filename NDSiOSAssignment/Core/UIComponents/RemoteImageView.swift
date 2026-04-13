//
//  RemoteImageView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    let height: CGFloat

    init(url: URL?, height: CGFloat = 110) {
        self.url = url
        self.height = height
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(10)
                    .background(Color.white)
            case .failure:
                fallback
            @unknown default:
                fallback
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
            ProgressView()
        }
    }

    private var fallback: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
            Image(systemName: "photo")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
