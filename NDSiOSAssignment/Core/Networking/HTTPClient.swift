//
//  HTTPClient.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

protocol HTTPClient {
    func send(_ endpoint: APIEndpoint) async throws -> Data
}
