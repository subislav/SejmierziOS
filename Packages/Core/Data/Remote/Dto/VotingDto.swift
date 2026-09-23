import Foundation

public struct VotingDto: Decodable, Sendable {
    public let sitting: Int
    public let votingNumber: Int
    public let sittingDay: Int?
    public let date: String?
    public let title: String?
    public let topic: String?
    public let description: String?
    public let kind: String?
    public let majorityType: String?
    public let yes: Int
    public let no: Int
    public let abstain: Int
    public let notParticipating: Int
    public let totalVoted: Int
    public let votes: [VotingVoteDto]?
}

public struct VotingVoteDto: Decodable, Sendable {
    public let mp: Int
    public let club: String?
    public let firstName: String?
    public let lastName: String?
    public let secondName: String?
    public let vote: String?

    enum CodingKeys: String, CodingKey {
        case mp = "MP"
        case club, firstName, lastName, secondName, vote
    }
}
