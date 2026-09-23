import Foundation

public struct Benchmark: Sendable {
    private let sink: MetricSink
    private let clock: @Sendable () -> Int64

    public init(
        sink: MetricSink,
        clock: @escaping @Sendable () -> Int64 = { Int64(Date().timeIntervalSince1970 * 1000) }
    ) {
        self.sink = sink
        self.clock = clock
    }

    public func measured<T>(
        category: MetricCategory,
        name: String,
        tags: [String: String] = [:],
        block: () async throws -> T
    ) async rethrows -> T {
        let start = DispatchTime.now().uptimeNanoseconds
        let result = try await block()
        let end = DispatchTime.now().uptimeNanoseconds

        let elapsedMs = Double(end - start) / 1_000_000.0

        record(name: name, category: category, value: elapsedMs, unit: Metric.unitMs, tags: tags)
        return result
    }

    public func record(
        name: String,
        category: MetricCategory,
        value: Double,
        unit: String,
        tags: [String: String] = [:]
    ) {
        let metric = Metric(
            name: name,
            category: category,
            value: value,
            unit: unit,
            timestampMs: clock(),
            tags: tags
        )
        sink.record(metric: metric)
    }
}
