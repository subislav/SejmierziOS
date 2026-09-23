import Foundation

public struct GetVotingDetailUseCase: Sendable {
    private let repository: VotingRepository
    private let benchmark: Benchmark

    public init(repository: VotingRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, sitting: Int, votingNumber: Int, source: DataSource) async -> DomainResult<VotingDetail> {
        await benchmark.measured(
            category: .useCase,
            name: "GetVotingDetailUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "Votings"
            ]
        ) {
            await repository.getVoting(term: term, sitting: sitting, votingNumber: votingNumber, source: source)
        }
    }
}
