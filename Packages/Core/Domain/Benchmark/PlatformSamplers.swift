import Foundation

public protocol MemorySampler: Sendable {
    func usedMemoryBytes() -> Int64
}

public protocol DisplayTracker: Sendable {
    func reportInitialDisplay(slice: String)
    func reportFullDisplay(slice: String)
    func reportColdStart(elapsedMs: Double)
}

public protocol FrameMetricsSampler: Sendable {
    func start(slice: String)
    func stop()
}

public protocol CpuSampler: Sendable {
    func start(slice: String)
    func stop()
}

public struct NoopMemorySampler: MemorySampler {
    public init() {}
    public func usedMemoryBytes() -> Int64 { 0 }
}

public struct NoopDisplayTracker: DisplayTracker {
    public init() {}
    public func reportInitialDisplay(slice: String) {}
    public func reportFullDisplay(slice: String) {}
    public func reportColdStart(elapsedMs: Double) {}
}

public struct NoopFrameMetricsSampler: FrameMetricsSampler {
    public init() {}
    public func start(slice: String) {}
    public func stop() {}
}

public struct NoopCpuSampler: CpuSampler {
    public init() {}
    public func start(slice: String) {}
    public func stop() {}
}
