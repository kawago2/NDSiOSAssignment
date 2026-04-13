//
//  DigimonSearchCriteria.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

struct DigimonSearchCriteria: Equatable {
    var name: String = ""
    var exact: Bool = false
    var type: String = ""
    var attribute: String = ""
    var xAntibody: Bool = false
    var level: String = ""
    var fields: [String] = []

    static let empty = DigimonSearchCriteria()
}
