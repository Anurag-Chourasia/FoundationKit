import Foundation

public enum NumberFormatterFactory {
    public static func makeDecimal(
        maximumFractionDigits: Int = 2,
        locale: Locale = Locale(identifier: "en_US_POSIX")
    ) -> NumberFormatting {
        DecimalValueFormatter(
            maximumFractionDigits: maximumFractionDigits,
            locale: locale
        )
    }
}

public struct DecimalValueFormatter: NumberFormatting, Sendable {
    private let maximumFractionDigits: Int
    private let localeIdentifier: String

    public init(
        maximumFractionDigits: Int = 2,
        locale: Locale = Locale(identifier: "en_US_POSIX")
    ) {
        self.maximumFractionDigits = maximumFractionDigits
        self.localeIdentifier = locale.identifier
    }

    public func string(from number: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        formatter.secondaryGroupingSize = 3
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: number)
    }
}
