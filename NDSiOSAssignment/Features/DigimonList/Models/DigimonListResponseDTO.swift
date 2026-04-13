//
//  DigimonListResponseDTO.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonListResponseDTO: Decodable {
    let content: [DigimonListItemDTO]
    let pageable: DigimonPageableDTO

    private enum CodingKeys: String, CodingKey {
        case content
        case pageable
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decodeIfPresent([DigimonListItemDTO].self, forKey: .content) ?? []
        pageable = try container.decode(DigimonPageableDTO.self, forKey: .pageable)
    }
}

struct DigimonListItemDTO: Decodable {
    let id: Int
    let name: String
    let href: String?
    let image: String?
}

struct DigimonPageableDTO: Decodable {
    let currentPage: Int
    let elementsOnPage: Int
    let totalElements: Int
    let totalPages: Int
    let previousPage: String?
    let nextPage: String?
}

extension DigimonListResponseDTO {
    func toDomain() -> DigimonPage {
        let mappedItems = content.map { item in
            DigimonSummary(
                id: item.id,
                name: item.name,
                imageURL: item.image.flatMap(URL.init(string:)),
                detailURL: item.href.flatMap(URL.init(string:))
            )
        }

        let pageInfo = DigimonPageInfo(
            currentPage: pageable.currentPage,
            elementsOnPage: pageable.elementsOnPage,
            totalElements: pageable.totalElements,
            totalPages: pageable.totalPages,
            hasNextPage: (pageable.nextPage?.isEmpty == false)
        )

        return DigimonPage(items: mappedItems, pageInfo: pageInfo)
    }
}
