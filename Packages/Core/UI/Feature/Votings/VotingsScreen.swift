import SwiftUI
import Domain

public struct VotingsScreen: View {
    @State var viewModel: VotingsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings

    public init(viewModel: VotingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.votings.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.votings.isEmpty {
                MessageView(message: error.localizedMessage) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.votings.isEmpty {
                MessageView(message: String(localized: "empty_votings", defaultValue: "Brak głosowań do wyświetlenia."))
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
        .navigationTitle(String(localized: "votings_title", defaultValue: "Głosowania"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(String(localized: "action_refresh", defaultValue: "Odśwież")) {
                    viewModel.send(.refresh)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
                .accessibilityLabel(String(localized: "settings_menu", defaultValue: "Ustawienia"))
            }
        }
        .screenDisplayTracking(slice: "Votings", contentLoaded: !viewModel.state.votings.isEmpty)
        .scrollJankTracking(slice: "Votings")
    }
}
