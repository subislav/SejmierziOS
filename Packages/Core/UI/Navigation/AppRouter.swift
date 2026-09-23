import SwiftUI

public enum AppRoute: Hashable {
    case mpDetail(id: Int)
    case votingDetail(sitting: Int, votingNumber: Int)
    case clubDetail(id: String)
    case benchmark
}

@Observable
public final class RootRouter {
    public var path: [AppRoute] = []
    public init() {}
    public func navigate(to route: AppRoute) { path.append(route) }
    public func pop() { if !path.isEmpty { path.removeLast() } }
}
