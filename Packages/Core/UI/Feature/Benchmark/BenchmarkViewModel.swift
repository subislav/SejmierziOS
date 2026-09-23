import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class BenchmarkViewModel {
    public var config: BenchmarkConfig = BenchmarkConfig()
    public var stats: [BenchmarkStatistics] = []
    public var sampleCount: Int = 0
    public var lastExportPath: String? = nil

    public var iterationsInput: String = ""
    public var warmupInput: String = ""

    private let metrics: MetricRepository
    private let settings: SettingsRepository
    private let exporter: BenchmarkExporter

    private let streamTask = TaskCanceller()

    public init(metrics: MetricRepository, settings: SettingsRepository, exporter: BenchmarkExporter) {
        self.metrics = metrics
        self.settings = settings
        self.exporter = exporter

        Task {
            let initialConfig = await settings.currentBenchmarkConfig()
            self.config = initialConfig
            self.iterationsInput = "\(initialConfig.totalIterations)"
            self.warmupInput = "\(initialConfig.warmupIterations)"
        }

        self.streamTask.task = Task { [weak self] in
            for await newMetrics in metrics.metricsStream {
                guard let self = self else { return }
                self.sampleCount = newMetrics.count
                self.stats = newMetrics.summarize(warmup: self.config.warmupIterations)
            }
        }
    }

    public func applyConfig() {
        if let total = Int(iterationsInput), let warm = Int(warmupInput), total > 0, warm >= 0, warm < total {
            let newConfig = BenchmarkConfig(totalIterations: total, warmupIterations: warm)
            self.config = newConfig

            Task { await settings.setBenchmarkConfig(newConfig) }

            let currentMetrics = metrics.snapshot()
            self.stats = currentMetrics.summarize(warmup: newConfig.warmupIterations)
        }
    }

    public func clear() {
        metrics.clear()
        self.lastExportPath = nil
    }

    public func exportCsv() {
        Task {
            let currentMetrics = metrics.snapshot()
            let csv = MetricCsvExporter.toCsv(metrics: currentMetrics)
            let fileName = "sejmierz-benchmarks-\(Int(Date().timeIntervalSince1970 * 1000)).csv"

            do {
                let path = try await exporter.export(fileName: fileName, content: csv)
                self.lastExportPath = path
            } catch {
                print("Eksport zawiódł: \(error)")
            }
        }
    }
}
