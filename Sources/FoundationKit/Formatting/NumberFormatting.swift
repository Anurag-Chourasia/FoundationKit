import Foundation

public protocol NumberFormatting: Sendable {
    func string(from number: NSNumber) -> String?
}
