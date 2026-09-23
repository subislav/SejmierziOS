import Foundation

public struct GetClubDetailUseCase: Sendable {
    private let repository: ClubRepository
    private let benchmark: Benchmark

    public init(repository: ClubRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, id: String, source: DataSource) async -> DomainResult<ClubDetail> {
        await benchmark.measured(
            category: .useCase,
            name: "GetClubDetailUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "Clubs"
            ]
        ) {
            await repository.getClub(term: term, id: id, source: source)
        }
    }
}
