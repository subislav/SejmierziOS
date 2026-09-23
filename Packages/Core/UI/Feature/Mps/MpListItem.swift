import SwiftUI
import Domain

struct MpListItem: View {
    let mp: Mp
    @Environment(\.appLanguage) private var language

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mp.firstLastName)
                .font(.title3)
                .fontWeight(.medium)

            if let club = mp.club {
                Text(L10n.labeled(.club, value: club, language: language))
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let district = mp.districtName {
                Text(L10n.labeled(.district, value: district, language: language))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !mp.active {
                Text(L10n.string(.mpInactive, language: language))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
