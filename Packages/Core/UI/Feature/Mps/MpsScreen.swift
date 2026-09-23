import SwiftUI
import Domain

public struct MpsScreen: View {
    @State var viewModel: MpsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings

    public init(viewModel: MpsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.mps.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.mps.isEmpty {
                MessageView(message: error.localizedMessage) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.mps.isEmpty {
                MessageView(message: String(localized: "empty_mps", defaultValue: "Brak posłów do wyświetlenia."))
            } else {
                List {
                    ForEach(viewModel.state.mps) { mp in
                        MpListItem(mp: mp)
                            .onTapGesture {
                                router.navigate(to: .mpDetail(id: mp.id))
                            }
                            .onAppear {
                                if mp == viewModel.state.mps.last {
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
        .navigationTitle(String(localized: "mps_title", defaultValue: "Posłowie"))
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
        .screenDisplayTracking(slice: "MPs", contentLoaded: !viewModel.state.mps.isEmpty)
        .scrollJankTracking(slice: "MPs")
    }
}
