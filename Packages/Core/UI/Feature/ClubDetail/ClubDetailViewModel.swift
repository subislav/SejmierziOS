import Foundation
import Observation
import Domain

public struct ClubDetailState: Sendable {
    public var detail: ClubDetail? = nil
    public var isLoading: Bool = true
    public var term: Term = .current
    public var error: DomainError? = nil
}

@Observable
@MainActor
public final class ClubDetailViewModel {
    public private(set) var state = ClubDetailState()

    private let clubId: String
    private let getClubDetailUseCase: GetClubDetailUseCase
    private let settings: SettingsRepository

    public init(clubId: String, getClubDetail: GetClubDetailUseCase, settings: SettingsRepository) {
        self.clubId = clubId
        self.getClubDetailUseCase = getClubDetail
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
        let result = await getClubDetailUseCase(term: state.term, id: clubId, source: mode.toDataSource())

        switch result {
        case .success(let detail):
            state.detail = detail
            state.isLoading = false
        case .failure(let err):
            state.error = err
            state.isLoading = false
        }
    }
}
