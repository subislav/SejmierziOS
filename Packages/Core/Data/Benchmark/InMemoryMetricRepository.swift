import Foundation
import Domain

public final class InMemoryMetricRepository: MetricRepository, MetricSink, @unchecked Sendable {
    private var _metrics: [Domain.Metric] = []
    private let lock = NSLock()
    private let broadcast = AsyncStreamBroadcast<[Domain.Metric]>(initial: [])

    public var metrics: AsyncStream<[Domain.Metric]> { broadcast.subscribe() }
    public var metricsStream: AsyncStream<[Domain.Metric]> { broadcast.subscribe() }

    public init() {}

    public func record(metric: Domain.Metric) {
        lock.lock()
        _metrics.append(metric)
        let current = _metrics
        lock.unlock()
        broadcast.yield(current)
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
        broadcast.yield([])
    }
}
