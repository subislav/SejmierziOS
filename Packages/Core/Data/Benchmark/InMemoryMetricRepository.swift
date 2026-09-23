import Foundation
import Domain

public final class InMemoryMetricRepository: MetricRepository, MetricSink, @unchecked Sendable {
    private var _metrics: [Domain.Metric] = []
    private let lock = NSLock()

    private let stream: AsyncStream<[Domain.Metric]>
    private let continuation: AsyncStream<[Domain.Metric]>.Continuation

    public var metrics: AsyncStream<[Domain.Metric]> { stream }
    public var metricsStream: AsyncStream<[Domain.Metric]> { stream }

    public init() {
        let (s, c) = AsyncStream<[Domain.Metric]>.makeStream()
        self.stream = s
        self.continuation = c
        c.yield([])
    }

    public func record(metric: Domain.Metric) {
        lock.lock()
        _metrics.append(metric)
        let current = _metrics
        lock.unlock()
        continuation.yield(current)
    }

    public func snapshot() -> [Domain.Metric] {
        lock.lock()
        defer { lock.unlock() }
        return _metrics
    }

    public func clear() {
        lock.lock()
        _metrics.removeAll()
        lock.unlock()
        continuation.yield([])
    }
}
