import Foundation
import Domain

public actor SejmApi: Sendable {
    private let interceptor: NetworkBenchmarkInterceptor
    private let baseURL = "https://api.sejm.gov.pl/sejm/term"

    public init(interceptor: NetworkBenchmarkInterceptor) {
        self.interceptor = interceptor
    }

    public func getMps(term: Int, offset: Int, limit: Int) async throws -> [MpDto] {
        let url = URL(string: "\(baseURL)\(term)/MP?offset=\(offset)&limit=\(limit)")!
        return try await interceptor.fetchAndDecode(url: url, endpointLabel: "/MP")
    }

    public func getMp(term: Int, id: Int) async throws -> MpDto {
        let url = URL(string: "\(baseURL)\(term)/MP/\(id)")!
        return try await interceptor.fetchAndDecode(url: url, endpointLabel: "/MP/{id}")
    }

    public func getClubs(term: Int) async throws -> [ClubDto] {
        let url = URL(string: "\(baseURL)\(term)/clubs")!
        return try await interceptor.fetchAndDecode(url: url, endpointLabel: "/clubs")
    }

    public func getClub(term: Int, id: String) async throws -> ClubDto {
        let url = URL(string: "\(baseURL)\(term)/clubs/\(id)")!
        return try await interceptor.fetchAndDecode(url: url, endpointLabel: "/clubs/{id}")
    }

    public func searchVotings(term: Int, offset: Int, limit: Int, dateFrom: String? = nil, dateTo: String? = nil, title: String? = nil) async throws -> [VotingDto] {
        var components = URLComponents(string: "\(baseURL)\(term)/votings/search")!
        var queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let dateFrom { queryItems.append(URLQueryItem(name: "dateFrom", value: dateFrom)) }
        if let dateTo { queryItems.append(URLQueryItem(name: "dateTo", value: dateTo)) }
        if let title { queryItems.append(URLQueryItem(name: "title", value: title)) }
        components.queryItems = queryItems

        return try await interceptor.fetchAndDecode(url: components.url!, endpointLabel: "/votings/search")
    }

    public func getVoting(term: Int, sitting: Int, votingNumber: Int) async throws -> VotingDto {
        let url = URL(string: "\(baseURL)\(term)/votings/\(sitting)/\(votingNumber)")!
        return try await interceptor.fetchAndDecode(url: url, endpointLabel: "/votings/{sitting}/{num}")
    }
}
