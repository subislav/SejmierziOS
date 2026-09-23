import Foundation

public enum MetricCsvExporter {
    private static let separator = ","

    public static func toCsv(metrics: [Metric]) -> String {
        guard !metrics.isEmpty else {
            return "name,category,value,unit,timestampMs\n"
        }

        let tagKeys = Array(Set(metrics.flatMap { $0.tags.keys })).sorted()

        var header = ["name", "category", "value", "unit", "timestampMs"]
        header.append(contentsOf: tagKeys)

        var result = header.joined(separator: separator) + "\n"

        for metric in metrics {
            var row = [
                metric.name.escapedForCsv(),
                metric.category.rawValue,
                String(metric.value),
                metric.unit,
                String(metric.timestampMs)
            ]

            for key in tagKeys {
                let tagValue = metric.tags[key] ?? ""
                row.append(tagValue.escapedForCsv())
            }

            result += row.joined(separator: separator) + "\n"
        }

        return result
    }
}

private extension String {
    func escapedForCsv() -> String {
        if self.contains(",") || self.contains("\"") || self.contains("\n") {
            let escaped = self.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return self
    }
}
