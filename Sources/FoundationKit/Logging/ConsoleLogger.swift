import Foundation

public struct ConsoleLogger: AppLogger {
    private let subsystem: String
    private let category: String
    private let dateProvider: @Sendable () -> Date

    public init(
        subsystem: String = "FoundationKit",
        category: String = "General",
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.subsystem = subsystem
        self.category = category
        self.dateProvider = dateProvider
    }

    public func log(_ message: String, level: LogLevel) {
        let timestamp = ISO8601DateFormatter().string(from: dateProvider())
        print("[\(timestamp)] [\(subsystem)] [\(category)] [\(level.rawValue.uppercased())] \(message)")
    }
}
