//
//  DigimonListView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct DigimonListView: View {
    @StateObject private var viewModel: DigimonListViewModel
    @State private var isFilterExpanded = false
    @State private var nameFilter: String
    @State private var typeFilter: String
    @State private var attributeFilter: String
    @State private var levelFilter: String
    @State private var fieldsFilterText: String

    private let container: AppContainer

    init(viewModel: DigimonListViewModel, container: AppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _nameFilter = State(initialValue: viewModel.searchCriteria.name)
        _typeFilter = State(initialValue: viewModel.searchCriteria.type)
        _attributeFilter = State(initialValue: viewModel.searchCriteria.attribute)
        _levelFilter = State(initialValue: viewModel.searchCriteria.level)
        _fieldsFilterText = State(initialValue: viewModel.searchCriteria.fields.joined(separator: ", "))
        self.container = container
    }

    var body: some View {
        VStack(spacing: 0) {
            filterHeader
            if isFilterExpanded {
                filterPanel
            }
            content
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoadingInitial {
                        ProgressView()
                    }
                }
            }
            .task {
                await viewModel.loadInitialIfNeeded()
            }
    }

    private var filterHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isFilterExpanded.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Search Filters")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if appliedFilterCount > 0 {
                    Text("\(appliedFilterCount)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
                Image(systemName: isFilterExpanded ? "chevron.up" : "chevron.down")
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(Color(.secondarySystemBackground))
    }

    private var filterPanel: some View {
        VStack(spacing: 10) {
            Group {
                TextField("Name (e.g. Agumon)", text: $nameFilter)
                TextField("Type (e.g. Reptile)", text: $typeFilter)
                TextField("Attribute (e.g. Vaccine)", text: $attributeFilter)
                TextField("Level (e.g. Child)", text: $levelFilter)
                TextField("Fields (comma separated)", text: $fieldsFilterText)
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)

            HStack(spacing: 10) {
                Button("Clear") {
                    clearDraftFilters()
                    Task {
                        await viewModel.applySearchCriteria(.empty)
                    }
                }
                .buttonStyle(.bordered)

                Button("Apply Filters") {
                    Task {
                        await viewModel.applySearchCriteria(buildCriteriaFromDraft())
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingInitial && viewModel.items.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
            errorView(message: errorMessage)
        } else if viewModel.items.isEmpty {
            emptyView
        } else {
            listView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading Digimon...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.secondary)
            Text("No Digimon found")
                .font(.headline)
            Text("Try changing your filters.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let paginationError = viewModel.paginationErrorMessage {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)

                        Text(paginationError)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button("Retry") {
                            Task {
                                await viewModel.loadNextPageIfNeeded(currentItem: viewModel.items.last)
                            }
                        }
                        .font(.footnote.weight(.semibold))

                        Button {
                            viewModel.clearPaginationError()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.footnote.weight(.bold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemYellow).opacity(0.18))
                    )
                }

                ForEach(viewModel.items) { digimon in
                    NavigationLink {
                        DigimonDetailView(
                            viewModel: container.makeDigimonDetailViewModel(digimonID: digimon.id),
                            fallbackSummary: digimon
                        )
                    } label: {
                        DigimonCardView(digimon: digimon)
                    }
                    .buttonStyle(.plain)
                    .task {
                        await viewModel.loadNextPageIfNeeded(currentItem: digimon)
                    }
                }

                if viewModel.isLoadingMore {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Loading more...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                if viewModel.hasMorePages && !viewModel.isLoadingMore {
                    Color.clear
                        .frame(height: 1)
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: viewModel.items.last)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var appliedFilterCount: Int {
        var count = 0
        if !viewModel.searchCriteria.name.isEmpty { count += 1 }
        if !viewModel.searchCriteria.type.isEmpty { count += 1 }
        if !viewModel.searchCriteria.attribute.isEmpty { count += 1 }
        if !viewModel.searchCriteria.level.isEmpty { count += 1 }
        if !viewModel.searchCriteria.fields.isEmpty { count += 1 }
        return count
    }

    private func buildCriteriaFromDraft() -> DigimonSearchCriteria {
        DigimonSearchCriteria(
            name: nameFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            type: typeFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            attribute: attributeFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            level: levelFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            fields: fieldsFilterText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
    }

    private func clearDraftFilters() {
        nameFilter = ""
        typeFilter = ""
        attributeFilter = ""
        levelFilter = ""
        fieldsFilterText = ""
    }
}

#Preview {
    DigimonListView(
        viewModel: AppContainer.shared.makeDigimonListViewModel(),
        container: AppContainer.shared
    )
}
