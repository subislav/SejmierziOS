import Foundation

public struct GetMpsUseCase: Sendable {
    private let repository: MpRepository
    private let benchmark: Benchmark

    public init(repository: MpRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, source: DataSource, offset: Int, limit: Int) async -> DomainResult<Page<Mp>> {
        await benchmark.measured(
            category: .useCase,
            name: "GetMpsUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "MPs"
            ]
        ) {
            await repository.getMps(term: term, source: source, offset: offset, limit: limit)
        }
    }
}
