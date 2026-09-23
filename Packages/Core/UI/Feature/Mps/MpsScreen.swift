import SwiftUI
import Domain

public struct MpsScreen: View {
    @State var viewModel: MpsViewModel
    @Environment(RootRouter.self) private var router
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.openSettings) private var openSettings
    @Environment(\.appLanguage) private var language

    public init(viewModel: MpsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.state.isLoading && viewModel.state.mps.isEmpty {
                LoadingView()
            } else if let error = viewModel.state.error, viewModel.state.mps.isEmpty {
                MessageView(message: error.localizedMessage(language: language)) {
                    viewModel.send(.refresh)
                }
            } else if viewModel.state.mps.isEmpty {
                MessageView(message: L10n.string(.emptyMps, language: language))
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
        .navigationTitle(L10n.string(.mpsTitle, language: language))
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
        .screenDisplayTracking(slice: "MPs", contentLoaded: !viewModel.state.mps.isEmpty)
        .scrollJankTracking(slice: "MPs")
    }
}
