import Foundation

public struct GetMpDetailUseCase: Sendable {
    private let repository: MpRepository
    private let benchmark: Benchmark

    public init(repository: MpRepository, benchmark: Benchmark) {
        self.repository = repository
        self.benchmark = benchmark
    }

    public func callAsFunction(term: Term, id: Int, source: DataSource) async -> DomainResult<Mp> {
        await benchmark.measured(
            category: .useCase,
            name: "GetMpDetailUseCase",
            tags: [
                MetricTag.source: source.rawValue.uppercased(),
                MetricTag.slice: "MPs"
            ]
        ) {
            await repository.getMp(term: term, id: id, source: source)
        }
    }
}
