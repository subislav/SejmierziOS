import Foundation

public protocol RunContextProvider: Sendable {
    func globalTags() -> [String: String]
}

public struct EmptyRunContextProvider: RunContextProvider {
    public init() {}
    public func globalTags() -> [String: String] { return [:] }
}
