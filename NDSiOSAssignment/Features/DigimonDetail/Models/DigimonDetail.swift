//
//  DigimonDetail.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonDetail: Identifiable, Equatable {
    let id: Int
    let name: String
    let isXAntibody: Bool
    let images: [DigimonImage]
    let levels: [String]
    let types: [String]
    let attributes: [String]
    let fields: [DigimonField]
    let releaseDate: String?
    let description: String?
    let skills: [DigimonSkill]

    var primaryImageURL: URL? {
        images.first?.url
    }
}

struct DigimonImage: Equatable {
    let url: URL?
    let isTransparent: Bool
}

struct DigimonField: Equatable, Identifiable {
    let id: Int
    let name: String
    let imageURL: URL?
}

struct DigimonSkill: Equatable, Identifiable {
    let id: Int
    let name: String
    let translation: String?
    let description: String?
}
