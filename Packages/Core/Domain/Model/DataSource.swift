import Foundation

public enum DataSource: String, Sendable, Equatable {
    case network
    case local
}

public enum DataSourceMode: String, Sendable, Equatable {
    case online
    case offline

    public func toDataSource() -> DataSource {
        switch self {
        case .online:
            return .network
        case .offline:
            return .local
        }
    }
}
