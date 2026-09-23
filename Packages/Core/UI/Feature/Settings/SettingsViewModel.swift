import Foundation
import Observation
import Domain

public struct SettingsState: Equatable, Sendable {
    public var mode: DataSourceMode = .online
    public var language: AppLanguage = .pl

    public init(mode: DataSourceMode = .online, language: AppLanguage = .pl) {
        self.mode = mode
        self.language = language
    }
}

public enum SettingsIntent: Sendable {
    case toggleMode(DataSourceMode)
    case changeLanguage(AppLanguage)
}

@Observable
@MainActor
public final class SettingsViewModel {
    public private(set) var state = SettingsState()

    private let settings: SettingsRepository
    private var modeTask: Task<Void, Never>?
    private var languageTask: Task<Void, Never>?

    public init(settings: SettingsRepository) {
        self.settings = settings

        modeTask = Task { [weak self] in
            for await mode in settings.dataSourceModeStream {
                self?.state.mode = mode
            }
        }
        languageTask = Task { [weak self] in
            for await language in settings.appLanguageStream {
                self?.state.language = language
            }
        }

        Task { [weak self] in
            guard let self else { return }
            self.state.mode = await settings.currentDataSourceMode()
            self.state.language = await settings.currentAppLanguage()
        }
    }

    public func send(_ intent: SettingsIntent) {
        switch intent {
        case .toggleMode(let mode):
            Task { await settings.setDataSourceMode(mode) }
        case .changeLanguage(let language):
            Task { await settings.setAppLanguage(language) }
        }
    }

    deinit {
        modeTask?.cancel()
        languageTask?.cancel()
    }
}
