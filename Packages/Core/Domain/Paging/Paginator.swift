import Foundation

public actor Paginator<T: Sendable & Equatable> {
    public enum LoadOutcome: Sendable {
        case loaded(newItems: [T])
        case skippedAlreadyLoading
        case skippedEndReached
    }

    private let pageSize: Int
    private let fetch: @Sendable (Int, Int) async -> DomainResult<Page<T>>

    private var items: [T] = []
    private var nextOffset: Int = 0
    private var endReached: Bool = false
    private var loading: Bool = false
    private var generation: Int = 0

    public var loadedItems: [T] { items }
    public var canLoadMore: Bool { !endReached && !loading }
    public var isLoading: Bool { loading }

    public init(
        pageSize: Int = 50,
        fetch: @escaping @Sendable (Int, Int) async -> DomainResult<Page<T>>
    ) {
        self.pageSize = pageSize
        self.fetch = fetch
    }

    public func reset() {
        items.removeAll()
        nextOffset = 0
        endReached = false
        loading = false
        generation &+= 1
    }

    public func loadNext() async -> DomainResult<LoadOutcome> {
        if loading {
            return .success(.skippedAlreadyLoading)
        }
        if endReached {
            return .success(.skippedEndReached)
        }

        let startGeneration = generation
        let offset = nextOffset
        loading = true
        defer { loading = false }

        let result = await fetch(offset, pageSize)

        guard startGeneration == generation else {
            return .success(.loaded(newItems: []))
        }

        switch result {
        case .success(let page):
            items.append(contentsOf: page.items)
            nextOffset = page.nextOffset
            endReached = !page.hasMore
            return .success(.loaded(newItems: page.items))

        case .failure(let error):
            return .failure(error)
        }
    }
}
