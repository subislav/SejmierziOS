import Foundation

public final class AsyncStreamBroadcast<Element: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Element
    private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]

    public init(initial: Element) {
        self.value = initial
    }

    public var current: Element {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    public func subscribe() -> AsyncStream<Element> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let id = UUID()
            lock.lock()
            continuations[id] = continuation
            let current = value
            lock.unlock()

            continuation.yield(current)
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                self.continuations.removeValue(forKey: id)
                self.lock.unlock()
            }
        }
    }

    public func yield(_ newValue: Element) {
        lock.lock()
        value = newValue
        let subscribers = Array(continuations.values)
        lock.unlock()
        for continuation in subscribers {
            continuation.yield(newValue)
        }
    }
}
