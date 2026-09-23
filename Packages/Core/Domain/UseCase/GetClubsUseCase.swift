import Foundation

public struct GetClubsUseCase: Sendable {
    private let repository: ClubRepository
    private let benchmark: Benchmark

    public init(repository: ClubRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Club>> {
        await benchmark.measured(
            category: .useCase,
            name: "GetClubsUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "Clubs"
            ]
        ) {
            await repository.getClubs(term: term, source: source, offset: offset, limit: limit)
        }
    }
}
