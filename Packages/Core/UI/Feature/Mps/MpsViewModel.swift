import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class MpsViewModel {
    public private(set) var state: MpsState = MpsState()

    private let getMpsUseCase: GetMpsUseCase
    private let settings: SettingsRepository
    private var paginator: Paginator<Mp>!

    private let modeObserverTask = TaskCanceller()

    public init(getMps: GetMpsUseCase, settings: SettingsRepository) {
        self.getMpsUseCase = getMps
        self.settings = settings

        self.paginator = Paginator(pageSize: 50) { @Sendable [getMps, settings] offset, limit in
            let currentMode = await settings.currentDataSourceMode()
            return await getMps(term: Term.current, source: currentMode.toDataSource(), offset: offset, limit: limit)
        }

        self.modeObserverTask.task = Task { [weak self] in
            for await newMode in settings.dataSourceModeStream {
                self?.state.mode = newMode
                self?.send(.refresh)
            }
        }
    }

    public func send(_ intent: MpsIntent) {
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
        state.isRefreshing = !state.mps.isEmpty
        state.error = nil

        let result = await paginator.loadNext()

        switch result {
        case .success:
            state.mps = await paginator.loadedItems
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
            state.mps = await paginator.loadedItems
            state.canLoadMore = await paginator.canLoadMore
        case .failure(let err):
            state.error = err
        }

        state.isLoadingMore = false
    }
}
