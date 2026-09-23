import Foundation

public struct VotingDetail: Sendable, Equatable {
    public let voting: Voting
    public let clubVotes: [ClubVoteSummary]

    public init(voting: Voting, clubVotes: [ClubVoteSummary]) {
        self.voting = voting
        self.clubVotes = clubVotes
    }
}

public struct ClubVoteSummary: Sendable, Equatable, Hashable {
    public let club: String
    public let yes: Int
    public let no: Int
    public let abstain: Int
    public let absent: Int

    public init(club: String, yes: Int, no: Int, abstain: Int, absent: Int) {
        self.club = club
        self.yes = yes
        self.no = no
        self.abstain = abstain
        self.absent = absent
    }

    public var total: Int {
        return yes + no + abstain + absent
    }
}
