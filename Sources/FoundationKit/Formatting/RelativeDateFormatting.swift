import Foundation

public protocol RelativeDateFormatting: Sendable {
    func localizedString(for date: Date, relativeTo referenceDate: Date) -> String
    func localizedString(fromTimeInterval timeInterval: TimeInterval) -> String
}

public extension RelativeDateFormatting {
    func localizedString(for date: Date) -> String {
        localizedString(for: date, relativeTo: Date())
    }
}
