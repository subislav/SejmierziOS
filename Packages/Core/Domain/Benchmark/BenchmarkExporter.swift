import Foundation

public protocol BenchmarkExporter: Sendable {
    func export(fileName: String, content: String) async throws -> String
}
