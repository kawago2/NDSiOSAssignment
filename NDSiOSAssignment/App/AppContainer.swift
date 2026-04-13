//
//  AppContainer.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

/// Central dependency container for app-wide services.
final class AppContainer {
    static let shared = AppContainer()

    let httpClient: HTTPClient
    let digimonRepository: DigimonRepository

    private init() {
        httpClient = URLSessionHTTPClient(baseURL: AppEnvironment.baseURL)
        digimonRepository = RemoteDigimonRepository(httpClient: httpClient)
    }

    func makeDigimonListViewModel() -> DigimonListViewModel {
        DigimonListViewModel(repository: digimonRepository)
    }

    func makeDigimonDetailViewModel(digimonID: Int) -> DigimonDetailViewModel {
        DigimonDetailViewModel(digimonID: digimonID, repository: digimonRepository)
    }
}

enum AppEnvironment {
    static let baseURL = URL(string: "https://digi-api.com/api/v1")!
}
