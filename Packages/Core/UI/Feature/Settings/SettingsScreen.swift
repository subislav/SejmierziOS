import SwiftUI
import Domain

public struct SettingsScreen: View {
    var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(L10n.string(.settingsTitle, language: viewModel.state.language))
                .font(.title2)
                .fontWeight(.bold)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.string(.settingsDataMode, language: viewModel.state.language))
                        .font(.headline)
                    Text(modeSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle(
                    "",
                    isOn: Binding(
                        get: { viewModel.state.mode == .online },
                        set: { isOnline in
                            viewModel.send(.toggleMode(isOnline ? .online : .offline))
                        }
                    )
                )
                .labelsHidden()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.string(.settingsLanguage, language: viewModel.state.language))
                    .font(.headline)

                Picker(
                    "",
                    selection: Binding(
                        get: { viewModel.state.language },
                        set: { viewModel.send(.changeLanguage($0)) }
                    )
                ) {
                    Text("PL").tag(AppLanguage.pl)
                    Text("EN").tag(AppLanguage.en)
                }
                .pickerStyle(.segmented)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .screenDisplayTracking(slice: "Settings", contentLoaded: true)
    }

    private var modeSubtitle: String {
        if viewModel.state.mode == .online {
            return L10n.string(.settingsModeOnline, language: viewModel.state.language)
        }
        return L10n.string(.settingsModeOffline, language: viewModel.state.language)
    }
}
