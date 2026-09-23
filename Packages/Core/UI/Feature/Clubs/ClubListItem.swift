import SwiftUI
import Domain

struct ClubListItem: View {
    let club: Club

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(club.name)
                .font(.title3)
                .fontWeight(.medium)


            Text("Liczba członków: \(club.membersCount)")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
