import SwiftUI
import Domain

struct ClubListItem: View {
    let club: Club
    @Environment(\.appLanguage) private var language

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(club.name)
                .font(.title3)
                .fontWeight(.medium)

            Text(L10n.labeled(.membersCount, value: "\(club.membersCount)", language: language))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
