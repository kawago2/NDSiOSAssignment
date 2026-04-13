//
//  RemoteDigimonRepository.swift
//  NDSiOSAssignment
//
//  Created by kawago on 13/04/26.
//

import Foundation

final class RemoteDigimonRepository: DigimonRepository {
    private let detailFilterChunkSize = 4

    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let detailCache = DigimonDetailCache()

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
            attribute: criteria.attribute.trimmedOrNil,
            exact: criteria.exact ? true : nil,
            xAntibody: criteria.xAntibody ? true : nil,
            level: criteria.level.trimmedOrNil
        )

        do {
            let data = try await httpClient.send(endpoint)
            let dto = try decoder.decode(DigimonListResponseDTO.self, from: data)
            let page = dto.toDomain()

            if criteria.type.trimmedOrNil == nil, criteria.fields.isEmpty {
                return page
            }

            let filteredItems = try await filterByDetailMetadata(page.items, criteria: criteria)
            return DigimonPage(items: filteredItems, pageInfo: page.pageInfo)
        } catch _ as DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw error
        }
    }

    func fetchDigimonDetail(id: Int) async throws -> DigimonDetail {
        if let cached = await detailCache.value(for: id) {
            return cached
        }

        let endpoint = DigimonAPIEndpoint.detail(id: id)
        do {
            let data = try await httpClient.send(endpoint)
            let dto = try decoder.decode(DigimonDetailResponseDTO.self, from: data)
            let detail = dto.toDomain()
            await detailCache.set(detail, for: id)
            return detail
        } catch _ as DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw error
        }
    }

    func fetchDigimonDetail(name: String) async throws -> DigimonDetail {
        let endpoint = DigimonAPIEndpoint.detail(name: name)
        do {
            let data = try await httpClient.send(endpoint)
            let dto = try decoder.decode(DigimonDetailResponseDTO.self, from: data)
            return dto.toDomain()
        } catch _ as DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw error
        }
    }

    func fetchFilterOptions() async throws -> DigimonFilterOptions {
        async let attributesTask = fetchTaxonomyNames(category: .attribute)
        async let typesTask = fetchTaxonomyNames(category: .type)
        async let levelsTask = fetchTaxonomyNames(category: .level)
        async let fieldsTask = fetchTaxonomyNames(category: .field)

        return try await DigimonFilterOptions(
            attributes: attributesTask,
            types: typesTask,
            levels: levelsTask,
            fields: fieldsTask
        )
    }

    private func filterByDetailMetadata(
        _ items: [DigimonSummary],
        criteria: DigimonSearchCriteria
    ) async throws -> [DigimonSummary] {
        let wantedType = criteria.type.trimmedOrNil?.lowercased()
        let wantedFields = Set(
            criteria.fields
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }
        )

        var indexedMatches: [(index: Int, item: DigimonSummary)] = []
        var start = 0

        while start < items.count {
            let end = min(start + detailFilterChunkSize, items.count)
            let chunk = Array(items[start..<end].enumerated()).map { (offset, item) in
                (index: start + offset, item: item)
            }

            let chunkMatches = try await withThrowingTaskGroup(of: (Int, DigimonSummary?).self) { group in
                for entry in chunk {
                    group.addTask { [self] in
                        let detail = try await fetchDigimonDetail(id: entry.item.id)

                        let typeMatches: Bool = {
                            guard let wantedType else { return true }
                            return detail.types.contains { $0.lowercased() == wantedType }
                        }()

                        let fieldsMatches: Bool = {
                            guard !wantedFields.isEmpty else { return true }
                            let detailFieldNames = Set(detail.fields.map { $0.name.lowercased() })
                            return !wantedFields.isDisjoint(with: detailFieldNames)
                        }()

                        let matchedItem = (typeMatches && fieldsMatches) ? entry.item : nil
                        return (entry.index, matchedItem)
                    }
                }

                var localMatches: [(index: Int, item: DigimonSummary)] = []
                for try await (index, matched) in group {
                    if let matched {
                        localMatches.append((index: index, item: matched))
                    }
                }
                return localMatches
            }

            indexedMatches.append(contentsOf: chunkMatches)
            start = end
        }

        return indexedMatches
            .sorted { $0.index < $1.index }
            .map(\.item)
    }

    private func fetchTaxonomyNames(category: TaxonomyCategory) async throws -> [String] {
        var page = 0
        var hasNextPage = true
        var names: [String] = []

        while hasNextPage {
            let endpoint = endpointForCategory(category, page: page)
            let data = try await httpClient.send(endpoint)

            let dto: TaxonomyListResponseDTO
            do {
                dto = try decoder.decode(TaxonomyListResponseDTO.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }

            names.append(contentsOf: dto.content.fields.map(\.name))
            hasNextPage = dto.pageable.nextPage?.isEmpty == false
            page += 1
        }

        return Array(Set(names)).sorted()
    }

    private func endpointForCategory(_ category: TaxonomyCategory, page: Int) -> APIEndpoint {
        switch category {
        case .attribute:
            return DigimonAPIEndpoint.attributeList(page: page, pageSize: 50, name: nil)
        case .type:
            return DigimonAPIEndpoint.typeList(page: page, pageSize: 50, name: nil)
        case .level:
            return DigimonAPIEndpoint.levelList(page: page, pageSize: 50, name: nil)
        case .field:
            return DigimonAPIEndpoint.fieldList(page: page, pageSize: 50, name: nil)
        }
    }
}

private enum TaxonomyCategory {
    case attribute
    case type
    case level
    case field
}

private extension String {
    var trimmedOrNil: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

private struct TaxonomyListResponseDTO: Decodable {
    let content: TaxonomyContentDTO
    let pageable: DigimonPageableDTO
}

private struct TaxonomyContentDTO: Decodable {
    let fields: [TaxonomyFieldDTO]
}

private struct TaxonomyFieldDTO: Decodable {
    let id: Int
    let name: String
    let href: String?
}

private actor DigimonDetailCache {
    private var storage: [Int: DigimonDetail] = [:]

    func value(for id: Int) -> DigimonDetail? {
        storage[id]
    }

    func set(_ detail: DigimonDetail, for id: Int) {
        storage[id] = detail
    }
}
