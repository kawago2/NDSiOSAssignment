//
//  DigimonAPIEndpoint.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

enum DigimonAPIEndpoint {
    static func list(
        page: Int,
        pageSize: Int,
        name: String? = nil,
        type: String? = nil,
        attribute: String? = nil,
        level: String? = nil,
        fields: [String] = []
    ) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        if let type, !type.isEmpty {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }

        if let attribute, !attribute.isEmpty {
            queryItems.append(URLQueryItem(name: "attribute", value: attribute))
        }

        if let level, !level.isEmpty {
            queryItems.append(URLQueryItem(name: "level", value: level))
        }

        fields
            .filter { !$0.isEmpty }
            .forEach { field in
                queryItems.append(URLQueryItem(name: "field", value: field))
            }

        return APIEndpoint(path: "/digimon", queryItems: queryItems)
    }

    static func detail(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/digimon/\(id)")
    }
}
