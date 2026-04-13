//
//  DigimonDetailView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct DigimonDetailView: View {
    @StateObject private var viewModel: DigimonDetailViewModel
    private let fallbackSummary: DigimonSummary?

    init(viewModel: DigimonDetailViewModel, fallbackSummary: DigimonSummary? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.fallbackSummary = fallbackSummary
    }

    var body: some View {
        content
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.load()
            }
    }

    private var navigationTitle: String {
        viewModel.detail?.name ?? fallbackSummary?.name ?? "Detail"
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.detail == nil {
            loadingView
        } else if let errorMessage = viewModel.errorMessage, viewModel.detail == nil {
            errorView(message: errorMessage)
        } else if let detail = viewModel.detail {
            detailContent(detail)
        } else {
            loadingView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading details...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry") {
                Task {
                    await viewModel.load()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detailContent(_ detail: DigimonDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let inlineErrorMessage = viewModel.inlineErrorMessage {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundStyle(.orange)

                        Text(inlineErrorMessage)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            viewModel.clearInlineError()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemYellow).opacity(0.18))
                    )
                }

                RemoteImageView(url: detail.primaryImageURL ?? fallbackSummary?.imageURL, height: 240)

                titleSection(detail)
                infoSection(detail)
                fieldsSection(detail)
                descriptionSection(detail)
                skillsSection(detail)
            }
            .padding(16)
        }
    }

    private func titleSection(_ detail: DigimonDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.name)
                .font(.title2.weight(.bold))

            HStack(spacing: 10) {
                Text("ID: #\(detail.id)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if detail.isXAntibody {
                    Text("X-Antibody")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemBlue).opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoSection(_ detail: DigimonDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Basic Info")

            infoRow(title: "Level", value: detail.levels.joined(separator: ", "))
            infoRow(title: "Type", value: detail.types.joined(separator: ", "))
            infoRow(title: "Attribute", value: detail.attributes.joined(separator: ", "))
            infoRow(title: "Release", value: detail.releaseDate ?? "Unknown")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func fieldsSection(_ detail: DigimonDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Fields")

            if detail.fields.isEmpty {
                Text("No fields available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                    ForEach(detail.fields) { field in
                        HStack(spacing: 8) {
                            AsyncImage(url: field.imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                default:
                                    Color(.systemGray5)
                                }
                            }
                            .frame(width: 26, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                            Text(field.name)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func descriptionSection(_ detail: DigimonDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Description")
            Text(detail.description ?? "No description available")
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func skillsSection(_ detail: DigimonDetail) -> some View {
        let displayedSkills = Array(detail.skills.prefix(10))

        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Skills")

            if displayedSkills.isEmpty {
                Text("No skills available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayedSkills) { skill in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(skillDisplayName(skill))
                            .font(.subheadline.weight(.semibold))

                        if let description = skill.description, !description.isEmpty {
                            Text(description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    if skill.id != displayedSkills.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(width: 82, alignment: .leading)

            Text(value.isEmpty ? "Unknown" : value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func skillDisplayName(_ skill: DigimonSkill) -> String {
        if let translation = skill.translation, !translation.isEmpty {
            return "\(skill.name) (\(translation))"
        }

        return skill.name
    }
}
