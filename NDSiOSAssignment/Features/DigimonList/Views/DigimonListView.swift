//
//  DigimonListView.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import SwiftUI

struct DigimonListView: View {
    @StateObject private var viewModel: DigimonListViewModel
    @State private var isFilterSheetPresented = false
    @State private var isApplyingFilters = false
    @State private var nameFilter: String
    @State private var exactFilter: Bool
    @State private var typeFilter: String
    @State private var attributeFilter: String
    @State private var xAntibodyFilter: Bool
    @State private var levelFilter: String
    @State private var fieldsFilterText: String

    private let container: AppContainer

    init(viewModel: DigimonListViewModel, container: AppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _nameFilter = State(initialValue: viewModel.searchCriteria.name)
        _exactFilter = State(initialValue: viewModel.searchCriteria.exact)
        _typeFilter = State(initialValue: viewModel.searchCriteria.type)
        _attributeFilter = State(initialValue: viewModel.searchCriteria.attribute)
        _xAntibodyFilter = State(initialValue: viewModel.searchCriteria.xAntibody)
        _levelFilter = State(initialValue: viewModel.searchCriteria.level)
        _fieldsFilterText = State(initialValue: viewModel.searchCriteria.fields.joined(separator: ", "))
        self.container = container
    }

    var body: some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.isLoadingInitial {
                        ProgressView()
                    }

                    Button {
                        isFilterSheetPresented = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 28, alignment: .leading)

                            // Keep badge inside the toolbar item frame to avoid clipping.
                            // For 99+ values, clamp text to keep width predictable.
                            let badgeText = appliedFilterCount > 99 ? "99+" : "\(appliedFilterCount)"

                            if appliedFilterCount > 0 {
                                Text(badgeText)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                    .padding(.trailing, 2)
                                    .padding(.top, 0)
                            }
                        }
                        .frame(width: 40, height: 28)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open filters")
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                filterSheet
            }
            .task {
                await viewModel.loadInitialIfNeeded()
            }
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Digimon") {
                    TextField("Name (e.g. Agumon)", text: $nameFilter)
                    Toggle("Exact name match", isOn: $exactFilter)
                    Toggle("X-Antibody", isOn: $xAntibodyFilter)
                }

                Section("Type") {
                    TextField("Type (e.g. Reptile)", text: $typeFilter)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    suggestionChips(options: suggestedTypes, onTap: { typeFilter = $0 })
                }

                Section("Attribute") {
                    TextField("Attribute (e.g. Vaccine)", text: $attributeFilter)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    suggestionChips(options: suggestedAttributes, onTap: { attributeFilter = $0 })
                }

                Section("Level") {
                    TextField("Level (e.g. Child)", text: $levelFilter)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    suggestionChips(options: suggestedLevels, onTap: { levelFilter = $0 })
                }

                Section("Fields") {
                    TextField("Fields (comma separated)", text: $fieldsFilterText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    multiSelectChips(options: suggestedFields)
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        clearDraftFilters()
                    }
                    .disabled(isApplyingFilters)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        applyFiltersFromSheet()
                    } label: {
                        if isApplyingFilters {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Applying...")
                            }
                        } else {
                            Text("Apply")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isApplyingFilters)
                }
            }
            .interactiveDismissDisabled(isApplyingFilters)
            .task {
                await viewModel.loadFilterOptionsIfNeeded()
            }
        }
    }

    private func applyFiltersFromSheet() {
        guard !isApplyingFilters else { return }

        isApplyingFilters = true
        let criteria = buildCriteriaFromDraft()

        Task {
            await viewModel.applySearchCriteria(criteria)
            isApplyingFilters = false
            isFilterSheetPresented = false
        }
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

    @ViewBuilder
    private var listView: some View {
        let scrollContent = ScrollView {
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

        scrollContent.refreshable {
            await viewModel.refresh()
        }
    }

    private var appliedFilterCount: Int {
        var count = 0
        if !viewModel.searchCriteria.name.isEmpty { count += 1 }
        if viewModel.searchCriteria.exact { count += 1 }
        if !viewModel.searchCriteria.type.isEmpty { count += 1 }
        if !viewModel.searchCriteria.attribute.isEmpty { count += 1 }
        if viewModel.searchCriteria.xAntibody { count += 1 }
        if !viewModel.searchCriteria.level.isEmpty { count += 1 }
        if !viewModel.searchCriteria.fields.isEmpty { count += 1 }
        return count
    }

    private func buildCriteriaFromDraft() -> DigimonSearchCriteria {
        DigimonSearchCriteria(
            name: nameFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            exact: exactFilter,
            type: typeFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            attribute: attributeFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            xAntibody: xAntibodyFilter,
            level: levelFilter.trimmingCharacters(in: .whitespacesAndNewlines),
            fields: fieldsFilterText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
    }

    private func clearDraftFilters() {
        nameFilter = ""
        exactFilter = false
        typeFilter = ""
        attributeFilter = ""
        xAntibodyFilter = false
        levelFilter = ""
        fieldsFilterText = ""
    }

    private var selectedFieldSet: Set<String> {
        Set(
            fieldsFilterText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
    }

    private var suggestedTypes: [String] {
        filteredOptions(from: viewModel.filterOptions.types, query: typeFilter)
    }

    private var suggestedAttributes: [String] {
        filteredOptions(from: viewModel.filterOptions.attributes, query: attributeFilter)
    }

    private var suggestedLevels: [String] {
        filteredOptions(from: viewModel.filterOptions.levels, query: levelFilter)
    }

    private var suggestedFields: [String] {
        let query = fieldsFilterText.components(separatedBy: ",").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return filteredOptions(from: viewModel.filterOptions.fields, query: query)
    }

    private func filteredOptions(from options: [String], query: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return Array(options.prefix(8))
        }
        return Array(
            options
                .filter { $0.lowercased().contains(trimmed.lowercased()) }
                .prefix(8)
        )
    }

    @ViewBuilder
    private func suggestionChips(options: [String], onTap: @escaping (String) -> Void) -> some View {
        if !options.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        Button(option) {
                            onTap(option)
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private func multiSelectChips(options: [String]) -> some View {
        if !options.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        let isSelected = selectedFieldSet.contains(option)
                        Button(option) {
                            handleFieldChipTap(option)
                        }
                        .buttonStyle(.bordered)
                        .tint(isSelected ? .accentColor : .secondary)
                        .font(.caption)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func toggleField(_ field: String) {
        var values = selectedFieldSet
        if values.contains(field) {
            values.remove(field)
        } else {
            values.insert(field)
        }
        fieldsFilterText = values.sorted().joined(separator: ", ")
    }

    private func handleFieldChipTap(_ field: String) {
        let tokens = fieldsFilterText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var values = Set(tokens)
        let trailingToken = fieldsFilterText
            .components(separatedBy: ",")
            .last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let isTrailingPartial = !trailingToken.isEmpty
            && trailingToken.caseInsensitiveCompare(field) != .orderedSame
            && field.lowercased().contains(trailingToken.lowercased())
            && !values.contains(field)

        if isTrailingPartial {
            values.remove(trailingToken)
        }

        toggleFieldInSet(field, values: &values)
        fieldsFilterText = values.sorted().joined(separator: ", ")
    }

    private func toggleFieldInSet(_ field: String, values: inout Set<String>) {
        if values.contains(field) {
            values.remove(field)
        } else {
            values.insert(field)
        }
    }
}

#Preview {
    DigimonListView(
        viewModel: AppContainer.shared.makeDigimonListViewModel(),
        container: AppContainer.shared
    )
}
