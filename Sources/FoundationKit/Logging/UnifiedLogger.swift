import OSLog

/// Production logging uses unified logging and treats all dynamic messages as private.
/// Tests can continue injecting an AppLogger without coupling domain code to OSLog.
public struct UnifiedLogger: AppLogger {
    private let logger: Logger

    public init(subsystem: String, category: String) {
        logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(_ message: String, level: LogLevel) {
        switch level {
        case .debug: logger.debug("\(message, privacy: .private)")
        case .info: logger.info("\(message, privacy: .private)")
        case .warning: logger.warning("\(message, privacy: .private)")
        case .error: logger.error("\(message, privacy: .private)")
        }
    }
}
