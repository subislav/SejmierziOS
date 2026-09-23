import Foundation
import Domain

public struct NetworkBenchmarkInterceptor: Sendable {
    private let session: URLSession
    private let benchmarkContext: BenchmarkContext
    private let jsonDecoder: JSONDecoder

    public init(session: URLSession, benchmarkContext: BenchmarkContext) {
        self.session = session
        self.benchmarkContext = benchmarkContext
        self.jsonDecoder = JSONDecoder()
    }

    public func fetchAndDecode<T: Decodable>(url: URL, endpointLabel: String) async throws -> T {
        let rawData = try await fetchRawData(from: url, endpointLabel: endpointLabel)

        return try await decode(endpoint: endpointLabel, data: rawData)
    }



    private func fetchRawData(from url: URL, endpointLabel: String) async throws -> Data {
        try await benchmarkContext.benchmark.measured(
            category: .network,
            name: "network.transport",
            tags: [MetricTag.endpoint: endpointLabel]
        ) {
            let (data, response) = try await session.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw ApiHttpError(
                    code: httpResponse.statusCode,
                    message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                )
            }
            return data
        }
    }

    private func decode<T: Decodable>(endpoint: String, data: Data) async throws -> T {
        try await benchmarkContext.measuredWithMemory(
            category: .parsing,
            name: "parsing.decode",
            tags: [
                MetricTag.endpoint: endpoint,
                "bytes": "\(data.count)"
            ]
        ) {
            try jsonDecoder.decode(T.self, from: data)
        }
    }
}
