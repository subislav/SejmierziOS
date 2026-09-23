import Foundation
import Observation
import Domain

public struct VotingDetailState: Sendable {
    public var detail: VotingDetail? = nil
    public var isLoading: Bool = true
    public var term: Term = .current
    public var error: DomainError? = nil
}

@Observable
@MainActor
public final class VotingDetailViewModel {
    public private(set) var state = VotingDetailState()

    private let sitting: Int
    private let votingNumber: Int
    private let getVotingDetailUseCase: GetVotingDetailUseCase
    private let settings: SettingsRepository

    public init(sitting: Int, votingNumber: Int, getVotingDetail: GetVotingDetailUseCase, settings: SettingsRepository) {
        self.sitting = sitting
        self.votingNumber = votingNumber
        self.getVotingDetailUseCase = getVotingDetail
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
        let result = await getVotingDetailUseCase(term: state.term, sitting: sitting, votingNumber: votingNumber, source: mode.toDataSource())

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
