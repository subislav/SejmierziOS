import Foundation

public enum DomainError: Error, Sendable, Equatable {
    case network(cause: String?)
    case http(code: Int, message: String?)
    case serialization(cause: String?)
    case notCached
    case empty
    case unknown(cause: String?)
}
