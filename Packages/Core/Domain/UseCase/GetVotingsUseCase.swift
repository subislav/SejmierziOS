import Foundation

public struct GetVotingsUseCase: Sendable {
    private let repository: VotingRepository
    private let benchmark: Benchmark

    public init(repository: VotingRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Voting>> {
        await benchmark.measured(
            category: .useCase,
            name: "GetVotingsUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "Votings"
            ]
        ) {
            await repository.getVotings(term: term, source: source, offset: offset, limit: limit)
        }
    }
}
