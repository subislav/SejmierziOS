import SwiftUI
import Domain

public struct MpDetailScreen: View {
    @State var viewModel: MpDetailViewModel
    @Environment(\.benchmarkContext) private var benchmarkContext
    @Environment(\.appLanguage) private var language

    public init(viewModel: MpDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        stateDrivenContent
            .navigationTitle(L10n.string(.mpDetailTitle, language: language))
            .navigationBarTitleDisplayMode(.inline)
            .screenDisplayTracking(slice: "MP detail", contentLoaded: viewModel.state.mp != nil)
    }

    @ViewBuilder
    private var stateDrivenContent: some View {
        if viewModel.state.isLoading {
            LoadingView()
        } else if let error = viewModel.state.error {
            MessageView(message: error.localizedMessage(language: language)) {
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
                        Text(L10n.string(.mpInactive, language: language))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section(header: Text(L10n.string(.basicInfo, language: language))) {
                if let club = mp.club {
                    DetailRow(label: L10n.string(.club, language: language), value: club)
                }
                if let district = mp.districtName {
                    DetailRow(label: L10n.string(.electoralDistrict, language: language), value: district)
                }
                if let districtNum = mp.districtNum {
                    DetailRow(label: L10n.string(.districtNumber, language: language), value: "\(districtNum)")
                }
                if let voivodeship = mp.voivodeship {
                    DetailRow(label: L10n.string(.voivodeship, language: language), value: voivodeship)
                }
                if let votes = mp.numberOfVotes {
                    DetailRow(label: L10n.string(.voteCount, language: language), value: "\(votes)")
                }
            }

            Section(header: Text(L10n.string(.personalData, language: language))) {
                if let profession = mp.profession {
                    DetailRow(label: L10n.string(.profession, language: language), value: profession)
                }
                if let education = mp.educationLevel {
                    DetailRow(label: L10n.string(.education, language: language), value: education)
                }
                if let birthDate = mp.birthDate {
                    DetailRow(label: L10n.string(.birthDate, language: language), value: birthDate)
                }
                if let birthLocation = mp.birthLocation {
                    DetailRow(label: L10n.string(.birthPlace, language: language), value: birthLocation)
                }
                if let email = mp.email {
                    DetailRow(label: L10n.string(.email, language: language), value: email)
                }
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
