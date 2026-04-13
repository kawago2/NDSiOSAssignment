//
//  URLSessionHTTPClient.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try endpoint.makeRequest(baseURL: baseURL)
        NetworkConsoleLogger.logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                NetworkConsoleLogger.logError(request: request, error: NetworkError.invalidResponse)
                throw NetworkError.invalidResponse
            }

            NetworkConsoleLogger.logResponse(request: request, response: httpResponse, data: data)

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            return data
        } catch let urlError as URLError {
            NetworkConsoleLogger.logError(request: request, error: urlError)
            throw map(urlError)
        } catch let networkError as NetworkError {
            NetworkConsoleLogger.logError(request: request, error: networkError)
            throw networkError
        } catch {
            NetworkConsoleLogger.logError(request: request, error: error)
            throw NetworkError.unknown(underlying: error)
        }
    }

    private func map(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return .noInternetConnection
        case .timedOut:
            return .requestTimedOut
        default:
            return .transportError(underlying: error)
        }
    }
}
