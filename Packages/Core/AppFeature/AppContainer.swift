import Foundation
import GRDB
import Domain
import Data
import UI

@MainActor
public final class AppContainer {

    public let benchmarkContext: BenchmarkContext
    public let settingsRepository: SettingsRepository
    private let metricRepository: MetricRepository
    private let benchmarkExporter: BenchmarkExporter

    private let getMps: GetMpsUseCase
    private let getMpDetail: GetMpDetailUseCase
    private let getClubs: GetClubsUseCase
    private let getClubDetail: GetClubDetailUseCase
    private let getVotings: GetVotingsUseCase
    private let getVotingDetail: GetVotingDetailUseCase

    public init() throws {
        _ = ProcessLaunchMark.start
        self.settingsRepository = InMemorySettingsRepository()
        self.benchmarkExporter = IOSBenchmarkExporter()

        let runContext = IOSRunContextProvider()
        self.metricRepository = InMemoryMetricRepository()
        let compositeSink = CompositeMetricSink(sinks: [metricRepository, ConsoleMetricSink()])
        let enrichingSink = EnrichingMetricSink(delegate: compositeSink, runContext: runContext)

        let benchmark = Benchmark(sink: enrichingSink)
        self.benchmarkContext = BenchmarkContext(
            benchmark: benchmark,
            memory: IOSMemorySampler(),
            frames: IOSFrameMetricsSampler(benchmark: benchmark),
            display: IOSDisplayTracker(benchmark: benchmark),
            cpu: IOSCpuSampler(benchmark: benchmark)
        )

        let dbPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("sejmierz.sqlite")
        let dbManager = try DatabaseManager(databaseURL: dbPath)

        let session = SejmUrlSessionFactory.create()
        let interceptor = NetworkBenchmarkInterceptor(session: session, benchmarkContext: benchmarkContext)
        let api = SejmApi(interceptor: interceptor)

        let mpRepo = MpRepositoryImpl(api: api, local: MpLocalDataSource(dbWriter: dbManager.writer, benchmark: benchmark))
        let clubRepo = ClubRepositoryImpl(api: api, local: ClubLocalDataSource(dbWriter: dbManager.writer, benchmark: benchmark))
        let votingRepo = VotingRepositoryImpl(api: api, local: VotingLocalDataSource(dbWriter: dbManager.writer, benchmark: benchmark))

        self.getMps = GetMpsUseCase(repository: mpRepo, benchmark: benchmark)
        self.getMpDetail = GetMpDetailUseCase(repository: mpRepo, benchmark: benchmark)
        self.getClubs = GetClubsUseCase(repository: clubRepo, benchmark: benchmark)
        self.getClubDetail = GetClubDetailUseCase(repository: clubRepo, benchmark: benchmark)
        self.getVotings = GetVotingsUseCase(repository: votingRepo, benchmark: benchmark)
        self.getVotingDetail = GetVotingDetailUseCase(repository: votingRepo, benchmark: benchmark)
    }

    public func makeMpsViewModel() -> MpsViewModel {
        MpsViewModel(getMps: getMps, settings: settingsRepository)
    }

    public func makeMpDetailViewModel(id: Int) -> MpDetailViewModel {
        MpDetailViewModel(mpId: id, getMpDetail: getMpDetail, settings: settingsRepository)
    }

    public func makeClubsViewModel() -> ClubsViewModel {
        ClubsViewModel(getClubs: getClubs, settings: settingsRepository)
    }

    public func makeClubDetailViewModel(id: String) -> ClubDetailViewModel {
        ClubDetailViewModel(clubId: id, getClubDetail: getClubDetail, settings: settingsRepository)
    }

    public func makeVotingsViewModel() -> VotingsViewModel {
        VotingsViewModel(getVotings: getVotings, settings: settingsRepository)
    }

    public func makeVotingDetailViewModel(sitting: Int, votingNumber: Int) -> VotingDetailViewModel {
        VotingDetailViewModel(sitting: sitting, votingNumber: votingNumber, getVotingDetail: getVotingDetail, settings: settingsRepository)
    }

    public func makeBenchmarkViewModel() -> BenchmarkViewModel {
        BenchmarkViewModel(metrics: metricRepository, settings: settingsRepository, exporter: benchmarkExporter)
    }
}
