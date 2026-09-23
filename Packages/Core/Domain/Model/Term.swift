import Foundation

public struct Term: Sendable, Equatable, Hashable {
    public let number: Int

    public init(number: Int) {
        precondition(number > 0, "Term number must be positive, was \(number)")
        self.number = number
    }

    public static let current = Term(number: 10)
}
