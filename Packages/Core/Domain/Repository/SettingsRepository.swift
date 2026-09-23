import Foundation

public enum AppLanguage: String, Sendable, Equatable {
    case pl
    case en
}

public protocol SettingsRepository: Sendable {

    var dataSourceModeStream: AsyncStream<DataSourceMode> { get }
    var benchmarkConfigStream: AsyncStream<BenchmarkConfig> { get }
    var appLanguageStream: AsyncStream<AppLanguage> { get }


    func currentDataSourceMode() async -> DataSourceMode
    func currentBenchmarkConfig() async -> BenchmarkConfig
    func currentAppLanguage() async -> AppLanguage


    func setDataSourceMode(_ mode: DataSourceMode) async
    func setBenchmarkConfig(_ config: BenchmarkConfig) async
    func setAppLanguage(_ language: AppLanguage) async
}
