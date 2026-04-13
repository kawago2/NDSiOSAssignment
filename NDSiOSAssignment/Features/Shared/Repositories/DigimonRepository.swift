//
//  DigimonRepository.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

protocol DigimonRepository {
    func fetchDigimonPage(
        page: Int,
        pageSize: Int,
        criteria: DigimonSearchCriteria
    ) async throws -> DigimonPage

    func fetchDigimonDetail(id: Int) async throws -> DigimonDetail
}
