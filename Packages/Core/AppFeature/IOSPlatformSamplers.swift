import Foundation
import Domain
import Darwin
import UIKit
import QuartzCore
import Network

public enum ProcessLaunchMark {
    public static let start = DispatchTime.now()

    public static func elapsedMs() -> Double {
        let now = DispatchTime.now().uptimeNanoseconds
        return Double(now - start.uptimeNanoseconds) / 1_000_000.0
    }
}

public struct IOSMemorySampler: MemorySampler {
    public init() {}

    public func usedMemoryBytes() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return kerr == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}

public final class IOSDisplayTracker: DisplayTracker, @unchecked Sendable {
    private let benchmark: Benchmark
    private let startTime = DispatchTime.now().uptimeNanoseconds

    public init(benchmark: Benchmark) {
        self.benchmark = benchmark
    }

    public func reportInitialDisplay(slice: String) {
        let elapsedMs = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000.0
        benchmark.record(
            name: MetricNames.uiTtid,
            category: .ui,
            value: elapsedMs,
            unit: Metric.unitMs,
            tags: [MetricTag.slice: slice]
        )
    }

    public func reportFullDisplay(slice: String) {
        let elapsedMs = Double(DispatchTime.now().uptimeNanoseconds - startTime) / 1_000_000.0
        benchmark.record(
            name: MetricNames.uiTtfd,
            category: .ui,
            value: elapsedMs,
            unit: Metric.unitMs,
            tags: [MetricTag.slice: slice]
        )
    }

    public func reportColdStart(elapsedMs: Double) {
        benchmark.record(
            name: MetricNames.appColdStart,
            category: .ui,
            value: elapsedMs,
            unit: Metric.unitMs,
            tags: [MetricTag.slice: "startup"]
        )
    }
}

public final class IOSFrameMetricsSampler: NSObject, FrameMetricsSampler, @unchecked Sendable {
    private let benchmark: Benchmark
    private var displayLink: CADisplayLink?
    private var jankFrames = 0
    private var totalFrames = 0
    private var stallCount = 0
    private var stallTotalMs = 0.0
    private var lastTimestamp: CFTimeInterval = 0
    private var slice = ""
    private let stallThreshold: CFTimeInterval = 0.016

    public init(benchmark: Benchmark) {
        self.benchmark = benchmark
    }

