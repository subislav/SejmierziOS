import Foundation
import Domain

public final class InMemorySettingsRepository: SettingsRepository, @unchecked Sendable {
    private let modeBroadcast = AsyncStreamBroadcast<DataSourceMode>(initial: .online)
    private let configBroadcast = AsyncStreamBroadcast<BenchmarkConfig>(initial: BenchmarkConfig())
    private let languageBroadcast = AsyncStreamBroadcast<AppLanguage>(initial: .pl)

    public init() {}

    public var dataSourceModeStream: AsyncStream<DataSourceMode> {
        modeBroadcast.subscribe()
    }

    public var benchmarkConfigStream: AsyncStream<BenchmarkConfig> {
        configBroadcast.subscribe()
    }

    public var appLanguageStream: AsyncStream<AppLanguage> {
        languageBroadcast.subscribe()
    }

    public func currentDataSourceMode() -> DataSourceMode {
        modeBroadcast.current
    }

    public func currentBenchmarkConfig() -> BenchmarkConfig {
        configBroadcast.current
    }

    public func currentAppLanguage() -> AppLanguage {
        languageBroadcast.current
    }

    public func setDataSourceMode(_ newMode: DataSourceMode) {
        modeBroadcast.yield(newMode)
    }

    public func setBenchmarkConfig(_ newConfig: BenchmarkConfig) {
        configBroadcast.yield(newConfig)
    }

    public func setAppLanguage(_ newLanguage: AppLanguage) {
        languageBroadcast.yield(newLanguage)
    }
}
