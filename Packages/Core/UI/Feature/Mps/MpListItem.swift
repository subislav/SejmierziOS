import SwiftUI
import Domain

struct MpListItem: View {
    let mp: Mp

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mp.firstLastName)
                .font(.title3)
                .fontWeight(.medium)

            if let club = mp.club {
                Text("Klub: \(club)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let district = mp.districtName {
                Text("Okręg: \(district)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !mp.active {
                Text("mp_inactive")
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