    public func start(slice: String) {
        stopInternal(record: false)
        self.slice = slice
        jankFrames = 0
        totalFrames = 0
        stallCount = 0
        stallTotalMs = 0.0
        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(onFrame(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    public func stop() {
        stopInternal(record: true)
    }

    private func stopInternal(record: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        guard record else { return }
        let tags = [
            MetricTag.slice: slice,
            "totalFrames": String(totalFrames),
        ]
        benchmark.record(
            name: MetricNames.uiJankFrames,
            category: .ui,
            value: Double(jankFrames),
            unit: Metric.unitFrames,
            tags: tags
        )
        benchmark.record(
            name: MetricNames.uiMainThreadStallCount,
            category: .ui,
            value: Double(stallCount),
            unit: Metric.unitCount,
            tags: tags
        )
        benchmark.record(
            name: MetricNames.uiMainThreadStallMs,
            category: .ui,
            value: stallTotalMs,
            unit: Metric.unitMs,
            tags: tags
        )
    }

    @objc private func onFrame(_ link: CADisplayLink) {
        totalFrames += 1
        if lastTimestamp > 0 {
            let delta = link.timestamp - lastTimestamp
            if delta > stallThreshold {
                jankFrames += 1
                stallCount += 1
                stallTotalMs += delta * 1000.0
            }
        }
        lastTimestamp = link.timestamp
    }
}

public final class IOSCpuSampler: CpuSampler, @unchecked Sendable {
    private let benchmark: Benchmark
    private var slice = ""
    private var wallStartNs: UInt64 = 0
    private var cpuStartMs: Double = 0
    private var peakPercent = 0.0
    private var timer: DispatchSourceTimer?
    private var lastWallNs: UInt64 = 0
    private var lastCpuMs: Double = 0
    private var active = false

    public init(benchmark: Benchmark) {
        self.benchmark = benchmark
    }

    public func start(slice: String) {
        stopInternal(record: false)
        self.slice = slice
        wallStartNs = DispatchTime.now().uptimeNanoseconds
        cpuStartMs = currentCpuTimeMs()
        lastWallNs = wallStartNs
        lastCpuMs = cpuStartMs
        peakPercent = 0
        active = true
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + .milliseconds(50), repeating: .milliseconds(50))
        t.setEventHandler { [weak self] in
            self?.samplePeak()
        }
        t.resume()
        timer = t
    }

    public func stop() {
        stopInternal(record: true)
    }

    private func stopInternal(record: Bool) {
        timer?.cancel()
        timer = nil
        guard active else { return }
        active = false
        guard record else { return }
        let wallDeltaMs = Double(DispatchTime.now().uptimeNanoseconds - wallStartNs) / 1_000_000.0
        let cpuDeltaMs = max(0, currentCpuTimeMs() - cpuStartMs)
        let avg = wallDeltaMs > 0 ? (cpuDeltaMs / wallDeltaMs) * 100.0 : 0
        if avg > peakPercent { peakPercent = avg }
        let tags = [MetricTag.slice: slice]
        benchmark.record(name: MetricNames.cpuAvg, category: .cpu, value: avg, unit: Metric.unitPercent, tags: tags)
        benchmark.record(name: MetricNames.cpuPeak, category: .cpu, value: peakPercent, unit: Metric.unitPercent, tags: tags)
    }

    private func samplePeak() {
        let wallNow = DispatchTime.now().uptimeNanoseconds
        let cpuNow = currentCpuTimeMs()
        let wallDeltaMs = Double(wallNow - lastWallNs) / 1_000_000.0
        let cpuDeltaMs = max(0, cpuNow - lastCpuMs)
        if wallDeltaMs > 0 {
            let instant = (cpuDeltaMs / wallDeltaMs) * 100.0
            if instant > peakPercent { peakPercent = instant }
        }
        lastWallNs = wallNow
        lastCpuMs = cpuNow
    }

    private func currentCpuTimeMs() -> Double {
        var info = task_thread_times_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_thread_times_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_THREAD_TIMES_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        let user = Double(info.user_time.seconds) * 1000.0 + Double(info.user_time.microseconds) / 1000.0
        let system = Double(info.system_time.seconds) * 1000.0 + Double(info.system_time.microseconds) / 1000.0
        return user + system
    }
}

public struct IOSBenchmarkExporter: BenchmarkExporter {
    public init() {}

    public func export(fileName: String, content: String) async throws -> String {
        let docsUrl = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = docsUrl.appendingPathComponent("benchmark-exports", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileUrl = dir.appendingPathComponent(fileName)
        try content.write(to: fileUrl, atomically: true, encoding: .utf8)
        return fileUrl.path
    }
}

public final class IOSRunContextProvider: RunContextProvider, @unchecked Sendable {
    private let runId = String(UUID().uuidString.prefix(8))
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "sejmierz.network")
    private var currentNetwork = "UNKNOWN"
    private let deviceModel: String
    private let buildType: String

    public init() {
        #if targetEnvironment(simulator)
        deviceModel = "Simulator"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        deviceModel = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif

        #if DEBUG
        buildType = "debug"
        #else
        buildType = "release"
        #endif

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status != .satisfied {
                self.currentNetwork = "NONE"
            } else if path.usesInterfaceType(.wifi) {
                self.currentNetwork = "WIFI"
            } else if path.usesInterfaceType(.cellular) {
                self.currentNetwork = "CELLULAR"
            } else if path.usesInterfaceType(.wiredEthernet) {
                self.currentNetwork = "ETHERNET"
            } else {
                self.currentNetwork = "OTHER"
            }
        }
        monitor.start(queue: queue)
    }

    public func globalTags() -> [String: String] {
        [
            MetricTag.platform: "Native-iOS",
            MetricTag.device: deviceModel,
            MetricTag.osVersion: "iOS \(UIDevice.current.systemVersion)",
            MetricTag.buildType: buildType,
            MetricTag.networkType: currentNetwork,
            MetricTag.runId: runId,
        ]
    }

    deinit {
        monitor.cancel()
    }
}
