import SwiftUI
import Domain

public struct MpDetailScreen: View {
    @State var viewModel: MpDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext

    public init(viewModel: MpDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle(String(localized: "mp_detail_title", defaultValue: "Profil posła"))
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "MP detail", contentLoaded: viewModel.state.mp != nil)
    }

    @ViewBuilder
    private var stateDrivenContent: some View {
        if viewModel.state.isLoading {
            LoadingView()
        } else if let error = viewModel.state.error {
            MessageView(message: error.localizedMessage) {
                viewModel.retry()
            }
        } else if let mp = viewModel.state.mp {
            mpFieldsList(for: mp)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func mpFieldsList(for mp: Mp) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mp.firstLastName)
                        .font(.title)
                        .fontWeight(.bold)

                    if !mp.active {
                        Text(String(localized: "mp_inactive", defaultValue: "NIEAKTYWNY(A)"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section(header: Text("Informacje podstawowe")) {
                if let club = mp.club { DetailRow(label: "Klub", value: club) }
                if let district = mp.districtName { DetailRow(label: "Okręg wyborczy", value: district) }
                if let districtNum = mp.districtNum { DetailRow(label: "Numer okręgu", value: "\(districtNum)") }
                if let voivodeship = mp.voivodeship { DetailRow(label: "Województwo", value: voivodeship) }
                if let votes = mp.numberOfVotes { DetailRow(label: "Liczba głosów", value: "\(votes)") }
            }

            Section(header: Text("Dane personalne")) {
                if let profession = mp.profession { DetailRow(label: "Zawód", value: profession) }
                if let education = mp.educationLevel { DetailRow(label: "Wykształcenie", value: education) }
                if let birthDate = mp.birthDate { DetailRow(label: "Data urodzenia", value: birthDate) }
                if let birthLocation = mp.birthLocation { DetailRow(label: "Miejsce urodzenia", value: birthLocation) }
                if let email = mp.email { DetailRow(label: "E-mail", value: email) }
            }
        }
        .listStyle(.insetGrouped)
    }
}

fileprivate struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}
