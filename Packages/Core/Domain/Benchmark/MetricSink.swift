import Foundation

public protocol MetricSink: Sendable {
    func record(metric: Metric)
}

public protocol MetricRepository: MetricSink {
    var metricsStream: AsyncStream<[Metric]> { get }

    func snapshot() -> [Metric]
    func clear()
}
