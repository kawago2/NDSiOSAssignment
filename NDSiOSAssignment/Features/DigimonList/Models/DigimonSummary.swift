//
//  DigimonSummary.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonSummary: Identifiable, Equatable {
    let id: Int
    let name: String
    let imageURL: URL?
    let detailURL: URL?
}

struct DigimonPageInfo: Equatable {
    let currentPage: Int
    let elementsOnPage: Int
    let totalElements: Int
    let totalPages: Int
    let hasNextPage: Bool
}

struct DigimonPage: Equatable {
    let items: [DigimonSummary]
    let pageInfo: DigimonPageInfo
}
