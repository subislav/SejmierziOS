import Foundation
import Domain

public extension DomainError {
    var localizedMessage: String {
        switch self {
        case .network:
            return NSLocalizedString("error_network", comment: "")
        case .http(let code, _):
            return String(format: NSLocalizedString("Błąd serwera (%d).", comment: ""), code)
        case .serialization:
            return NSLocalizedString("error_serialization", comment: "")
        case .notCached:
            return NSLocalizedString("error_not_cached", comment: "")
        case .empty:
            return NSLocalizedString("error_empty", comment: "")
        case .unknown:
            return NSLocalizedString("error_unknown", comment: "")
        }
    }
}
