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
        attribute: String? = nil,
        exact: Bool? = nil,
        xAntibody: Bool? = nil,
        level: String? = nil
    ) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]

        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        if let exact {
            queryItems.append(URLQueryItem(name: "exact", value: exact ? "true" : "false"))
        }

        if let attribute, !attribute.isEmpty {
            queryItems.append(URLQueryItem(name: "attribute", value: attribute))
        }

        if let xAntibody {
            queryItems.append(URLQueryItem(name: "xAntibody", value: xAntibody ? "true" : "false"))
        }

        if let level, !level.isEmpty {
            queryItems.append(URLQueryItem(name: "level", value: level))
        }

        return APIEndpoint(path: "/digimon", queryItems: queryItems)
    }

    static func detail(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/digimon/\(id)")
    }

    static func detail(name: String) -> APIEndpoint {
        APIEndpoint(path: "/digimon/\(name)")
    }

    static func attribute(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/attribute/\(id)")
    }

    static func attribute(name: String) -> APIEndpoint {
        APIEndpoint(path: "/attribute/\(name)")
    }

    static func attributeList(page: Int, pageSize: Int = 50, name: String? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        return APIEndpoint(path: "/attribute", queryItems: queryItems)
    }

    static func field(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/field/\(id)")
    }

    static func field(name: String) -> APIEndpoint {
        APIEndpoint(path: "/field/\(name)")
    }

    static func fieldList(page: Int, pageSize: Int = 50, name: String? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        return APIEndpoint(path: "/field", queryItems: queryItems)
    }

    static func level(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/level/\(id)")
    }

    static func level(name: String) -> APIEndpoint {
        APIEndpoint(path: "/level/\(name)")
    }

    static func levelList(page: Int, pageSize: Int = 50, name: String? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        return APIEndpoint(path: "/level", queryItems: queryItems)
    }

    static func type(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/type/\(id)")
    }

    static func type(name: String) -> APIEndpoint {
        APIEndpoint(path: "/type/\(name)")
    }

    static func typeList(page: Int, pageSize: Int = 50, name: String? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        return APIEndpoint(path: "/type", queryItems: queryItems)
    }

    static func skill(id: Int) -> APIEndpoint {
        APIEndpoint(path: "/skill/\(id)")
    }

    static func skill(name: String) -> APIEndpoint {
        APIEndpoint(path: "/skill/\(name)")
    }
}
