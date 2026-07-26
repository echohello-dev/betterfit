import Foundation

public enum AppearancePreference: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }
}

extension AppearancePreference {
    public static let storageKey = "betterfit.appearancePreference"
    public static let defaultPreference: AppearancePreference = .dark

    public static func fromStorage(_ rawValue: String?) -> AppearancePreference {
        guard let rawValue, let pref = AppearancePreference(rawValue: rawValue) else {
            return defaultPreference
        }
        return pref
    }
}
