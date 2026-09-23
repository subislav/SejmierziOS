import Foundation

public enum MetricCategory: String, Sendable {
    case network = "NETWORK"
    case parsing = "PARSING"
    case db = "DB"
    case useCase = "USECASE"
    case ui = "UI"
    case memory = "MEMORY"
    case cpu = "CPU"
}

public enum MetricTag {
    public static let platform = "platform"
    public static let device = "device"
    public static let osVersion = "osVersion"
    public static let source = "source"
    public static let mode = "mode"
    public static let coldWarm = "coldWarm"
    public static let networkType = "networkType"
    public static let buildType = "buildType"
    public static let endpoint = "endpoint"
    public static let slice = "slice"
    public static let runId = "runId"
    public static let iteration = "iteration"
}

public enum MetricNames {
    public static let uiTtid = "ui.ttid"
    public static let uiTtfd = "ui.ttfd"
    public static let uiJankFrames = "ui.jankFrames"
    public static let uiMainThreadStallCount = "ui.mainThreadStallCount"
    public static let uiMainThreadStallMs = "ui.mainThreadStallTotalMs"
    public static let appColdStart = "app.coldStart"
    public static let cpuAvg = "cpu.avg"
    public static let cpuPeak = "cpu.peak"
    public static let networkTransport = "network.transport"
    public static let parsingDecode = "parsing.decode"
}

public struct Metric: Sendable {
    public let name: String
    public let category: MetricCategory
    public let value: Double
    public let unit: String
    public let timestampMs: Int64
    public let tags: [String: String]

    public init(name: String, category: MetricCategory, value: Double, unit: String, timestampMs: Int64, tags: [String: String] = [:]) {
        self.name = name
        self.category = category
        self.value = value
        self.unit = unit
        self.timestampMs = timestampMs
        self.tags = tags
    }

    public static let unitMs = "ms"
    public static let unitBytes = "bytes"
    public static let unitFrames = "frames"
    public static let unitCount = "count"
    public static let unitPercent = "percent"
}
