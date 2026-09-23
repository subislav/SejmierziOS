import Foundation

public struct ClubDto: Decodable, Sendable {
    public let id: String
    public let name: String
    public let membersCount: Int
    public let email: String?
    public let phone: String?
    public let fax: String?
    public let members: [ClubMemberDto]?
}

public struct ClubMemberDto: Decodable, Sendable {
    public let id: Int
    public let firstName: String?
    public let lastName: String?
    public let function: String?
}
