import SwiftUI
import Domain

public struct ClubsScreen: View {
    @State var viewModel: ClubsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings
    @Environment(\.appLanguage) private var language

    public init(viewModel: ClubsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.clubs.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.clubs.isEmpty {
                MessageView(message: error.localizedMessage(language: language)) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.clubs.isEmpty {
                MessageView(message: L10n.string(.emptyClubs, language: language))
            } else {
                List {
                    ForEach(viewModel.state.clubs) { club in
                        ClubListItem(club: club)
                            .onTapGesture {
                                router.navigate(to: .clubDetail(id: club.id))
                            }
                            .onAppear {
                                if club == viewModel.state.clubs.last {
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
        .navigationTitle(L10n.string(.clubsTitle, language: language))
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
        .screenDisplayTracking(slice: "Clubs", contentLoaded: !viewModel.state.clubs.isEmpty)
        .scrollJankTracking(slice: "Clubs")
    }
}
