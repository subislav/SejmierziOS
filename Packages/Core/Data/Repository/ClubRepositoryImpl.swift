import Foundation
import Domain

public struct ClubRepositoryImpl: ClubRepository {
    private let api: SejmApi
    private let local: ClubLocalDataSource

    public init(api: SejmApi, local: ClubLocalDataSource) {
        self.api = api
        self.local = local
    }

    public func getClubs(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Club>> {
        switch source {
        case .network:
            return await performSafeCall {
                if offset > 0 {
                    return Page(items: [], offset: offset, limit: limit)
                } else {
                    let clubs = try await api.getClubs(term: term.number).map { $0.toDomain() }
                    Task.detached {
                        try? await local.upsertAll(term: term.number, clubs: clubs)
                    }
                    return Page(items: clubs, offset: offset, limit: limit)
                }
            }

        case .local:
            let result: DomainResult<Page<Club>> = await performSafeCall {
                let clubs = try await local.readPage(term: term.number, offset: offset, limit: limit)
                return Page(items: clubs, offset: offset, limit: limit)
            }
            return result.emptyAsNotCached(offset: offset)
        }
    }

    public func getClub(term: Term, id: String, source: DataSource) async -> DomainResult<ClubDetail> {
        switch source {
        case .network:
            return await performSafeCall {
                let detail = try await api.getClub(term: term.number, id: id).toDetailDomain()
                Task.detached {
                    try? await local.upsertAll(term: term.number, clubs: [detail.club])
                }
                return detail
            }

        case .local:
            return await performSafeCall {
                guard let club = try await local.readById(term: term.number, id: id) else {
                    throw DomainError.notCached
                }
                return ClubDetail(club: club, members: [])
            }
        }
    }
}
