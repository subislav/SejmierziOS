import SwiftUI
import Domain

public struct BenchmarkScreen: View {
    @State var viewModel: BenchmarkViewModel
    @Environment(\.openSettings) private var openSettings

    public init(viewModel: BenchmarkViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text(String(localized: "benchmark_iterations", defaultValue: "Liczba iteracji")).font(.caption)
                        TextField("35", text: $viewModel.iterationsInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.iterationsInput) { _, _ in viewModel.applyConfig() }
                    }
                    VStack(alignment: .leading) {
                        Text(String(localized: "benchmark_warmup", defaultValue: "Rozgrzewka")).font(.caption)
                        TextField("5", text: $viewModel.warmupInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.warmupInput) { _, _ in viewModel.applyConfig() }
                    }
                }

                HStack(spacing: 12) {
                    Button(action: viewModel.exportCsv) {
                        Text(String(localized: "benchmark_export_csv", defaultValue: "Eksport CSV"))
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)

                    Button(action: viewModel.clear) {
                        Text(String(localized: "benchmark_clear", defaultValue: "Wyczyść"))
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                }

                Text("\(viewModel.sampleCount) próbek")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let path = viewModel.lastExportPath {
                    Text("Wyeksportowano do: \(path)")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }

                if viewModel.stats.isEmpty {
                    Text(String(localized: "benchmark_no_data", defaultValue: "Brak pomiarów. Przeglądaj aplikację, aby je zebrać."))
                        .padding(.top, 24)
                } else {
                    ForEach(viewModel.stats, id: \.stableId) { stat in
                        StatCard(stats: stat)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(String(localized: "benchmark_title", defaultValue: "Telemetria"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
                .accessibilityLabel(String(localized: "settings_menu", defaultValue: "Ustawienia"))
            }
        }
    }
}

struct StatCard: View {
    let stats: BenchmarkStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            let title = stats.slice != nil ? "\(stats.name)  ·  \(stats.slice!)" : stats.name
            Text(title).font(.headline)

            Text("n=\(stats.sampleCount)  mean=\(stats.mean.fmt) \(stats.unit)  median=\(stats.median.fmt)  p95=\(stats.p95.fmt)")
                .font(.caption)
            Text("min=\(stats.min.fmt)  max=\(stats.max.fmt)  sd=\(stats.stdDev.fmt)")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

fileprivate extension Double {
    var fmt: String {
        return String(format: "%.2f", self)
    }
}
