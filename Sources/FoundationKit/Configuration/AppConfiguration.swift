import Foundation

public struct AppConfiguration: Sendable, Equatable {
    public let environment: BuildEnvironment
    public let apiBaseURL: URL?
    public let featureFlags: FeatureFlags

    public init(
        environment: BuildEnvironment,
        apiBaseURL: URL? = nil,
        featureFlags: FeatureFlags = FeatureFlags()
    ) {
        self.environment = environment
        self.apiBaseURL = apiBaseURL
        self.featureFlags = featureFlags
    }

    public func isFeatureEnabled(_ key: String) -> Bool {
        featureFlags.isEnabled(key)
    }
}
