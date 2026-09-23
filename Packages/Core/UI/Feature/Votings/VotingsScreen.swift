import SwiftUI
import Domain

public struct VotingsScreen: View {
    @State var viewModel: VotingsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings
    @Environment(\.appLanguage) private var language

    public init(viewModel: VotingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.votings.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.votings.isEmpty {
                MessageView(message: error.localizedMessage(language: language)) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.votings.isEmpty {
                MessageView(message: L10n.string(.emptyVotings, language: language))
            } else {
                List {
                    ForEach(viewModel.state.votings, id: \.self) { voting in
                        VotingListItem(voting: voting)
                            .onTapGesture {
                                router.navigate(to: .votingDetail(sitting: voting.sitting, votingNumber: voting.votingNumber))
                            }
                            .onAppear {
                                if voting == viewModel.state.votings.last {
                                    viewModel.send(.loadMore)
                                }
                            }
                    }
                    if viewModel.state.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.send(.refresh)
                }
            }
        }
        .navigationTitle(L10n.string(.votingsTitle, language: language))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.string(.actionRefresh, language: language)) {
                    viewModel.send(.refresh)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
                .accessibilityLabel(L10n.string(.settingsMenu, language: language))
            }
        }
        .screenDisplayTracking(slice: "Votings", contentLoaded: !viewModel.state.votings.isEmpty)
        .scrollJankTracking(slice: "Votings")
    }
}
