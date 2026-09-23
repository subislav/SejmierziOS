import Foundation

public protocol VotingRepository: Sendable {
    func getVotings(
        term: Term,
        source: DataSource,
        offset: Int,
        limit: Int
    ) async -> DomainResult<Page<Voting>>

    func getVoting(
        term: Term,
        sitting: Int,
        votingNumber: Int,
        source: DataSource
    ) async -> DomainResult<VotingDetail>
}
