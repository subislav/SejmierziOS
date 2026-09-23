import Foundation
import Domain

public struct ClubsState: Sendable {
    public var clubs: [Club] = []
    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var isRefreshing: Bool = false
    public var canLoadMore: Bool = true
    public var mode: DataSourceMode = .online
    public var term: Term = .current
    public var error: DomainError? = nil
}

public enum ClubsIntent {
    case refresh
    case loadMore
}
