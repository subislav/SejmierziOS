import SwiftUI
import Domain

public struct ClubDetailScreen: View {
    @State var viewModel: ClubDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext

    public init(viewModel: ClubDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle("club_detail_title")
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "Club detail", contentLoaded: viewModel.state.detail != nil)
            .scrollJankTracking(slice: "Club detail")
    }

    @ViewBuilder
    private var stateDrivenContent: some View {
        if viewModel.state.isLoading {
            LoadingView()
        } else if let error = viewModel.state.error {
            MessageView(message: error.localizedMessage) {
                let _ = viewModel.retry()
            }
        } else if let detail = viewModel.state.detail {
            clubFieldsList(for: detail)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func clubFieldsList(for detail: ClubDetail) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detail.club.name).font(.headline)
                    Text("Kod: \(detail.club.id)").font(.subheadline).foregroundStyle(.secondary)
                    Text("Liczba członków: \(detail.club.membersCount)")
                    if let email = detail.club.email { Text("E-mail: \(email)") }
                    if let phone = detail.club.phone { Text("Telefon: \(phone)") }
                    if let fax = detail.club.fax { Text("Faks: \(fax)") }
                }
                .padding(.vertical, 8)
            }

            if detail.members.isEmpty {
                Section {
                    Text("club_no_members")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Section(header: Text("Członkowie").font(.title3.bold())) {
                    ForEach(detail.members) { member in
                        VStack(alignment: .leading) {
                            Text(member.fullName).font(.body)
                            if let function = member.function, !function.isEmpty {
                                Text(function).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
