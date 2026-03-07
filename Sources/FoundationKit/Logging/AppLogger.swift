public protocol AppLogger: Sendable {
    func log(_ message: String, level: LogLevel)
}
