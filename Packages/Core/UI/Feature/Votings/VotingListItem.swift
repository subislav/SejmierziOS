import SwiftUI
import Domain

struct VotingListItem: View {
    let voting: Voting

    private var displayTitle: String {
        if let topic = voting.topic, !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return topic
        }
        if let title = voting.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        return String(localized: "Posiedzenie \(voting.sitting), Głosowanie \(voting.votingNumber)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayTitle)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(3)

            if let date = voting.date {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }


                Text("ZA: \(voting.yes) • PRZECIW: \(voting.no) • WSTRZ.: \(voting.abstain)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
