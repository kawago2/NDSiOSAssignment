//
//  NetworkConsoleLogger.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

enum NetworkConsoleLogger {
    private static let maxBodyCharacters = 2000

    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "-"
        let url = request.url?.absoluteString ?? "-"
        let headers = request.allHTTPHeaderFields ?? [:]
        let payload = bodyString(from: request.httpBody)

        print("\n===== API REQUEST =====")
        print("METHOD   : \(method)")
        print("ENDPOINT : \(url)")
        print("HEADERS  : \(headers)")
        print("PAYLOAD  : \(payload)")
        print("=======================\n")
        #endif
    }

    static func logResponse(
        request: URLRequest,
        response: HTTPURLResponse,
        data: Data
    ) {
        #if DEBUG
        let method = request.httpMethod ?? "-"
        let url = request.url?.absoluteString ?? "-"
        let statusCode = response.statusCode
        let headers = response.allHeaderFields
        let responseBody = trimmedBodyString(from: data)

        print("\n===== API RESPONSE =====")
        print("METHOD   : \(method)")
        print("ENDPOINT : \(url)")
        print("STATUS   : \(statusCode)")
        print("HEADERS  : \(headers)")
        print("RESPONSE : \(responseBody)")
        print("========================\n")
        #endif
    }

    static func logError(request: URLRequest, error: Error) {
        #if DEBUG
        let method = request.httpMethod ?? "-"
        let url = request.url?.absoluteString ?? "-"

        print("\n===== API ERROR =====")
        print("METHOD   : \(method)")
        print("ENDPOINT : \(url)")
        print("ERROR    : \(error)")
        print("=====================\n")
        #endif
    }

    private static func bodyString(from data: Data?) -> String {
        guard let data else { return "-" }
        return trimmedBodyString(from: data)
    }

    private static func trimmedBodyString(from data: Data) -> String {
        guard let rawText = String(data: data, encoding: .utf8) else {
            return "<non-utf8 body: \(data.count) bytes>"
        }

        if rawText.count <= maxBodyCharacters {
            return rawText
        }

        let prefix = rawText.prefix(maxBodyCharacters)
        return "\(prefix)... [truncated]"
    }
}
