import Foundation

public final class TaskCanceller: @unchecked Sendable {
    public var task: Task<Void, Never>?
    public init() {}
    deinit { task?.cancel() }
}
