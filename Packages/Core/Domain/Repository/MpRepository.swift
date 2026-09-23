import Foundation

public protocol MpRepository: Sendable {
    func getMps(
        term: Term,
        source: DataSource,
        offset: Int,
        limit: Int
    ) async -> DomainResult<Page<Mp>>

    func getMp(
        term: Term,
        id: Int,
        source: DataSource
    ) async -> DomainResult<Mp>
}
