import SwiftUI
import Domain
import UI

public struct RootView: View {
    private let container: AppContainer
    @State private var mpsRouter = RootRouter()
    @State private var votingsRouter = RootRouter()
    @State private var clubsRouter = RootRouter()
    @State private var isSettingsOpen = false
    @State private var settingsViewModel: SettingsViewModel
    @State private var appLanguage: AppLanguage = .pl

    public init(container: AppContainer) {
        self.container = container
        _settingsViewModel = State(initialValue: SettingsViewModel(settings: container.settingsRepository))
    }

    public var body: some View {
        TabView {
            NavigationStack(path: $mpsRouter.path) {
                MpsScreen(viewModel: container.makeMpsViewModel())
                    .navigationDestination(for: AppRoute.self) { handleRoute($0) }
            }
            .tabItem { Label(L10n.string(.tabMps, language: appLanguage), systemImage: "person.3") }
            .environment(mpsRouter)

            NavigationStack(path: $votingsRouter.path) {
                VotingsScreen(viewModel: container.makeVotingsViewModel())
                    .navigationDestination(for: AppRoute.self) { handleRoute($0) }
            }
            .tabItem { Label(L10n.string(.tabVotings, language: appLanguage), systemImage: "hand.raised") }
            .environment(votingsRouter)

            NavigationStack(path: $clubsRouter.path) {
                ClubsScreen(viewModel: container.makeClubsViewModel())
                    .navigationDestination(for: AppRoute.self) { handleRoute($0) }
            }
            .tabItem { Label(L10n.string(.tabClubs, language: appLanguage), systemImage: "building.columns") }
            .environment(clubsRouter)

            NavigationStack {
                BenchmarkScreen(viewModel: container.makeBenchmarkViewModel())
            }
            .tabItem { Label(L10n.string(.tabTelemetry, language: appLanguage), systemImage: "chart.bar.xaxis") }
        }
        .environment(\.benchmarkContext, container.benchmarkContext)
        .environment(\.openSettings) {
            withAnimation(.easeInOut(duration: 0.25)) {
                isSettingsOpen = true
            }
        }
        .environment(\.appLanguage, appLanguage)
        .environment(\.locale, Locale(identifier: appLanguage.rawValue))
        .overlay {
            SettingsDrawerOverlay(isOpen: $isSettingsOpen) {
                SettingsScreen(viewModel: settingsViewModel)
            }
        }
        .task {
            for await language in container.settingsRepository.appLanguageStream {
                appLanguage = language
            }
        }
    }

    @ViewBuilder
    private func handleRoute(_ route: AppRoute) -> some View {
        switch route {
        case .mpDetail(let id):
            MpDetailScreen(viewModel: container.makeMpDetailViewModel(id: id))
        case .votingDetail(let sitting, let num):
            VotingDetailScreen(viewModel: container.makeVotingDetailViewModel(sitting: sitting, votingNumber: num))
        case .clubDetail(let id):
            ClubDetailScreen(viewModel: container.makeClubDetailViewModel(id: id))
        case .benchmark:
            BenchmarkScreen(viewModel: container.makeBenchmarkViewModel())
        }
    }
}
