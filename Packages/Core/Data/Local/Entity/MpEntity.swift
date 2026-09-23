import Foundation
import GRDB
import Domain

public struct MpEntity: Codable, FetchableRecord, PersistableRecord, Sendable {
    public let term: Int
    public let id: Int
    public let firstLastName: String
    public let club: String?
    public let active: Bool
    public let districtName: String?
    public let districtNum: Int?
    public let voivodeship: String?
    public let profession: String?
    public let educationLevel: String?
    public let email: String?
    public let numberOfVotes: Int?
    public let birthDate: String?
    public let birthLocation: String?

    public init(term: Int, mp: Mp) {
        self.term = term
        self.id = mp.id
        self.firstLastName = mp.firstLastName
        self.club = mp.club
        self.active = mp.active
        self.districtName = mp.districtName
        self.districtNum = mp.districtNum
        self.voivodeship = mp.voivodeship
        self.profession = mp.profession
        self.educationLevel = mp.educationLevel
        self.email = mp.email
        self.numberOfVotes = mp.numberOfVotes
        self.birthDate = mp.birthDate
        self.birthLocation = mp.birthLocation
    }
}
