import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case classic
    case midnight
    case forest
    case sunset

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .sunset: return "Sunset"
        }
    }

    var accent: Color {
        switch self {
        case .classic: return .blue
        case .midnight: return Color(red: 0.62, green: 0.45, blue: 1.0)
        case .forest: return Color(red: 0.20, green: 0.72, blue: 0.47)
        case .sunset: return Color(red: 1.0, green: 0.45, blue: 0.34)
        }
    }

    var backgroundGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .classic:
            colors = [Color(.systemBackground), Color(.secondarySystemBackground)]
        case .midnight:
            colors = [
                Color(red: 0.05, green: 0.06, blue: 0.10),
                Color(red: 0.10, green: 0.07, blue: 0.18),
            ]
        case .forest:
            colors = [
                Color(red: 0.04, green: 0.09, blue: 0.07),
                Color(red: 0.06, green: 0.13, blue: 0.09),
            ]
        case .sunset:
            colors = [
                Color(red: 0.10, green: 0.06, blue: 0.07),
                Color(red: 0.16, green: 0.08, blue: 0.08),
            ]
        }

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .classic:
            return nil
        case .midnight, .forest, .sunset:
            return .dark
        }
    }

    var cardBackground: AnyShapeStyle {
        switch self {
        case .classic:
            return AnyShapeStyle(.thinMaterial)
        case .midnight, .forest, .sunset:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }

    var cardStroke: Color {
        switch self {
        case .classic:
            return Color(.separator).opacity(0.35)
        case .midnight:
            return Color.white.opacity(0.10)
        case .forest:
            return Color.white.opacity(0.10)
        case .sunset:
            return Color.white.opacity(0.10)
        }
    }
}

extension AppTheme {
    static let storageKey = "betterfit.appTheme"

    static func fromStorage(_ rawValue: String?) -> AppTheme {
        guard let rawValue, let theme = AppTheme(rawValue: rawValue) else {
            return .classic
        }
        return theme
    }
}
