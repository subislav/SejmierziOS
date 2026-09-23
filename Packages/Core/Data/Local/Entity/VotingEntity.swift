import Foundation
import GRDB
import Domain

public struct VotingEntity: Codable, FetchableRecord, PersistableRecord, Sendable {
    public let term: Int
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

    public init(term: Int, voting: Voting) {
        self.term = term
        self.sitting = voting.sitting
        self.votingNumber = voting.votingNumber
        self.sittingDay = voting.sittingDay
        self.date = voting.date
        self.title = voting.title
        self.topic = voting.topic
        self.description = voting.description
        self.kind = voting.kind
        self.majorityType = voting.majorityType
        self.yes = voting.yes
        self.no = voting.no
        self.abstain = voting.abstain
        self.notParticipating = voting.notParticipating
        self.totalVoted = voting.totalVoted
    }
}
