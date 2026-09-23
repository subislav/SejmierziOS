import SwiftUI

public struct AppView: View {
    private let container: AppContainer
    @State private var coldStartReported = false

    public init() {
        do {
            self.container = try AppContainer()
            container.benchmarkContext.display.reportInitialDisplay(slice: "startup")
        } catch {
            fatalError("Krytyczny błąd podczas inicjalizacji bazy danych lub DI: \(error)")
        }
    }

    public var body: some View {
        RootView(container: container)
            .onAppear {
                Task { @MainActor in
                    await Task.yield()
                    container.benchmarkContext.display.reportFullDisplay(slice: "startup")
                    if !coldStartReported {
                        container.benchmarkContext.display.reportColdStart(elapsedMs: ProcessLaunchMark.elapsedMs())
                        coldStartReported = true
                    }
                }
            }
    }
}
