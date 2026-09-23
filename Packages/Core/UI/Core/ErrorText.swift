import Foundation
import Domain

public extension DomainError {
    func localizedMessage(language: AppLanguage) -> String {
        switch self {
        case .network:
            return L10n.string(.errorNetwork, language: language)
        case .http(let code, _):
            return L10n.httpError(code: code, language: language)
        case .serialization:
            return L10n.string(.errorSerialization, language: language)
        case .notCached:
            return L10n.string(.errorNotCached, language: language)
        case .empty:
            return L10n.string(.errorEmpty, language: language)
        case .unknown:
            return L10n.string(.errorUnknown, language: language)
        }
    }
}
