# Sejmierz — Native iOS (Swift)

## 1. Purpose of the application

Sejmierz is a client application for the public parliamentary API of the Sejm of the Republic of Poland (`api.sejm.gov.pl`, current term `term10`). The product exposes three primary information domains—Members of Parliament (MPs), votings, and parliamentary clubs—together with an integrated telemetry (benchmarking) surface used for comparative performance evaluation across mobile paradigms.

This repository contains the **native iOS** realisation of Sejmierz. It is implemented in Swift and SwiftUI and is intended as the reference user-experience and navigation model for parallel Android and Compose Multiplatform implementations.

## 2. Architectural style

The project follows **Clean Architecture** with a clear separation of concerns across four Swift Package Manager (SPM) targets inside a single local package (`Packages/Core`):

| Layer | SPM target | Responsibility |
|-------|------------|----------------|
| Presentation / UI | `UI` | SwiftUI screens, Observation-based view models, navigation helpers, shared visual components |
| Application composition | `AppFeature` | Dependency graph (`AppContainer`), root `TabView` shell, settings drawer host |
| Domain | `Domain` | Entities, repository protocols, use cases, paging abstractions, benchmark contracts |
| Data | `Data` | Networking (`URLSession`), GRDB persistence, repository implementations, settings store |

Dependency direction is strictly inward: `AppFeature` → `UI` / `Data` → `Domain`. The Domain layer has no UI or framework UI dependencies.

Presentation state management uses **MVVM** with Swift’s Observation framework (`@Observable` view models). User intents are modelled as discrete actions (refresh, load more, configuration changes) handled by the view model, which orchestrates use cases and updates immutable UI state.

## 3. Module and directory structure

```
SejmierziOS/
├── Sejmierz/                 # Thin host application (@main, assets)
├── Sejmierz.xcodeproj/
└── Packages/Core/
    ├── Package.swift
    ├── AppFeature/           # RootView, AppContainer, AppView
    ├── Domain/               # Models, repositories, use cases, benchmark
    ├── Data/                 # API, GRDB, mappers, settings, metric sinks
    └── UI/
        ├── Feature/          # Mps, MpDetail, Votings, VotingDetail, Clubs,
        │                     # ClubDetail, Benchmark, Settings
        ├── Navigation/       # AppRoute, RootRouter
        └── Core/             # State views, drawer overlay, telemetry hooks
```

Features are organised as vertical slices under `UI/Feature`, with matching Domain use cases and Data repositories.

## 4. Navigation and interaction model

The root shell is a SwiftUI `TabView` with four tabs:

1. Posłowie (MPs)
2. Głosowania (Votings)
3. Kluby (Clubs)
4. Telemetria (Benchmark / telemetry)

Each content tab owns an independent `NavigationStack` and `RootRouter` path, preventing cross-tab stack leakage. List → detail navigation uses typed `AppRoute` values. Telemetry is a first-class tab root (not a modal shortcut).

Application settings (online/offline data-source mode and PL/EN language) are presented as a **trailing slide-over panel**, opened from a menu control on every tab root. Locale is applied via SwiftUI’s environment locale based on the selected language stream.

## 5. Data and concurrency

- **Remote access:** custom `URLSession` stack with a network timing interceptor feeding the benchmark pipeline.
- **Local cache:** GRDB (SQLite) with local data sources for MPs, votings, and clubs.
- **Repository policy:** online-first with offline mode selectable through settings (explicit `DataSourceMode`, not a silent SSOT merge).
- **Paging:** Domain-level offset/limit paginator shared conceptually with the Kotlin stacks.
- **Concurrency:** Swift Concurrency (`async`/`await`, `AsyncStream` for settings observation).

## 6. Telemetry and benchmarking

Benchmarking is a first-class concern. The Domain layer defines metric sinks, runners, and statistical summarisation. The UI layer instruments screen display timing, scroll jank, main-thread stalls (>16 ms), and CPU avg/peak during scroll and parse. Cold start (`app.coldStart`) is recorded from process launch to the first rendered frame. Configuration (iteration and warmup counts), CSV export under `Documents/benchmark-exports/`, and metric clearing are available on the Telemetria tab. Global tags include a dynamic network type (WIFI / CELLULAR / …).

## 7. Principal technologies and dependencies

| Concern | Technology |
|---------|------------|
| Language / UI | Swift 5.9+, SwiftUI, iOS 17+ |
| Packaging | Swift Package Manager (local multi-target package) |
| Persistence | GRDB.swift |
| State | Observation (`@Observable`) |
| Host | Xcode application target `Sejmierz` |

## 8. Design patterns employed

- Clean Architecture (layered modules)
- MVVM with unidirectional intents
- Repository pattern
- Use-case / interactor pattern
- Dependency injection via composition root (`AppContainer`)
- Router / typed navigation destinations
- Strategy-like data-source mode switching (online vs offline)

## 9. Build and run

Open `Sejmierz.xcodeproj` in Xcode, select an iOS Simulator or device (iOS 17+), and build the `Sejmierz` scheme. The local package resolves automatically from `Packages/Core`.
