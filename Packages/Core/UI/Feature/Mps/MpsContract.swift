import Foundation
import Domain

public struct MpsState: Sendable {
    public var mps: [Mp] = []
    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var isRefreshing: Bool = false
    public var canLoadMore: Bool = true
    public var mode: DataSourceMode = .online
    public var term: Term = .current
    public var error: DomainError? = nil
}

public enum MpsIntent {
    case refresh
    case loadMore
}
