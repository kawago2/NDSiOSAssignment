//
//  DigimonFilterOptions.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonFilterOptions: Equatable {
    let attributes: [String]
    let types: [String]
    let levels: [String]
    let fields: [String]

    static let empty = DigimonFilterOptions(attributes: [], types: [], levels: [], fields: [])
}
