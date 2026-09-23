import SwiftUI
import Domain

public struct VotingDetailScreen: View {
    @State var viewModel: VotingDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext

    public init(viewModel: VotingDetailViewModel) {
        self.viewModel = viewModel
    }

    private func getDisplayTitle(for voting: Voting) -> String {
        if let topic = voting.topic, !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return topic }
        if let title = voting.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return title }
        return String(localized: "Posiedzenie \(voting.sitting), Głosowanie \(voting.votingNumber)")
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle("voting_detail_title")
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "Voting detail", contentLoaded: viewModel.state.detail != nil)
            .scrollJankTracking(slice: "Voting detail")
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
            votingFieldsList(for: detail)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func votingFieldsList(for detail: VotingDetail) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(getDisplayTitle(for: detail.voting))
                        .font(.title3)
                        .fontWeight(.bold)

                    if let title = detail.voting.title, title != getDisplayTitle(for: detail.voting) {
                        Text(title).font(.subheadline).foregroundColor(.secondary)
                    }

                    if let date = detail.voting.date { Text(date).font(.caption).foregroundColor(.secondary) }
                    if let kind = detail.voting.kind { Text("Rodzaj: \(kind)").font(.subheadline) }
                    if let majority = detail.voting.majorityType { Text("Większość: \(majority)").font(.subheadline) }

                    Divider().padding(.vertical, 4)

                    Text("ZA: \(detail.voting.yes) • PRZECIW: \(detail.voting.no) • WSTRZ.: \(detail.voting.abstain)")
                        .font(.body)
                        .fontWeight(.medium)

                    Text("Oddano głosów: \(detail.voting.totalVoted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            if detail.clubVotes.isEmpty {
                Section {
                    Text("voting_no_club_tally")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Section(header: Text("Rozkład głosów").font(.title3.bold())) {
                    ForEach(detail.clubVotes, id: \.club) { summary in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.club).font(.headline)
                            Text("ZA: \(summary.yes) | PRZECIW: \(summary.no) | WSTRZ.: \(summary.abstain) | NIEOBECNI: \(summary.absent)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
