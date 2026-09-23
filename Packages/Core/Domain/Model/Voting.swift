import Foundation

public struct Voting: Sendable, Equatable, Hashable {
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

    public init(sitting: Int, votingNumber: Int, sittingDay: Int?, date: String?, title: String?, topic: String?, description: String?, kind: String?, majorityType: String?, yes: Int, no: Int, abstain: Int, notParticipating: Int, totalVoted: Int) {
        self.sitting = sitting
        self.votingNumber = votingNumber
        self.sittingDay = sittingDay
        self.date = date
        self.title = title
        self.topic = topic
        self.description = description
        self.kind = kind
        self.majorityType = majorityType
        self.yes = yes
        self.no = no
        self.abstain = abstain
        self.notParticipating = notParticipating
        self.totalVoted = totalVoted
    }
}
