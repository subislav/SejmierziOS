import Foundation

public struct ClubDetail: Sendable, Equatable {
    public let club: Club
    public let members: [ClubMember]

    public init(club: Club, members: [ClubMember]) {
        self.club = club
        self.members = members
    }
}

public struct ClubMember: Sendable, Equatable, Hashable, Identifiable {
    public let id: Int
    public let firstName: String?
    public let lastName: String?
    public let function: String?

    public init(id: Int, firstName: String?, lastName: String?, function: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.function = function
    }

    public var fullName: String {
        return [firstName, lastName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
