import Foundation

public struct BenchmarkContext: Sendable {
    public let benchmark: Benchmark
    public let memory: MemorySampler
    public let frames: FrameMetricsSampler
    public let display: DisplayTracker
    public let cpu: CpuSampler

    public init(
        benchmark: Benchmark,
        memory: MemorySampler,
        frames: FrameMetricsSampler,
        display: DisplayTracker,
        cpu: CpuSampler
    ) {
        self.benchmark = benchmark
        self.memory = memory
        self.frames = frames
        self.display = display
        self.cpu = cpu
    }

    public func measuredWithMemory<T>(
        category: MetricCategory,
        name: String,
        tags: [String: String] = [:],
        block: () async throws -> T
    ) async throws -> T {
        let slice = tags[MetricTag.slice] ?? name
        cpu.start(slice: slice)
        let before = memory.usedMemoryBytes()
        do {
            let result = try await benchmark.measured(category: category, name: name, tags: tags, block: block)
            let after = memory.usedMemoryBytes()
            benchmark.record(
                name: "\(name).memoryDelta",
                category: .memory,
                value: Double(after - before),
                unit: Metric.unitBytes,
                tags: tags
            )
            benchmark.record(
                name: "\(name).memoryUsed",
                category: .memory,
                value: Double(after),
                unit: Metric.unitBytes,
                tags: tags
            )
            cpu.stop()
            return result
        } catch {
            cpu.stop()
            throw error
        }
    }
}
