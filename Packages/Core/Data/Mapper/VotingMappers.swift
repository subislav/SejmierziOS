import Foundation
import Domain

extension VotingDto {
    func toDomain() -> Voting {
        return Voting(
            sitting: sitting,
            votingNumber: votingNumber,
            sittingDay: sittingDay,
            date: date,
            title: title,
            topic: topic,
            description: description,
            kind: kind,
            majorityType: majorityType,
            yes: yes,
            no: no,
            abstain: abstain,
            notParticipating: notParticipating,
            totalVoted: totalVoted
        )
    }

    func toDetailDomain() -> VotingDetail {
        return VotingDetail(
            voting: toDomain(),
            clubVotes: aggregateClubVotes()
        )
    }

    private func aggregateClubVotes() -> [ClubVoteSummary] {
        guard let votes = votes else { return [] }

        let grouped = Dictionary(grouping: votes, by: { $0.club ?? "—" })

        return grouped.map { (clubName, clubVotes) in
            ClubVoteSummary(
                club: clubName,
                yes: clubVotes.filter { $0.vote == "YES" }.count,
                no: clubVotes.filter { $0.vote == "NO" }.count,
                abstain: clubVotes.filter { $0.vote == "ABSTAIN" }.count,
                absent: clubVotes.filter { !["YES", "NO", "ABSTAIN"].contains($0.vote) }.count
            )
        }.sorted { $0.total > $1.total }
    }
}

extension VotingEntity {
    func toDomain() -> Voting {
        return Voting(
            sitting: sitting,
            votingNumber: votingNumber,
            sittingDay: sittingDay,
            date: date,
            title: title,
            topic: topic,
            description: description,
            kind: kind,
            majorityType: majorityType,
            yes: yes,
            no: no,
            abstain: abstain,
            notParticipating: notParticipating,
            totalVoted: totalVoted
        )
    }
}
