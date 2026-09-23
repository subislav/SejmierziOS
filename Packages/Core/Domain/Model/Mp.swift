import Foundation

public struct Mp: Sendable, Equatable, Hashable, Identifiable {
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

    public init(id: Int, firstLastName: String, club: String?, active: Bool, districtName: String?, districtNum: Int?, voivodeship: String?, profession: String?, educationLevel: String?, email: String?, numberOfVotes: Int?, birthDate: String?, birthLocation: String?) {
        self.id = id
        self.firstLastName = firstLastName
        self.club = club
        self.active = active
        self.districtName = districtName
        self.districtNum = districtNum
        self.voivodeship = voivodeship
        self.profession = profession
        self.educationLevel = educationLevel
        self.email = email
        self.numberOfVotes = numberOfVotes
        self.birthDate = birthDate
        self.birthLocation = birthLocation
    }

    public func photoUrl(term: Term) -> String {
        return "https://api.sejm.gov.pl/sejm/term\(term.number)/MP/\(id)/photo"
    }
}
