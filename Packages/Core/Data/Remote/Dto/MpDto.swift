import Foundation

public struct MpDto: Decodable, Sendable {
    public let id: Int
    public let firstLastName: String?
    public let firstName: String?
    public let lastName: String?
    public let club: String?
    public let active: Bool?
    public let districtName: String?
    public let districtNum: Int?
    public let voivodeship: String?
    public let profession: String?
    public let educationLevel: String?
    public let email: String?
    public let numberOfVotes: Int?
    public let birthDate: String?
    public let birthLocation: String?
}
