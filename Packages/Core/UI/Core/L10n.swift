import Foundation
import Domain
import SwiftUI

private struct AppLanguageKey: EnvironmentKey {
    static let defaultValue: AppLanguage = .pl
}

public extension EnvironmentValues {
    var appLanguage: AppLanguage {
        get { self[AppLanguageKey.self] }
        set { self[AppLanguageKey.self] = newValue }
    }
}

public enum L10n {
    public enum Key: String {
        case settingsTitle
        case settingsDataMode
        case settingsLanguage
        case settingsModeOnline
        case settingsModeOffline
        case settingsMenu

        case mpsTitle
        case clubsTitle
        case votingsTitle
        case mpDetailTitle
        case clubDetailTitle
        case votingDetailTitle
        case mpInactive

        case emptyMps
        case emptyClubs
        case emptyVotings
        case clubNoMembers
        case votingNoClubTally

        case actionRefresh
        case actionRetry

        case benchmarkTitle
        case benchmarkIterations
        case benchmarkWarmup
        case benchmarkExportCsv
        case benchmarkClear
        case benchmarkNoData
        case benchmarkSamples
        case benchmarkExportedTo

        case tabMps
        case tabVotings
        case tabClubs
        case tabTelemetry

        case club
        case code
        case membersCount
        case members
        case email
        case phone
        case fax
        case district
        case electoralDistrict
        case districtNumber
        case voivodeship
        case voteCount
        case basicInfo
        case personalData
        case profession
        case education
        case birthDate
        case birthPlace
        case kind
        case majority
        case votesCast
        case voteBreakdown
        case voteYes
        case voteNo
        case voteAbstain
        case voteAbsent

        case errorNetwork
        case errorHttp
        case errorSerialization
        case errorNotCached
        case errorEmpty
        case errorUnknown
    }

    public static func string(_ key: Key, language: AppLanguage) -> String {
        switch language {
        case .en:
            return en[key] ?? pl[key] ?? key.rawValue
        case .pl:
            return pl[key] ?? key.rawValue
        }
    }

    public static func labeled(_ key: Key, value: String, language: AppLanguage) -> String {
        "\(string(key, language: language)): \(value)"
    }

    public static func votingTitle(sitting: Int, votingNumber: Int, language: AppLanguage) -> String {
        switch language {
        case .en:
            return "Sitting \(sitting), Voting \(votingNumber)"
        case .pl:
            return "Posiedzenie \(sitting), Głosowanie \(votingNumber)"
        }
    }

    public static func voteLine(yes: Int, no: Int, abstain: Int, language: AppLanguage) -> String {
        "\(string(.voteYes, language: language)): \(yes) • \(string(.voteNo, language: language)): \(no) • \(string(.voteAbstain, language: language)): \(abstain)"
    }

    public static func clubVoteLine(yes: Int, no: Int, abstain: Int, absent: Int, language: AppLanguage) -> String {
        "\(string(.voteYes, language: language)): \(yes) | \(string(.voteNo, language: language)): \(no) | \(string(.voteAbstain, language: language)): \(abstain) | \(string(.voteAbsent, language: language)): \(absent)"
    }

    public static func httpError(code: Int, language: AppLanguage) -> String {
        String(format: string(.errorHttp, language: language), code)
    }

