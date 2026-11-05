import Foundation

public protocol AppClock: Sendable {
    var now: Date { get }
}

public struct SystemClock: AppClock {
    public init() {}

    public var now: Date {
        Date()
    }
}

public struct FixedClock: AppClock {
    public let now: Date

    public init(now: Date) {
        self.now = now
    }
}

/// Adapts a native monotonic clock to the wall-date contract used for cache timestamps.
/// The anchor is captured once: later wall-clock adjustments cannot reorder elapsed time.
public struct NativeClockAdapter<C: Swift.Clock>: AppClock where C.Duration == Duration {
    public let clock: C
    private let anchor: C.Instant
    private let anchorDate: Date

    public init(clock: C, anchorDate: Date = Date()) {
        self.clock = clock
        self.anchor = clock.now
        self.anchorDate = anchorDate
    }

    public var now: Date {
        let elapsed = anchor.duration(to: clock.now).components
        return anchorDate.addingTimeInterval(Double(elapsed.seconds) + Double(elapsed.attoseconds) / 1e18)
    }

    public func sleep(for duration: Duration, tolerance: Duration? = nil) async throws {
        try await clock.sleep(until: clock.now.advanced(by: duration), tolerance: tolerance)
    }
}
