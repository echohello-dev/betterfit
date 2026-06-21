import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

enum AppTheme: String, CaseIterable, Identifiable {
    case bold
    case classic
    case midnight
    case forest
    case sunset

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bold: return "Bold"
        case .classic: return "Classic"
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .sunset: return "Sunset"
        }
    }

    var accent: Color {
        switch self {
        case .bold: return Color(red: 1.00, green: 0.84, blue: 0.00)
        case .classic: return .blue
        case .midnight: return Color(red: 0.62, green: 0.45, blue: 1.0)
        case .forest: return Color(red: 0.20, green: 0.72, blue: 0.47)
        case .sunset: return Color(red: 1.0, green: 0.45, blue: 0.34)
        }
    }

    var backgroundGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .bold:
            colors = [Color.black, Color(red: 0.06, green: 0.06, blue: 0.06)]
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
        case .bold:
            return .dark
        case .classic:
            return nil
        case .midnight, .forest, .sunset:
            return .dark
        }
    }

    var cardBackground: AnyShapeStyle {
        switch self {
        case .bold:
            return AnyShapeStyle(Color.black.opacity(0.55))
        case .classic:
            return AnyShapeStyle(.thinMaterial)
        case .midnight, .forest, .sunset:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }

    var cardStroke: Color {
        switch self {
        case .bold:
            return accent.opacity(0.35)
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

    static let defaultTheme: AppTheme = .bold

    static func fromStorage(_ rawValue: String?) -> AppTheme {
        guard let rawValue, let theme = AppTheme(rawValue: rawValue) else {
            return defaultTheme
        }
        return theme
    }
}

extension AppTheme {
    static let headingFontCandidates: [String] = [
        "BBHHegarty-ExtraBold",
        "BBHHegarty-Bold",
        "BBH Hegarty",
        "BBHHegarty",
        "BBH-Hegarty",
        "BBHHegarty-Regular",
    ]

    static let italicFontCandidates: [String] = [
        "BBHHegarty-ExtraBoldItalic",
        "BBHHegarty-BoldItalic",
        "BBHHegarty-Italic",
        "BBH Hegarty",
    ]

    func headingFont(size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        #if canImport(UIKit)
            if let resolvedName = AppTheme.headingFontCandidates.first(where: {
                UIFont(name: $0, size: size) != nil
            }) {
                return .custom(resolvedName, size: size, relativeTo: textStyle)
            }
        #endif
        return .system(size: size, weight: .black, design: .rounded)
    }

    func italicFont(size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        #if canImport(UIKit)
            if let resolvedName = AppTheme.italicFontCandidates.first(where: {
                UIFont(name: $0, size: size) != nil
            }) {
                return .custom(resolvedName, size: size, relativeTo: textStyle)
            }
        #endif
        return .system(size: size, weight: .bold, design: .rounded).italic()
    }
}

extension View {
    func bfHeading(theme: AppTheme, size: CGFloat, relativeTo textStyle: Font.TextStyle = .headline)
        -> some View
    {
        font(theme.headingFont(size: size, relativeTo: textStyle))
    }

    func bfItalic(theme: AppTheme, size: CGFloat, relativeTo textStyle: Font.TextStyle = .body)
        -> some View
    {
        font(theme.italicFont(size: size, relativeTo: textStyle))
    }
}
