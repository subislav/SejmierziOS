import Foundation

public struct BenchmarkRunner: Sendable {
    private let benchmark: Benchmark

    public init(benchmark: Benchmark) {
        self.benchmark = benchmark
    }

    public func run<T>(
        category: MetricCategory,
        name: String,
        config: BenchmarkConfig = BenchmarkConfig(),
        baseTags: [String: String] = [:],
        operation: () async throws -> T
    ) async throws {
        for iteration in 0..<config.totalIterations {
            try Task.checkCancellation()

            let isWarmup = iteration < config.warmupIterations
            var tags = baseTags
            tags[MetricTag.iteration] = String(iteration)
            tags[MetricTag.coldWarm] = isWarmup ? "WARMUP" : "CLEAN"

            _ = try await benchmark.measured(category: category, name: name, tags: tags) {
                try await operation()
            }
        }
    }
}