    private static let pl: [Key: String] = [
        .settingsTitle: "Ustawienia",
        .settingsDataMode: "Globalny tryb źródła danych",
        .settingsLanguage: "Język aplikacji",
        .settingsModeOnline: "Online (Pobieranie z API Sejmu)",
        .settingsModeOffline: "Offline (Lokalna pamięć podręczna)",
        .settingsMenu: "Ustawienia",
        .mpsTitle: "Posłowie",
        .clubsTitle: "Kluby",
        .votingsTitle: "Głosowania",
        .mpDetailTitle: "Profil posła",
        .clubDetailTitle: "Klub",
        .votingDetailTitle: "Głosowanie",
        .mpInactive: "NIEAKTYWNY(A)",
        .emptyMps: "Brak posłów do wyświetlenia.",
        .emptyClubs: "Brak klubów do wyświetlenia.",
        .emptyVotings: "Brak głosowań do wyświetlenia.",
        .clubNoMembers: "Brak członków do wyświetlenia.",
        .votingNoClubTally: "Brak rozkładu głosów klubów.",
        .actionRefresh: "Odśwież",
        .actionRetry: "Ponów",
        .benchmarkTitle: "Telemetria",
        .benchmarkIterations: "Liczba iteracji",
        .benchmarkWarmup: "Rozgrzewka",
        .benchmarkExportCsv: "Eksport CSV",
        .benchmarkClear: "Wyczyść",
        .benchmarkNoData: "Brak pomiarów. Przeglądaj aplikację, aby je zebrać.",
        .benchmarkSamples: "próbek",
        .benchmarkExportedTo: "Wyeksportowano do: %@",
        .tabMps: "Posłowie",
        .tabVotings: "Głosowania",
        .tabClubs: "Kluby",
        .tabTelemetry: "Telemetria",
        .club: "Klub",
        .code: "Kod",
        .membersCount: "Liczba członków",
        .members: "Członkowie",
        .email: "E-mail",
        .phone: "Telefon",
        .fax: "Faks",
        .district: "Okręg",
        .electoralDistrict: "Okręg wyborczy",
        .districtNumber: "Numer okręgu",
        .voivodeship: "Województwo",
        .voteCount: "Liczba głosów",
        .basicInfo: "Informacje podstawowe",
        .personalData: "Dane personalne",
        .profession: "Zawód",
        .education: "Wykształcenie",
        .birthDate: "Data urodzenia",
        .birthPlace: "Miejsce urodzenia",
        .kind: "Rodzaj",
        .majority: "Większość",
        .votesCast: "Oddano głosów",
        .voteBreakdown: "Rozkład głosów",
        .voteYes: "ZA",
        .voteNo: "PRZECIW",
        .voteAbstain: "WSTRZ.",
        .voteAbsent: "NIEOBECNI",
        .errorNetwork: "Błąd sieci. Sprawdź połączenie i spróbuj ponownie.",
        .errorHttp: "Błąd serwera (%d).",
        .errorSerialization: "Nie udało się przetworzyć odpowiedzi serwera.",
        .errorNotCached: "Brak danych w pamięci podręcznej. Przełącz na tryb online.",
        .errorEmpty: "Brak danych do wyświetlenia.",
        .errorUnknown: "Wystąpił nieoczekiwany błąd.",
    ]

    private static let en: [Key: String] = [
        .settingsTitle: "Settings",
        .settingsDataMode: "Global data source mode",
        .settingsLanguage: "App language",
        .settingsModeOnline: "Online (Fetch from Sejm API)",
        .settingsModeOffline: "Offline (Local cache)",
        .settingsMenu: "Settings",
        .mpsTitle: "MPs",
        .clubsTitle: "Clubs",
        .votingsTitle: "Votings",
        .mpDetailTitle: "MP profile",
        .clubDetailTitle: "Club",
        .votingDetailTitle: "Voting",
        .mpInactive: "INACTIVE",
        .emptyMps: "No MPs to display.",
        .emptyClubs: "No clubs to display.",
        .emptyVotings: "No votings to display.",
        .clubNoMembers: "No members to display.",
        .votingNoClubTally: "No club vote breakdown available.",
        .actionRefresh: "Refresh",
        .actionRetry: "Retry",
        .benchmarkTitle: "Telemetry",
        .benchmarkIterations: "Iterations",
        .benchmarkWarmup: "Warmup",
        .benchmarkExportCsv: "Export CSV",
        .benchmarkClear: "Clear",
        .benchmarkNoData: "No measurements yet. Browse the app to collect them.",
        .benchmarkSamples: "samples",
        .benchmarkExportedTo: "Exported to: %@",
        .tabMps: "MPs",
        .tabVotings: "Votings",
        .tabClubs: "Clubs",
        .tabTelemetry: "Telemetry",
        .club: "Club",
        .code: "Code",
        .membersCount: "Members",
        .members: "Members",
        .email: "Email",
        .phone: "Phone",
        .fax: "Fax",
        .district: "District",
        .electoralDistrict: "Electoral district",
        .districtNumber: "District number",
        .voivodeship: "Voivodeship",
        .voteCount: "Votes",
        .basicInfo: "Basic information",
        .personalData: "Personal data",
        .profession: "Profession",
        .education: "Education",
        .birthDate: "Date of birth",
        .birthPlace: "Place of birth",
        .kind: "Type",
        .majority: "Majority",
        .votesCast: "Votes cast",
        .voteBreakdown: "Vote breakdown",
        .voteYes: "YES",
        .voteNo: "NO",
        .voteAbstain: "ABST.",
        .voteAbsent: "ABSENT",
        .errorNetwork: "Network error. Check your connection and try again.",
        .errorHttp: "Server error (%d).",
        .errorSerialization: "Failed to parse the server response.",
        .errorNotCached: "No cached data. Switch to online mode.",
        .errorEmpty: "Nothing to display.",
        .errorUnknown: "An unexpected error occurred.",
    ]
}
