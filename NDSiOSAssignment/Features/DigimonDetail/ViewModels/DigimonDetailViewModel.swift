//
//  DigimonDetailViewModel.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation
import Combine

@MainActor
final class DigimonDetailViewModel: ObservableObject {
    @Published private(set) var detail: DigimonDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var inlineErrorMessage: String?

    private let repository: DigimonRepository
    private let digimonID: Int

    init(digimonID: Int, repository: DigimonRepository) {
        self.digimonID = digimonID
        self.repository = repository
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        if detail == nil {
            errorMessage = nil
        }
        inlineErrorMessage = nil

        defer { isLoading = false }

        do {
            detail = try await repository.fetchDigimonDetail(id: digimonID)
        } catch {
            let message = error.userFacingMessage(default: "Failed to load Digimon details.")
            if detail == nil {
                errorMessage = message
            } else {
                inlineErrorMessage = message
            }
        }
    }

    func clearInlineError() {
        inlineErrorMessage = nil
    }
}
