import Foundation
import XCTest
@testable import FoundationKit

final class FoundationKitTests: XCTestCase {
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

    func testDateFormatterProducesDeterministicOutput() {
        let formatter = DateFormatterFactory.make(
            dateFormat: "yyyy-MM-dd HH:mm",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
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

    func testDateValueFormatterSupportsDirectInitialization() {
        let formatter = DateValueFormatter(
            dateFormat: "dd/MM/yyyy",
            locale: Locale(identifier: "en_GB"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
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
}
