import Foundation

public enum DateFormatterFactory {
    public static func make(
        dateFormat: String,
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        timeZone: TimeZone = .gmt,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> DateFormatting {
        DateValueFormatter(
            dateFormat: dateFormat,
            locale: locale,
            timeZone: timeZone,
            calendar: calendar
        )
    }
}

public struct DateValueFormatter: DateFormatting, Sendable {
    private let dateFormat: String
    private let localeIdentifier: String
    private let timeZoneIdentifier: String
    private let calendarIdentifier: Calendar.Identifier

    public init(
        dateFormat: String,
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        timeZone: TimeZone = .gmt,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.dateFormat = dateFormat
        self.localeIdentifier = locale.identifier
        self.timeZoneIdentifier = timeZone.identifier
        self.calendarIdentifier = calendar.identifier
    }

    public func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        formatter.calendar = Calendar(identifier: calendarIdentifier)
        return formatter.string(from: date)
    }
}
