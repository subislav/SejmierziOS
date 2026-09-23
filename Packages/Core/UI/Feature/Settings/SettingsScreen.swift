import SwiftUI
import Domain

public struct SettingsScreen: View {
    var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(String(localized: "settings_title", defaultValue: "Ustawienia"))
                .font(.title2)
                .fontWeight(.bold)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "settings_data_mode", defaultValue: "Globalny tryb źródła danych"))
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
                Text(String(localized: "settings_language", defaultValue: "Język aplikacji"))
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
            return String(localized: "settings_mode_online", defaultValue: "Online (Pobieranie z API Sejmu)")
        }
        return String(localized: "settings_mode_offline", defaultValue: "Offline (Lokalna pamięć podręczna)")
    }
}
