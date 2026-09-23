# Sejmierz — Native iOS (Swift)

## 1. Purpose of the application

Sejmierz is a client application for the public parliamentary API of the Sejm of the Republic of Poland (`api.sejm.gov.pl`, current term `term10`). The product exposes three primary information domains—Members of Parliament (MPs), votings, and parliamentary clubs—together with an integrated telemetry (benchmarking) surface used for comparative performance evaluation across mobile paradigms.

This repository contains the **native iOS** realisation of Sejmierz. It is implemented in Swift and SwiftUI and is intended as the reference user-experience and navigation model for parallel Android and Compose Multiplatform implementations.

## 2. Architectural style

The project follows **Clean Architecture** with a clear separation of concerns across four Swift Package Manager (SPM) targets inside a single local package (`Packages/Core`):

| Layer | SPM target | Responsibility |
|-------|------------|----------------|
| Presentation / UI | `UI` | SwiftUI screens, Observation-based view models, navigation helpers, shared visual components, in-app localisation (`L10n`) |
| Application composition | `AppFeature` | Dependency graph (`AppContainer`), root `TabView` shell, settings drawer host |
| Domain | `Domain` | Entities, repository protocols, use cases, paging abstractions, benchmark contracts, multi-subscriber stream utilities |
| Data | `Data` | Networking (`URLSession`), GRDB persistence, repository implementations, in-memory settings store, metric sinks |

Dependency direction is strictly inward: `AppFeature` → `UI` / `Data` → `Domain`. The Domain layer has no UI or framework UI dependencies.

Presentation state management uses **MVVM** with Swift’s Observation framework (`@Observable` view models). User intents are modelled as discrete actions (refresh, load more, configuration changes) handled by the view model, which orchestrates use cases and updates immutable UI state.

## 3. Module and directory structure

```
SejmierziOS/
├── Sejmierz/                 # Thin host application (@main, assets)
├── Sejmierz.xcodeproj/
└── Packages/Core/
    ├── Package.swift
    ├── AppFeature/           # RootView, AppContainer, AppView, platform samplers
    ├── Domain/               # Models, repositories, use cases, benchmark, AsyncStreamBroadcast
    ├── Data/                 # API, GRDB, mappers, settings, metric sinks
    └── UI/
        ├── Feature/          # Mps, MpDetail, Votings, VotingDetail, Clubs,
        │                     # ClubDetail, Benchmark, Settings
        ├── Navigation/       # AppRoute, RootRouter
        └── Core/             # State views, drawer overlay, L10n, telemetry hooks
```

Features are organised as vertical slices under `UI/Feature`, with matching Domain use cases and Data repositories.

## 4. Navigation and interaction model

The root shell is a SwiftUI `TabView` with four tabs:

1. Posłowie (MPs)
2. Głosowania (Votings)
3. Kluby (Clubs)
4. Telemetria (Benchmark / telemetry)

Each content tab owns an independent `NavigationStack` and `RootRouter` path, preventing cross-tab stack leakage. List → detail navigation uses typed `AppRoute` values. Telemetry is a first-class tab root (not a modal shortcut).

Application settings (online/offline data-source mode and PL/EN language) are presented as a **trailing slide-over drawer**, opened from a menu control on every tab root. The drawer is mounted as a SwiftUI overlay: when closed it does not intercept hit testing; when open, a dimmed backdrop dismisses it on tap.

UI copy is resolved through a central `L10n` catalogue (Polish and English). The selected `AppLanguage` is published via the settings repository stream, injected into the SwiftUI environment, and consumed by list screens, detail screens, list items, error messages, and tab labels so that a language change updates the entire interface—not only the tab bar.

Shared list and telemetry view models are retained in `AppContainer` so that settings observers and metric collectors remain single, long-lived subscribers for the lifetime of the app session.

## 5. Data and concurrency

- **Remote access:** custom `URLSession` stack with a network timing interceptor feeding the benchmark pipeline.
- **Local cache:** GRDB (SQLite) with local data sources for MPs, votings, and clubs.
- **Repository policy:** online-first with offline mode selectable through settings (explicit `DataSourceMode`, not a silent SSOT merge). Switching mode notifies all listening screens through a broadcast stream and triggers list refresh.
- **Paging:** Domain-level offset/limit paginator shared conceptually with the Kotlin stacks.
- **Concurrency:** Swift Concurrency (`async`/`await`). Settings (`DataSourceMode`, `AppLanguage`, `BenchmarkConfig`) and metric snapshots are observed via `AsyncStream`. Because a single `AsyncStream` delivers each element to only one consumer, the Domain layer provides `AsyncStreamBroadcast`, which fans out the current value and subsequent yields to every subscriber (settings UI, root locale bridge, list view models, telemetry).

## 6. Telemetry and benchmarking

Benchmarking is a first-class concern. The Domain layer defines metric sinks, runners, and statistical summarisation. The UI layer instruments screen display timing, scroll jank, main-thread stalls (>16 ms), and CPU avg/peak during scroll and parse. Cold start (`app.coldStart`) is recorded from process launch to the first rendered frame. Configuration (iteration and warmup counts), CSV export under `Documents/benchmark-exports/`, and metric clearing are available on the Telemetria tab. Clearing updates both the in-memory metric store and the visible sample count/statistics immediately. Global tags include a dynamic network type (WIFI / CELLULAR / …).

## 7. Principal technologies and dependencies

| Concern | Technology |
|---------|------------|
| Language / UI | Swift 5.9+, SwiftUI, iOS 17+ |
| Packaging | Swift Package Manager (local multi-target package) |
| Persistence | GRDB.swift |
| State | Observation (`@Observable`) |
| Localisation | In-app `L10n` (PL/EN), driven by settings `AppLanguage` |
| Host | Xcode application target `Sejmierz` |

## 8. Design patterns employed

- Clean Architecture (layered modules)
- MVVM with unidirectional intents
- Repository pattern
- Use-case / interactor pattern
- Dependency injection via composition root (`AppContainer`)
- Router / typed navigation destinations
- Strategy-like data-source mode switching (online vs offline)
- Broadcast / multi-subscriber observation for settings and metrics streams
