import Foundation
import Domain

public actor InMemorySettingsRepository: SettingsRepository {

    private var mode: DataSourceMode = .online
    private var config: BenchmarkConfig = BenchmarkConfig()
    private var language: AppLanguage = .pl

    private let modeContinuation: AsyncStream<DataSourceMode>.Continuation
    public let dataSourceModeStream: AsyncStream<DataSourceMode>

    private let configContinuation: AsyncStream<BenchmarkConfig>.Continuation
    public let benchmarkConfigStream: AsyncStream<BenchmarkConfig>

    private let langContinuation: AsyncStream<AppLanguage>.Continuation
    public let appLanguageStream: AsyncStream<AppLanguage>

    public init() {
        let (modeS, modeC) = AsyncStream<DataSourceMode>.makeStream()
        self.dataSourceModeStream = modeS
        self.modeContinuation = modeC
        modeC.yield(.online)

        let (configS, configC) = AsyncStream<BenchmarkConfig>.makeStream()
        self.benchmarkConfigStream = configS
        self.configContinuation = configC
        configC.yield(BenchmarkConfig())

        let (langS, langC) = AsyncStream<AppLanguage>.makeStream()
        self.appLanguageStream = langS
        self.langContinuation = langC
        langC.yield(.pl)
    }



    public func currentDataSourceMode() -> DataSourceMode {
        return mode
    }

    public func currentBenchmarkConfig() -> BenchmarkConfig {
        return config
    }

    public func currentAppLanguage() -> AppLanguage {
        return language
    }



    public func setDataSourceMode(_ newMode: DataSourceMode) {
        mode = newMode
        modeContinuation.yield(newMode)
    }

    public func setBenchmarkConfig(_ newConfig: BenchmarkConfig) {
        config = newConfig
        configContinuation.yield(newConfig)
    }

    public func setAppLanguage(_ newLanguage: AppLanguage) {
        language = newLanguage
        langContinuation.yield(newLanguage)
    }
}
