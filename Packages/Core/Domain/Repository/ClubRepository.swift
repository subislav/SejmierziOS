import Foundation

public protocol ClubRepository: Sendable {
    func getClubs(
        term: Term,
        source: DataSource,
        offset: Int,
        limit: Int
    ) async -> DomainResult<Page<Club>>

    func getClub(
        term: Term,
        id: String,
        source: DataSource
    ) async -> DomainResult<ClubDetail>
}
