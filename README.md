# Sejmierz (iOS)

Native Swift/SwiftUI client for the Polish Sejm public API (`api.sejm.gov.pl`, term 10). Browse MPs, votings, and clubs, with online/offline data mode, PL/EN UI language, and a telemetry tab for performance measurements.

## Structure

Local SPM package at `Packages/Core`:

| Target | Role |
|--------|------|
| `AppFeature` | App composition (`AppContainer`), root `TabView`, settings drawer |
| `UI` | Screens, view models, navigation, L10n |
| `Domain` | Models, repository protocols, use cases, benchmark contracts |
| `Data` | Sejm API, GRDB cache, repository implementations, settings |

```
SejmierziOS/
├── Sejmierz/              # Host app (@main)
├── Sejmierz.xcodeproj/
└── Packages/Core/
    ├── AppFeature/
    ├── Domain/
    ├── Data/
    └── UI/Feature/        # Mps, Votings, Clubs, details, Benchmark, Settings
```

## Features

- Four tabs: MPs, Votings, Clubs, Telemetry
- Independent `NavigationStack` per tab
- Settings drawer: online/offline source + PL/EN language (applies across UI via `L10n`)
- GRDB local cache for offline mode
- Telemetry: display timing, scroll jank, CPU samples, CSV export

## Stack

- Swift 5.9+, SwiftUI, iOS 17+
- Observation (`@Observable`)
- GRDB.swift
- Swift Concurrency (`async`/`await`, broadcast `AsyncStream` for settings)

## Run

Open `Sejmierz.xcodeproj`, pick an iOS 17+ simulator or device, build the `Sejmierz` scheme.
