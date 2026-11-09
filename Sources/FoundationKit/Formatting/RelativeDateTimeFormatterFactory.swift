import Foundation

public enum RelativeDateTimeFormatterFactory {
    public static func make(
        dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .numeric,
        unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full,
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> RelativeDateFormatting {
        RelativeDateTimeValueFormatter(
            dateTimeStyle: dateTimeStyle,
            unitsStyle: unitsStyle,
            locale: locale,
            calendar: calendar
        )
    }
}

public struct RelativeDateTimeValueFormatter: RelativeDateFormatting, Sendable {
    private let dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle
    private let unitsStyle: RelativeDateTimeFormatter.UnitsStyle
    private let localeIdentifier: String
    private let calendarIdentifier: Calendar.Identifier

    public init(
        dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .numeric,
        unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full,
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.dateTimeStyle = dateTimeStyle
        self.unitsStyle = unitsStyle
        self.localeIdentifier = locale.identifier
        self.calendarIdentifier = calendar.identifier
    }

    public func localizedString(for date: Date, relativeTo referenceDate: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = dateTimeStyle
        formatter.unitsStyle = unitsStyle
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.calendar = Calendar(identifier: calendarIdentifier)
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }

    public func localizedString(fromTimeInterval timeInterval: TimeInterval) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = dateTimeStyle
        formatter.unitsStyle = unitsStyle
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.calendar = Calendar(identifier: calendarIdentifier)
        return formatter.localizedString(fromTimeInterval: timeInterval)
    }
}
