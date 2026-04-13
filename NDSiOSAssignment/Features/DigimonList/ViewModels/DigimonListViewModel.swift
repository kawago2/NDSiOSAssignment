//
//  DigimonListViewModel.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation
import Combine

@MainActor
final class DigimonListViewModel: ObservableObject {
    @Published private(set) var items: [DigimonSummary] = []
    @Published private(set) var isLoadingInitial = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMorePages = true
    @Published private(set) var errorMessage: String?
    @Published private(set) var paginationErrorMessage: String?
    @Published private(set) var filterOptions: DigimonFilterOptions = .empty
    @Published var searchCriteria: DigimonSearchCriteria = .empty

    let pageSize = 8

    private let repository: DigimonRepository
    private var currentPage = 0
    private var pendingItems: [DigimonSummary] = []

    init(repository: DigimonRepository) {
        self.repository = repository
    }

    func loadFilterOptionsIfNeeded() async {
        guard filterOptions == .empty else { return }

        do {
            filterOptions = try await repository.fetchFilterOptions()
        } catch {
            // Filter options are optional for interaction. Keep manual input available.
        }
    }

    func loadInitialIfNeeded() async {
        guard items.isEmpty, !isLoadingInitial else { return }
        await refresh()
    }

    func refresh() async {
        errorMessage = nil
        paginationErrorMessage = nil
        currentPage = 0
        hasMorePages = true
        pendingItems = []
        items = []
        await fetchDisplayBatch(isInitial: true)
    }

    func applySearchCriteria(_ criteria: DigimonSearchCriteria) async {
        guard criteria != searchCriteria else { return }
        searchCriteria = criteria
        await refresh()
    }

    func loadNextPageIfNeeded(currentItem: DigimonSummary?) async {
        guard hasMorePages, !isLoadingInitial, !isLoadingMore else { return }
        paginationErrorMessage = nil

        guard let currentItem else {
            await fetchDisplayBatch(isInitial: items.isEmpty)
            return
        }

        guard let index = items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let thresholdIndex = max(items.count - 2, 0)

        if index >= thresholdIndex {
            await fetchDisplayBatch(isInitial: false)
        }
    }

    func clearPaginationError() {
        paginationErrorMessage = nil
    }

    private func fetchDisplayBatch(isInitial: Bool) async {
        if isInitial {
            isLoadingInitial = true
        } else {
            isLoadingMore = true
        }

        defer {
            isLoadingInitial = false
            isLoadingMore = false
        }

        do {
            var batchPool: [DigimonSummary] = pendingItems
            pendingItems = []

            while batchPool.count < pageSize && hasMorePages {
                let page = try await repository.fetchDigimonPage(
                    page: currentPage,
                    pageSize: pageSize,
                    criteria: searchCriteria
                )

                currentPage += 1
                hasMorePages = page.pageInfo.hasNextPage
                batchPool.append(contentsOf: page.items)

                if !page.pageInfo.hasNextPage {
                    break
                }
            }

            let nextBatch = Array(batchPool.prefix(pageSize))
            pendingItems = Array(batchPool.dropFirst(nextBatch.count))
            items.append(contentsOf: nextBatch)

            hasMorePages = hasMorePages || !pendingItems.isEmpty
        } catch {
            let message = error.userFacingMessage(default: "Failed to load Digimon.")
            if isInitial {
                errorMessage = message
            } else {
                paginationErrorMessage = message
            }
        }
    }
}
