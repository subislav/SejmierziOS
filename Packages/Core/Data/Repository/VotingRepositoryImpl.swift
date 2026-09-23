import Foundation
import Domain

public struct VotingRepositoryImpl: VotingRepository {
    private let api: SejmApi
    private let local: VotingLocalDataSource

    private let defaultDateFrom = "2024-01-01"
    private let defaultDateTo = "2024-12-31"

    public init(api: SejmApi, local: VotingLocalDataSource) {
        self.api = api
        self.local = local
    }

    public func getVotings(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Voting>> {
        switch source {
        case .network:
            return await performSafeCall {
                let votings = try await api.searchVotings(
                    term: term.number,
                    offset: offset,
                    limit: limit,
                    dateFrom: defaultDateFrom,
                    dateTo: defaultDateTo,
                    title: nil
                ).map { $0.toDomain() }

                Task.detached {
                    try? await local.upsertAll(term: term.number, votings: votings)
                }
                return Page(items: votings, offset: offset, limit: limit)
            }

        case .local:
            let result: DomainResult<Page<Voting>> = await performSafeCall {
                let votings = try await local.readPage(term: term.number, offset: offset, limit: limit)
                return Page(items: votings, offset: offset, limit: limit)
            }
            return result.emptyAsNotCached(offset: offset)
        }
    }

    public func getVoting(term: Term, sitting: Int, votingNumber: Int, source: DataSource) async -> DomainResult<VotingDetail> {
        switch source {
        case .network:
            return await performSafeCall {
                let detail = try await api.getVoting(term: term.number, sitting: sitting, votingNumber: votingNumber).toDetailDomain()
                Task.detached {
                    try? await local.upsertAll(term: term.number, votings: [detail.voting])
                }
                return detail
            }

        case .local:
            return await performSafeCall {
                guard let voting = try await local.readById(term: term.number, sitting: sitting, votingNumber: votingNumber) else {
                    throw DomainError.notCached
                }
                return VotingDetail(voting: voting, clubVotes: [])
            }
        }
    }
}
