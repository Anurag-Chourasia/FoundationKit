import Foundation

public protocol DateFormatting: Sendable {
    func string(from date: Date) -> String
}
