import Foundation

public struct BenchmarkStatistics: Sendable, Equatable {
    public let name: String
    public let slice: String?
    public let unit: String
    public let sampleCount: Int
    public let mean: Double
    public let median: Double
    public let min: Double
    public let max: Double
    public let p90: Double
    public let p95: Double
    public let stdDev: Double

    public var stableId: String {
        "\(name)|\(slice ?? "")|\(unit)"
    }

    public static func from(
        name: String,
        slice: String?,
        unit: String,
        values: [Double]
    ) -> BenchmarkStatistics {
        precondition(!values.isEmpty, "Cannot compute statistics over an empty sample")

        let sorted = values.sorted()
        let n = Double(sorted.count)


        let mean = sorted.reduce(0, +) / n


        let variance = sorted.reduce(0) { sum, value in
            sum + pow(value - mean, 2)
        } / n

        return BenchmarkStatistics(
            name: name,
            slice: slice,
            unit: unit,
            sampleCount: sorted.count,
            mean: mean,
            median: percentile(sorted: sorted, p: 50.0),
            min: sorted.first!,
            max: sorted.last!,
            p90: percentile(sorted: sorted, p: 90.0),
            p95: percentile(sorted: sorted, p: 95.0),
            stdDev: sqrt(variance)
        )
    }

    private static func percentile(sorted: [Double], p: Double) -> Double {
        if sorted.count == 1 { return sorted[0] }

        let rank = (p / 100.0) * Double(sorted.count - 1)
        let lower = Int(rank)
        let upper = Swift.min(lower + 1, sorted.count - 1)
        let weight = rank - Double(lower)

        return sorted[lower] * (1.0 - weight) + sorted[upper] * weight
    }
}

public extension Array where Element == Metric {

    func summarize(warmup: Int = 0) -> [BenchmarkStatistics] {
        var grouped: [String: [Metric]] = [:]

        for metric in self {
            let sliceVal = metric.tags[MetricTag.slice] ?? "nil"
            let key = "\(metric.name)||\(sliceVal)"
            grouped[key, default: []].append(metric)
        }

        var results: [BenchmarkStatistics] = []

        for (_, group) in grouped {
            guard let firstMetric = group.first else { continue }

            let name = firstMetric.name
            let slice = firstMetric.tags[MetricTag.slice]
            let unit = firstMetric.unit

            let cleanValues = group.dropFirst(warmup).map { $0.value }

            if !cleanValues.isEmpty {
                results.append(
                    BenchmarkStatistics.from(
                        name: name,
                        slice: slice,
                        unit: unit,
                        values: cleanValues
                    )
                )
            }
        }

        return results.sorted { lhs, rhs in
            if lhs.name == rhs.name {
                return (lhs.slice ?? "") < (rhs.slice ?? "")
            }
            return lhs.name < rhs.name
        }
    }
}
