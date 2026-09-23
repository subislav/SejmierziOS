import SwiftUI

public struct LoadingView: View {
    public init() {}

    public var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct MessageView: View {
    let message: String
    let onRetry: (() -> Void)?
    @Environment(\.appLanguage) private var language

    public init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text(L10n.string(.actionRetry, language: language))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
