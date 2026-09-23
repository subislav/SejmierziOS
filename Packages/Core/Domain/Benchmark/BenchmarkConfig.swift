import Foundation

public struct BenchmarkConfig: Equatable, Sendable {
    public let totalIterations: Int
    public let warmupIterations: Int

    public static let defaultTotalIterations = 35
    public static let defaultWarmupIterations = 5

    public init(totalIterations: Int = defaultTotalIterations, warmupIterations: Int = defaultWarmupIterations) {
        precondition(totalIterations > 0, "totalIterations must be > 0")
        precondition(warmupIterations >= 0 && warmupIterations < totalIterations, "warmupIterations must be in 0 until totalIterations")

        self.totalIterations = totalIterations
        self.warmupIterations = warmupIterations
    }

    public var cleanSamples: Int {
        totalIterations - warmupIterations
    }
}
