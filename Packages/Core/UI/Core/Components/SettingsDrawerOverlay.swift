import SwiftUI

private struct OpenSettingsKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    var openSettings: () -> Void {
        get { self[OpenSettingsKey.self] }
        set { self[OpenSettingsKey.self] = newValue }
    }
}

public struct SettingsDrawerOverlay<Content: View>: View {
    @Binding var isOpen: Bool
    let content: Content

    public init(isOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isOpen = isOpen
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            let drawerWidth = geo.size.width * 0.66

            ZStack(alignment: .trailing) {
                if isOpen {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isOpen = false
                            }
                        }
                        .transition(.opacity)

                    content
                        .frame(width: drawerWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: -2, y: 0)
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .allowsHitTesting(isOpen)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: isOpen)
    }
}
