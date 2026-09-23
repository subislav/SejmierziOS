import SwiftUI
import Domain

struct VotingListItem: View {
    let voting: Voting
    @Environment(\.appLanguage) private var language

    private var displayTitle: String {
        if let topic = voting.topic, !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return topic
        }
        if let title = voting.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        return L10n.votingTitle(sitting: voting.sitting, votingNumber: voting.votingNumber, language: language)
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


            Text(L10n.voteLine(yes: voting.yes, no: voting.no, abstain: voting.abstain, language: language))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
