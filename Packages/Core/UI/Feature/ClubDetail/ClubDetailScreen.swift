import SwiftUI
import Domain

public struct ClubDetailScreen: View {
    @State var viewModel: ClubDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.appLanguage) private var language

    public init(viewModel: ClubDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle(L10n.string(.clubDetailTitle, language: language))
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "Club detail", contentLoaded: viewModel.state.detail != nil)
            .scrollJankTracking(slice: "Club detail")
    }

    @ViewBuilder
    private var stateDrivenContent: some View {
        if viewModel.state.isLoading {
            LoadingView()
        } else if let error = viewModel.state.error {
            MessageView(message: error.localizedMessage(language: language)) {
                viewModel.retry()
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
                    Text(L10n.labeled(.code, value: detail.club.id, language: language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(L10n.labeled(.membersCount, value: "\(detail.club.membersCount)", language: language))
                    if let email = detail.club.email {
                        Text(L10n.labeled(.email, value: email, language: language))
                    }
                    if let phone = detail.club.phone {
                        Text(L10n.labeled(.phone, value: phone, language: language))
                    }
                    if let fax = detail.club.fax {
                        Text(L10n.labeled(.fax, value: fax, language: language))
                    }
                }
                .padding(.vertical, 8)
            }

            if detail.members.isEmpty {
                Section {
                    Text(L10n.string(.clubNoMembers, language: language))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Section(header: Text(L10n.string(.members, language: language)).font(.title3.bold())) {
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
