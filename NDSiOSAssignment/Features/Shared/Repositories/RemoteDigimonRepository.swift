//
//  RemoteDigimonRepository.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

final class RemoteDigimonRepository: DigimonRepository {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder

    init(httpClient: HTTPClient, decoder: JSONDecoder = JSONDecoder()) {
        self.httpClient = httpClient
        self.decoder = decoder
    }

    func fetchDigimonPage(
        page: Int,
        pageSize: Int,
        criteria: DigimonSearchCriteria
    ) async throws -> DigimonPage {
        let endpoint = DigimonAPIEndpoint.list(
            page: page,
            pageSize: pageSize,
            name: criteria.name.trimmedOrNil,
            type: criteria.type.trimmedOrNil,
            attribute: criteria.attribute.trimmedOrNil,
            level: criteria.level.trimmedOrNil,
            fields: criteria.fields.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        )

        do {
            let data = try await httpClient.send(endpoint)
            let dto = try decoder.decode(DigimonListResponseDTO.self, from: data)
            return dto.toDomain()
        } catch let _ as DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw error
        }
    }

    func fetchDigimonDetail(id: Int) async throws -> DigimonDetail {
        let endpoint = DigimonAPIEndpoint.detail(id: id)
        do {
            let data = try await httpClient.send(endpoint)
            let dto = try decoder.decode(DigimonDetailResponseDTO.self, from: data)
            return dto.toDomain()
        } catch let _ as DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw error
        }
    }
}

private extension String {
    var trimmedOrNil: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
