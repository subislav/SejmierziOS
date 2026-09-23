import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class VotingsViewModel {
    public private(set) var state: VotingsState = VotingsState()

    private let getVotingsUseCase: GetVotingsUseCase
    private let settings: SettingsRepository
    private var paginator: Paginator<Voting>!

    private let modeObserverTask = TaskCanceller()

    public init(getVotings: GetVotingsUseCase, settings: SettingsRepository) {
        self.getVotingsUseCase = getVotings
        self.settings = settings

        self.paginator = Paginator(pageSize: 50) { @Sendable [getVotings, settings] offset, limit in
            let currentMode = await settings.currentDataSourceMode()
            return await getVotings(term: Term.current, source: currentMode.toDataSource(), offset: offset, limit: limit)
        }

        self.modeObserverTask.task = Task { [weak self] in
            for await newMode in settings.dataSourceModeStream {
                self?.state.mode = newMode
                self?.send(.refresh)
            }
        }
    }

    public func send(_ intent: VotingsIntent) {
        switch intent {
        case .refresh:
            Task { await refresh() }
        case .loadMore:
            Task { await loadMore() }
        }
    }

    private func refresh() async {
        await paginator.reset()

        state.isLoading = true
        state.isRefreshing = !state.votings.isEmpty
        state.error = nil

        let result = await paginator.loadNext()

        switch result {
        case .success:
            state.votings = await paginator.loadedItems
            state.canLoadMore = await paginator.canLoadMore
            state.error = nil
        case .failure(let err):
            state.error = err
        }

        state.isLoading = false
        state.isRefreshing = false
    }

    private func loadMore() async {
        let canLoad = await paginator.canLoadMore
        guard !state.isLoadingMore && canLoad else { return }

        state.isLoadingMore = true
        let result = await paginator.loadNext()

        switch result {
        case .success:
            state.votings = await paginator.loadedItems
            state.canLoadMore = await paginator.canLoadMore
        case .failure(let err):
            state.error = err
        }

        state.isLoadingMore = false
    }
}
