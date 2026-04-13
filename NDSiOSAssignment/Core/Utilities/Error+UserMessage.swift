//
//  Error+UserMessage.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

extension Error {
    func userFacingMessage(default defaultMessage: String) -> String {
        if let networkError = self as? NetworkError {
            return networkError.errorDescription ?? defaultMessage
        }

        if self is DecodingError {
            return "The server returned unexpected data. Please try again later."
        }

        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Please check your network and try again."
            case .timedOut:
                return "The request timed out. Please try again."
            default:
                break
            }
        }

        return (self as? LocalizedError)?.errorDescription ?? defaultMessage
    }
}
