import Foundation
import XCTest
@testable import FoundationKit

final class FoundationKitTests: XCTestCase {
    func testNativeClockAdapterTracksInjectedMonotonicTime() {
        let native = AdjustableNativeClock()
        let anchor = Date(timeIntervalSince1970: 1_000)
        let clock = NativeClockAdapter(clock: native, anchorDate: anchor)
        XCTAssertEqual(clock.now, anchor)
        native.advance(by: .milliseconds(2_500))
        XCTAssertEqual(clock.now.timeIntervalSince(anchor), 2.5, accuracy: 0.000_001)
    }

    func testNativeClockAdapterSleepHonorsCancellation() async {
        let clock = NativeClockAdapter(clock: ContinuousClock())
        let task = Task { try await clock.sleep(for: .seconds(3_600)) }
        task.cancel()
        do { try await task.value; XCTFail("Expected cancellation") } catch is CancellationError { } catch { XCTFail("Unexpected error: \(error)") }
    }

    func testBuildEnvironmentExposesAllExpectedCasesAndRawValues() {
        XCTAssertEqual(BuildEnvironment.allCases, [.debug, .staging, .release])
        XCTAssertEqual(BuildEnvironment.debug.rawValue, "debug")
        XCTAssertEqual(BuildEnvironment.staging.rawValue, "staging")
        XCTAssertEqual(BuildEnvironment.release.rawValue, "release")
    }

    func testConsoleLoggerAcceptsAllLogLevelsWithoutCrashing() {
        let logger = ConsoleLogger(
            subsystem: "Tests",
            category: "Logging",
            dateProvider: { Date(timeIntervalSince1970: 0) }
        )

        for level in LogLevel.allCases {
            logger.log("message", level: level)
        }
    }

    func testConsoleLoggerSupportsDefaultInitializer() {
        let logger = ConsoleLogger()

        logger.log("default init", level: .info)
    }

    func testUnifiedLoggerAcceptsAllLogLevelsWithoutCrashing() {
        let logger = UnifiedLogger(subsystem: "Tests", category: "Logging")

        for level in LogLevel.allCases {
            logger.log("test unified message", level: level)
        }
    }

