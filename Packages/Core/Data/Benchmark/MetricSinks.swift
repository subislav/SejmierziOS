import Foundation
import Domain

public struct ConsoleMetricSink: MetricSink {
    public init() {}

    public func record(metric: Metric) {
        let tagsString = metric.tags.map { "\($0.key)=\($0.value)" }.joined(separator: ";")
        print("SEJMIERZ_BENCH|\(metric.category.rawValue)|\(metric.name)|\(metric.value)|\(metric.unit)|\(tagsString)")
    }
}

public struct CompositeMetricSink: MetricSink {
    private let sinks: [MetricSink]

    public init(sinks: [MetricSink]) {
        self.sinks = sinks
    }

    public func record(metric: Metric) {
        for sink in sinks {
            sink.record(metric: metric)
        }
    }
}

public struct EnrichingMetricSink: MetricSink {
    private let delegate: MetricSink
    private let runContext: RunContextProvider

    public init(delegate: MetricSink, runContext: RunContextProvider) {
        self.delegate = delegate
        self.runContext = runContext
    }

    public func record(metric: Metric) {
        var mergedTags = runContext.globalTags()

        for (key, value) in metric.tags {
            mergedTags[key] = value
        }

        let enrichedMetric = Metric(
            name: metric.name,
            category: metric.category,
            value: metric.value,
            unit: metric.unit,
            timestampMs: metric.timestampMs,
            tags: mergedTags
        )

        delegate.record(metric: enrichedMetric)
    }
}

