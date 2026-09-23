import Foundation
import GRDB
import Domain

public struct ClubEntity: Codable, FetchableRecord, PersistableRecord, Sendable {
    public let term: Int
    public let id: String
    public let name: String
    public let membersCount: Int
    public let email: String?
    public let phone: String?
    public let fax: String?

    public init(term: Int, club: Club) {
        self.term = term
        self.id = club.id
        self.name = club.name
        self.membersCount = club.membersCount
        self.email = club.email
        self.phone = club.phone
        self.fax = club.fax
    }
}
