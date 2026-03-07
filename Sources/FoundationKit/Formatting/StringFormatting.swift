public enum StringFormatting {
    public static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func joinedNonEmpty(_ values: [String], separator: String = " ") -> String {
        values
            .map(trimmed)
            .filter { !$0.isEmpty }
            .joined(separator: separator)
    }
}
