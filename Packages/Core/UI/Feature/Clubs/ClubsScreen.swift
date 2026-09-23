import SwiftUI
import Domain

public struct ClubsScreen: View {
    @State var viewModel: ClubsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings

    public init(viewModel: ClubsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.clubs.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.clubs.isEmpty {
                MessageView(message: error.localizedMessage) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.clubs.isEmpty {
                MessageView(message: String(localized: "empty_clubs", defaultValue: "Brak klubów do wyświetlenia."))
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
        .navigationTitle(String(localized: "clubs_title", defaultValue: "Kluby"))
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
        .screenDisplayTracking(slice: "Clubs", contentLoaded: !viewModel.state.clubs.isEmpty)
        .scrollJankTracking(slice: "Clubs")
    }
}
