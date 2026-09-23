import SwiftUI
import Domain

public struct VotingDetailScreen: View {
    @State var viewModel: VotingDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.appLanguage) private var language

    public init(viewModel: VotingDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private func getDisplayTitle(for voting: Voting) -> String {
        if let topic = voting.topic, !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return topic }
        if let title = voting.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return title }
        return L10n.votingTitle(sitting: voting.sitting, votingNumber: voting.votingNumber, language: language)
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle(L10n.string(.votingDetailTitle, language: language))
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "Voting detail", contentLoaded: viewModel.state.detail != nil)
            .scrollJankTracking(slice: "Voting detail")
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
                    if let kind = detail.voting.kind {
                        Text(L10n.labeled(.kind, value: kind, language: language)).font(.subheadline)
                    }
                    if let majority = detail.voting.majorityType {
                        Text(L10n.labeled(.majority, value: majority, language: language)).font(.subheadline)
                    }

                    Divider().padding(.vertical, 4)

                    Text(L10n.voteLine(
                        yes: detail.voting.yes,
                        no: detail.voting.no,
                        abstain: detail.voting.abstain,
                        language: language
                    ))
                    .font(.body)
                    .fontWeight(.medium)

                    Text(L10n.labeled(.votesCast, value: "\(detail.voting.totalVoted)", language: language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            if detail.clubVotes.isEmpty {
                Section {
                    Text(L10n.string(.votingNoClubTally, language: language))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Section(header: Text(L10n.string(.voteBreakdown, language: language)).font(.title3.bold())) {
                    ForEach(detail.clubVotes, id: \.club) { summary in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.club).font(.headline)
                            Text(L10n.clubVoteLine(
                                yes: summary.yes,
                                no: summary.no,
                                abstain: summary.abstain,
                                absent: summary.absent,
                                language: language
                            ))
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
