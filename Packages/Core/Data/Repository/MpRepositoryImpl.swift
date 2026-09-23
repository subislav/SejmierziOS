import Foundation
import Domain

public struct MpRepositoryImpl: MpRepository {
    private let api: SejmApi
    private let local: MpLocalDataSource

    public init(api: SejmApi, local: MpLocalDataSource) {
        self.api = api
        self.local = local
    }

    public func getMps(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Mp>> {
        switch source {
        case .network:
            return await performSafeCall {
                let mps = try await api.getMps(term: term.number, offset: offset, limit: limit).map { $0.toDomain() }

                Task.detached {
                    try? await local.upsertAll(term: term.number, mps: mps)
                }

                return Page(items: mps, offset: offset, limit: limit)
            }

        case .local:
            let result: DomainResult<Page<Mp>> = await performSafeCall {
                let mps = try await local.readPage(term: term.number, offset: offset, limit: limit)
                return Page(items: mps, offset: offset, limit: limit)
            }
            return result.emptyAsNotCached(offset: offset)
        }
    }

    public func getMp(term: Term, id: Int, source: DataSource) async -> DomainResult<Mp> {
        switch source {
        case .network:
            return await performSafeCall {
                let mp = try await api.getMp(term: term.number, id: id).toDomain()
                Task.detached {
                    try? await local.upsertAll(term: term.number, mps: [mp])
                }
                return mp
            }

        case .local:
            return await performSafeCall {
                guard let mp = try await local.readById(term: term.number, id: id) else {
                    throw DomainError.notCached
                }
                return mp
            }
        }
    }
}
