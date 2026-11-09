import Foundation

public enum ByteCountFormatterFactory {
    public static func make(
        countStyle: ByteCountFormatter.CountStyle = .file,
        allowedUnits: ByteCountFormatter.Units = .useAll,
        zeroSizeString: String = "0 KB"
    ) -> ByteCountFormatting {
        ByteCountValueFormatter(
            countStyle: countStyle,
            allowedUnits: allowedUnits,
            zeroSizeString: zeroSizeString
        )
    }
}

public struct ByteCountValueFormatter: ByteCountFormatting, Sendable {
    private let countStyle: ByteCountFormatter.CountStyle
    private let allowedUnits: ByteCountFormatter.Units
    private let zeroSizeString: String

    public init(
        countStyle: ByteCountFormatter.CountStyle = .file,
        allowedUnits: ByteCountFormatter.Units = .useAll,
        zeroSizeString: String = "0 KB"
    ) {
        self.countStyle = countStyle
        self.allowedUnits = allowedUnits
        self.zeroSizeString = zeroSizeString
    }

    public func string(fromByteCount byteCount: Int64) -> String {
        guard byteCount > 0 else { return zeroSizeString }
        let formatter = ByteCountFormatter()
        formatter.countStyle = countStyle
        formatter.allowedUnits = allowedUnits
        return formatter.string(fromByteCount: byteCount)
    }
}
