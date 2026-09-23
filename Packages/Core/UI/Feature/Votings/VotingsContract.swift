import Foundation
import Domain

public struct VotingsState: Sendable {
    public var votings: [Voting] = []
    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var isRefreshing: Bool = false
    public var canLoadMore: Bool = true
    public var mode: DataSourceMode = .online
    public var term: Term = .current
    public var error: DomainError? = nil
}

public enum VotingsIntent {
    case refresh
    case loadMore
}