    func testDateFormatterProducesDeterministicOutput() throws {
        let timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let formatter = DateFormatterFactory.make(
            dateFormat: "yyyy-MM-dd HH:mm",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timeZone,
            calendar: Calendar(identifier: .gregorian)
        )

        let output = formatter.string(from: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(output, "1970-01-01 00:00")
    }

    func testDateFormatterFactoryAndFormatterSupportDefaultArguments() {
        let factoryFormatter = DateFormatterFactory.make(dateFormat: "yyyy-MM-dd")
        let directFormatter = DateValueFormatter(dateFormat: "yyyy-MM-dd")
        let date = Date(timeIntervalSince1970: 0)

        XCTAssertEqual(factoryFormatter.string(from: date), "1970-01-01")
        XCTAssertEqual(directFormatter.string(from: date), "1970-01-01")
    }

    func testDateValueFormatterSupportsDirectInitialization() throws {
        let timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let formatter = DateValueFormatter(
            dateFormat: "dd/MM/yyyy",
            locale: Locale(identifier: "en_GB"),
            timeZone: timeZone,
            calendar: Calendar(identifier: .gregorian)
        )

        let output = formatter.string(from: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(output, "01/01/1970")
    }

    func testNumberFormatterProducesDeterministicOutput() {
        let formatter = NumberFormatterFactory.makeDecimal(
            maximumFractionDigits: 2,
            locale: Locale(identifier: "en_US_POSIX")
        )

        let output = formatter.string(from: 1234.567 as NSNumber)

        XCTAssertEqual(output, "1,234.57")
    }

    func testDecimalValueFormatterSupportsDirectInitialization() {
        let formatter = DecimalValueFormatter(
            maximumFractionDigits: 0,
            locale: Locale(identifier: "en_US")
        )

        let output = formatter.string(from: 1234.567 as NSNumber)

        XCTAssertEqual(output, "1,235")
    }

    func testAppConfigurationPreservesEnvironmentAndFeatureFlagState() {
        let flags = FeatureFlags()
            .setting("offline_cache", enabled: true)
            .setting("new_search_ui", enabled: false)
        let configuration = AppConfiguration(
            environment: .staging,
            apiBaseURL: URL(string: "https://example.com"),
            featureFlags: flags
        )

        XCTAssertEqual(configuration.environment, .staging)
        XCTAssertEqual(configuration.apiBaseURL?.absoluteString, "https://example.com")
        XCTAssertTrue(configuration.isFeatureEnabled("offline_cache"))
        XCTAssertFalse(configuration.isFeatureEnabled("new_search_ui"))
        XCTAssertFalse(configuration.isFeatureEnabled("missing_flag"))
    }

    func testAppConfigurationUsesDefaultValues() {
        let configuration = AppConfiguration(environment: .debug)

        XCTAssertEqual(configuration.environment, .debug)
        XCTAssertNil(configuration.apiBaseURL)
        XCTAssertFalse(configuration.isFeatureEnabled("missing_flag"))
    }

    func testFeatureFlagsCanBeInitializedWithValuesAndQueriedBySubscript() {
        let flags = FeatureFlags(values: [
            "feature_a": true,
            "feature_b": false
        ])

        XCTAssertTrue(flags["feature_a"])
        XCTAssertFalse(flags["feature_b"])
        XCTAssertFalse(flags["missing_feature"])
    }

    func testStringFormattingTrimsAndJoinsOnlyNonEmptyValues() {
        let output = StringFormatting.joinedNonEmpty(
            ["  Hello", "", "World  ", "   "],
            separator: ", "
        )

        XCTAssertEqual(output, "Hello, World")
    }

    func testStringFormattingTrimmedRemovesWhitespaceAndNewlines() {
        XCTAssertEqual(StringFormatting.trimmed(" \n value \t "), "value")
    }

    func testFixedClockReturnsInjectedDate() {
        let expectedDate = Date(timeIntervalSince1970: 123)
        let clock = FixedClock(now: expectedDate)

        XCTAssertEqual(clock.now, expectedDate)
    }

    func testSystemClockReturnsCurrentDate() {
        let before = Date()
        let now = SystemClock().now
        let after = Date()

        XCTAssertGreaterThanOrEqual(now, before)
        XCTAssertLessThanOrEqual(now, after)
    }

    @MainActor
    func testMainQueueDispatcherExecutesWorkOnMainQueue() {
        let expectation = expectation(description: "Main queue work executed")
        let dispatcher = MainQueueDispatcher()

        dispatcher.async {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testByteCountFormatterProducesDeterministicOutputForZeroOrNegativeBytes() {
        let formatter = ByteCountFormatterFactory.make()

        XCTAssertEqual(formatter.string(fromByteCount: 0), "0 KB")
        XCTAssertEqual(formatter.string(fromByteCount: -1), "0 KB")
        XCTAssertEqual(formatter.string(fromByteCount: Int(0)), "0 KB")
    }

    func testByteCountFormatterProducesFormattedOutputForPositiveBytes() {
        let formatter = ByteCountFormatterFactory.make()

        let formatted1KB = formatter.string(fromByteCount: 1_024)
        XCTAssertTrue(formatted1KB.contains("1") && formatted1KB.contains("B"))

        let formatted1MB = formatter.string(fromByteCount: 1_048_576)
        XCTAssertTrue(formatted1MB.contains("1") && formatted1MB.contains("B"))
    }

    func testByteCountFormatterSupportsCustomZeroStringAndOptions() {
        let formatter = ByteCountFormatterFactory.make(
            countStyle: .memory,
            allowedUnits: [.useMB, .useGB],
            zeroSizeString: "Zero Bytes"
        )

        XCTAssertEqual(formatter.string(fromByteCount: 0), "Zero Bytes")
        XCTAssertEqual(formatter.string(fromByteCount: -50), "Zero Bytes")
    }

    func testByteCountValueFormatterSupportsDirectInitialization() {
        let formatter = ByteCountValueFormatter(
            countStyle: .file,
            allowedUnits: .useAll,
            zeroSizeString: "Empty"
        )

        XCTAssertEqual(formatter.string(fromByteCount: 0), "Empty")
        XCTAssertFalse(formatter.string(fromByteCount: 2_048).isEmpty)
    }

    func testRelativeDateTimeFormatterProducesExpectedOutputForPastAndFutureDates() {
        let formatter = RelativeDateTimeFormatterFactory.make(
            dateTimeStyle: .numeric,
            unitsStyle: .full,
            locale: Locale(identifier: "en_US_POSIX")
        )

        let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
        let oneHourAgo = referenceDate.addingTimeInterval(-3_600)
        let inOneDay = referenceDate.addingTimeInterval(86_400)

        let pastString = formatter.localizedString(for: oneHourAgo, relativeTo: referenceDate)
        XCTAssertTrue(pastString.contains("hour") && pastString.contains("ago"))

        let futureString = formatter.localizedString(for: inOneDay, relativeTo: referenceDate)
        XCTAssertTrue(futureString.contains("in") && futureString.contains("day"))
    }

    func testRelativeDateTimeFormatterProducesExpectedOutputFromTimeInterval() {
        let formatter = RelativeDateTimeFormatterFactory.make(
            dateTimeStyle: .numeric,
            unitsStyle: .short,
            locale: Locale(identifier: "en_US_POSIX")
        )

        let result = formatter.localizedString(fromTimeInterval: -120)
        XCTAssertFalse(result.isEmpty)
    }

    func testDateFormatterFactoryMakeRelativeProducesFunctionalFormatter() {
        let formatter = DateFormatterFactory.makeRelative()
        let ref = Date()
        let past = ref.addingTimeInterval(-60)

        let result = formatter.localizedString(for: past, relativeTo: ref)
        XCTAssertFalse(result.isEmpty)
    }

    func testRelativeDateTimeValueFormatterSupportsDirectInitialization() {
        let formatter = RelativeDateTimeValueFormatter(
            dateTimeStyle: .named,
            unitsStyle: .abbreviated,
            locale: Locale(identifier: "en_US"),
            calendar: Calendar(identifier: .gregorian)
        )

        let now = Date()
        let yesterday = now.addingTimeInterval(-86_400)
        XCTAssertFalse(formatter.localizedString(for: yesterday, relativeTo: now).isEmpty)
        XCTAssertFalse(formatter.localizedString(for: now).isEmpty)
    }
}

private final class AdjustableNativeClock: Clock, @unchecked Sendable {
    typealias Instant = ContinuousClock.Instant
    typealias Duration = Swift.Duration
    private let lock = NSLock()
    private var instant = ContinuousClock.now
    var now: Instant { lock.withLock { instant } }
    var minimumResolution: Duration { .nanoseconds(1) }
    func advance(by duration: Duration) { lock.withLock { instant = instant.advanced(by: duration) } }
    func sleep(until deadline: Instant, tolerance: Duration?) async throws { try Task.checkCancellation() }
}
