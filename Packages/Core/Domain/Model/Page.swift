import Foundation

public struct Page<T: Sendable>: Sendable, Equatable where T: Equatable {
    public let items: [T]
    public let offset: Int
    public let limit: Int

    public init(items: [T], offset: Int, limit: Int) {
        self.items = items
        self.offset = offset
        self.limit = limit
    }

    public var hasMore: Bool {
        return items.count >= limit
    }

    public var nextOffset: Int {
        return offset + items.count
    }
}
