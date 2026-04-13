//
//  DigimonDetailResponseDTO.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonDetailResponseDTO: Decodable {
    let id: Int
    let name: String
    let xAntibody: Bool
    let images: [DigimonImageDTO]
    let levels: [DigimonLevelDTO]
    let types: [DigimonTypeDTO]
    let attributes: [DigimonAttributeDTO]
    let fields: [DigimonFieldDTO]
    let releaseDate: String?
    let descriptions: [DigimonDescriptionDTO]
    let skills: [DigimonSkillDTO]
}

struct DigimonImageDTO: Decodable {
    let href: String
    let transparent: Bool
}

struct DigimonLevelDTO: Decodable {
    let id: Int
    let level: String
}

struct DigimonTypeDTO: Decodable {
    let id: Int
    let type: String
}

struct DigimonAttributeDTO: Decodable {
    let id: Int
    let attribute: String
}

struct DigimonFieldDTO: Decodable {
    let id: Int
    let field: String
    let image: String?
}

struct DigimonDescriptionDTO: Decodable {
    let origin: String?
    let language: String
    let description: String
}

struct DigimonSkillDTO: Decodable {
    let id: Int
    let skill: String
    let translation: String?
    let description: String?
}

extension DigimonDetailResponseDTO {
    func toDomain(preferredLanguage: String = "en_us") -> DigimonDetail {
        let descriptionForLanguage = descriptions.first(where: { $0.language == preferredLanguage })?.description
            ?? descriptions.first?.description

        return DigimonDetail(
            id: id,
            name: name,
            isXAntibody: xAntibody,
            images: images.map {
                DigimonImage(url: URL(string: $0.href), isTransparent: $0.transparent)
            },
            levels: levels.map(\.level),
            types: types.map(\.type),
            attributes: attributes.map(\.attribute),
            fields: fields.map {
                DigimonField(id: $0.id, name: $0.field, imageURL: URL(string: $0.image ?? ""))
            },
            releaseDate: releaseDate,
            description: descriptionForLanguage,
            skills: skills.map {
                DigimonSkill(
                    id: $0.id,
                    name: $0.skill,
                    translation: $0.translation,
                    description: $0.description
                )
            }
        )
    }
}
