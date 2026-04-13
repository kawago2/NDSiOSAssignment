//
//  NetworkError.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noInternetConnection
    case requestTimedOut
    case invalidResponse
    case decodingFailed
    case serverError(statusCode: Int)
    case transportError(underlying: URLError)
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again."
        case .requestTimedOut:
            return "The request timed out. Please try again."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "The server returned unexpected data. Please try again later."
        case .serverError(let statusCode):
            switch statusCode {
            case 400:
                return "Invalid request. Please update filters and try again."
            case 404:
                return "Requested data was not found."
            case 429:
                return "Too many requests. Please wait a moment and try again."
            case 500...599:
                return "The server is temporarily unavailable. Please try again later."
            default:
                return "Request failed with status code \(statusCode)."
            }
        case .transportError:
            return "A network error occurred while sending the request."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
