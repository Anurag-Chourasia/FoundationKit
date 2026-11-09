import Foundation

public protocol ByteCountFormatting: Sendable {
    func string(fromByteCount byteCount: Int64) -> String
}

public extension ByteCountFormatting {
    func string(fromByteCount byteCount: Int) -> String {
        string(fromByteCount: Int64(byteCount))
    }
}
