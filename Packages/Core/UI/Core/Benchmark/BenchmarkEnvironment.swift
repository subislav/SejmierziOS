import SwiftUI
import Domain

private struct BenchmarkContextKey: EnvironmentKey {
    static let defaultValue: BenchmarkContext? = nil
}

public extension EnvironmentValues {
    var benchmarkContext: BenchmarkContext? {
        get { self[BenchmarkContextKey.self] }
        set { self[BenchmarkContextKey.self] = newValue }
    }
}
