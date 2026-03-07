public struct FeatureFlags: Sendable, Equatable {
    private let values: [String: Bool]

    public init(values: [String: Bool] = [:]) {
        self.values = values
    }

    public subscript(_ key: String) -> Bool {
        values[key] ?? false
    }

    public func isEnabled(_ key: String) -> Bool {
        self[key]
    }

    public func setting(_ key: String, enabled: Bool) -> FeatureFlags {
        var updatedValues = values
        updatedValues[key] = enabled
        return FeatureFlags(values: updatedValues)
    }
}
