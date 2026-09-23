import Foundation
import Observation
import Domain

public struct MpDetailState: Sendable {
    public var mp: Mp? = nil
    public var isLoading: Bool = true
    public var term: Term = .current
    public var error: DomainError? = nil
}

@Observable
@MainActor
public final class MpDetailViewModel {
    public private(set) var state = MpDetailState()

    private let mpId: Int
    private let getMpDetailUseCase: GetMpDetailUseCase
    private let settings: SettingsRepository

    public init(mpId: Int, getMpDetail: GetMpDetailUseCase, settings: SettingsRepository) {
        self.mpId = mpId
        self.getMpDetailUseCase = getMpDetail
        self.settings = settings

        Task { await load() }
    }

    public func retry() {
        Task { await load() }
    }

    private func load() async {
        state.isLoading = true
        state.error = nil

        let mode = await settings.currentDataSourceMode()
        let result = await getMpDetailUseCase(term: state.term, id: mpId, source: mode.toDataSource())

        switch result {
        case .success(let mp):
            state.mp = mp
            state.isLoading = false
        case .failure(let err):
            state.error = err
            state.isLoading = false
        }
    }
}
