import SwiftUI
import Domain
import QuartzCore

struct ScreenDisplayTrackingModifier: ViewModifier {
    let slice: String
    let contentLoaded: Bool

    @Environment(\.benchmarkContext) private var context
    @State private var startTime: UInt64 = DispatchTime.now().uptimeNanoseconds
    @State private var ttidReported = false
    @State private var ttfdReported = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !ttidReported else { return }
                Task { @MainActor in
                    await waitForNextFrame()
                    guard !ttidReported else { return }
                    recordMetric(name: MetricNames.uiTtid)
                    ttidReported = true
                }
            }
            .onChange(of: contentLoaded) { _, newValue in
                guard newValue, !ttfdReported else { return }
                Task { @MainActor in
                    await waitForNextFrame()
                    guard !ttfdReported else { return }
                    recordMetric(name: MetricNames.uiTtfd)
                    ttfdReported = true
                }
            }
    }

    private func waitForNextFrame() async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                DispatchQueue.main.async {
                    cont.resume()
                }
            }
            CATransaction.commit()
        }
    }

    private func recordMetric(name: String) {
        guard let benchmark = context?.benchmark else { return }
        let now = DispatchTime.now().uptimeNanoseconds
        let elapsedMs = Double(now - startTime) / 1_000_000.0
        benchmark.record(
            name: name,
            category: .ui,
            value: elapsedMs,
            unit: Metric.unitMs,
            tags: [MetricTag.slice: slice]
        )
    }
}

public extension View {
    func screenDisplayTracking(slice: String, contentLoaded: Bool) -> some View {
        modifier(ScreenDisplayTrackingModifier(slice: slice, contentLoaded: contentLoaded))
    }
}
