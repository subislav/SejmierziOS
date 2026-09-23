import SwiftUI
import UIKit
import Domain

public struct ScrollJankTrackingModifier: ViewModifier {
    let slice: String
    @Environment(\.benchmarkContext) private var context

    public func body(content: Content) -> some View {
        content.background(
            ScrollActivityObserver(
                onBegin: {
                    context?.frames.start(slice: slice)
                    context?.cpu.start(slice: slice)
                },
                onEnd: {
                    context?.frames.stop()
                    context?.cpu.stop()
                }
            )
        )
    }
}

public extension View {
    func scrollJankTracking(slice: String) -> some View {
        modifier(ScrollJankTrackingModifier(slice: slice))
    }
}

private struct ScrollActivityObserver: UIViewRepresentable {
    let onBegin: () -> Void
    let onEnd: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        context.coordinator.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onBegin = onBegin
        context.coordinator.onEnd = onEnd
        context.coordinator.attach(to: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBegin: onBegin, onEnd: onEnd)
    }

    final class Coordinator: NSObject {
        var onBegin: () -> Void
        var onEnd: () -> Void
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?
        private var isTracking = false

        init(onBegin: @escaping () -> Void, onEnd: @escaping () -> Void) {
            self.onBegin = onBegin
            self.onEnd = onEnd
        }

        func attach(to view: UIView) {
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self, let view else { return }
                guard let scroll = Self.findScrollView(from: view) else { return }
                if scrollView === scroll { return }
                observation?.invalidate()
                scrollView = scroll
                observation = scroll.observe(\.contentOffset, options: [.new]) { [weak self] scroll, _ in
                    self?.handle(scroll: scroll)
                }
            }
        }

        private func handle(scroll: UIScrollView) {
            let moving = scroll.isDragging || scroll.isDecelerating || scroll.isTracking
            if moving && !isTracking {
                isTracking = true
                onBegin()
            } else if !moving && isTracking {
                isTracking = false
                onEnd()
            }
        }

        private static func findScrollView(from view: UIView) -> UIScrollView? {
            var current: UIView? = view
            while let node = current {
                if let scroll = node as? UIScrollView { return scroll }
                current = node.superview
            }
            func search(_ root: UIView) -> UIScrollView? {
                if let scroll = root as? UIScrollView { return scroll }
                for child in root.subviews {
                    if let found = search(child) { return found }
                }
                return nil
            }
            var windowRoot = view
            while let parent = windowRoot.superview { windowRoot = parent }
            return search(windowRoot)
        }

        deinit {
            observation?.invalidate()
            if isTracking { onEnd() }
        }
    }
}
