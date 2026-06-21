import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Appearance Preference

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var resolvedColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension AppearancePreference {
    static let storageKey = "betterfit.appearancePreference"
    static let defaultPreference: AppearancePreference = .dark

    static func fromStorage(_ rawValue: String?) -> AppearancePreference {
        guard let rawValue, let pref = AppearancePreference(rawValue: rawValue) else {
            return defaultPreference
        }
        return pref
    }
}

// MARK: - AppTheme

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

    // MARK: Accent (same in light + dark)

    var accent: Color {
        switch self {
        case .bold: return Color(red: 1.00, green: 0.84, blue: 0.00)
        case .classic: return Color(red: 0.0, green: 0.48, blue: 1.00)
        case .midnight: return Color(red: 0.62, green: 0.45, blue: 1.0)
        case .forest: return Color(red: 0.20, green: 0.78, blue: 0.47)
        case .sunset: return Color(red: 1.0, green: 0.45, blue: 0.34)
        }
    }

    // MARK: Semantic Color Tokens (light + dark)

    /// Primary text — strongest contrast against the background.
    func textPrimary(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? .white
                : Color(red: 0.08, green: 0.08, blue: 0.08)
        case .classic:
            return scheme == .dark
                ? .white
                : Color(red: 0.07, green: 0.07, blue: 0.07)
        case .midnight:
            return scheme == .dark
                ? .white
                : Color(red: 0.10, green: 0.10, blue: 0.20)
        case .forest:
            return scheme == .dark
                ? .white
                : Color(red: 0.05, green: 0.15, blue: 0.10)
        case .sunset:
            return scheme == .dark
                ? .white
                : Color(red: 0.18, green: 0.10, blue: 0.08)
        }
    }

    /// Secondary text — labels, captions, supporting copy.
    /// Uses a hand-picked contrast pair (not SwiftUI's .secondary) to guarantee readability.
    func textSecondary(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? Color(white: 0.78)
                : Color(red: 0.32, green: 0.32, blue: 0.32)
        case .classic:
            return scheme == .dark
                ? Color(white: 0.75)
                : Color(red: 0.30, green: 0.30, blue: 0.30)
        case .midnight:
            return scheme == .dark
                ? Color(white: 0.80)
                : Color(red: 0.32, green: 0.32, blue: 0.42)
        case .forest:
            return scheme == .dark
                ? Color(white: 0.78)
                : Color(red: 0.25, green: 0.38, blue: 0.30)
        case .sunset:
            return scheme == .dark
                ? Color(white: 0.80)
                : Color(red: 0.42, green: 0.30, blue: 0.28)
        }
    }

    /// Tertiary text — hints, placeholders, dimmed metadata.
    func textTertiary(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? Color(white: 0.60)
                : Color(red: 0.50, green: 0.50, blue: 0.50)
        case .classic:
            return scheme == .dark
                ? Color(white: 0.58)
                : Color(red: 0.48, green: 0.48, blue: 0.48)
        case .midnight:
            return scheme == .dark
                ? Color(white: 0.62)
                : Color(red: 0.50, green: 0.50, blue: 0.60)
        case .forest:
            return scheme == .dark
                ? Color(white: 0.60)
                : Color(red: 0.45, green: 0.55, blue: 0.48)
        case .sunset:
            return scheme == .dark
                ? Color(white: 0.62)
                : Color(red: 0.55, green: 0.45, blue: 0.42)
        }
    }

    /// Surface/card background fill (semi-transparent so gradient bleeds through).
    /// Returns a `Color` (not `ShapeStyle`) so call sites can chain `.opacity()`.
    func cardBackground(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? Color.white.opacity(0.06)
                : Color.white.opacity(0.45)
        case .classic:
            return scheme == .dark
                ? Color.white.opacity(0.05)
                : Color.white.opacity(0.55)
        case .midnight, .forest, .sunset:
            return scheme == .dark
                ? Color.white.opacity(0.06)
                : Color.white.opacity(0.55)
        }
    }

    /// Card border / divider line.
    func cardStroke(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.10)
        case .classic:
            return scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.08)
        case .midnight:
            return scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.10)
        case .forest:
            return scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.10)
        case .sunset:
            return scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.10)
        }
    }

    /// Solid background (used as the base under gradients in some places).
    func backgroundBase(for scheme: ColorScheme) -> Color {
        switch self {
        case .bold:
            return scheme == .dark
                ? Color(red: 0.04, green: 0.04, blue: 0.04)
                : Color(red: 0.96, green: 0.96, blue: 0.94)
        case .classic:
            return scheme == .dark
                ? Color.black
                : Color(red: 0.98, green: 0.98, blue: 1.00)
        case .midnight:
            return scheme == .dark
                ? Color(red: 0.05, green: 0.06, blue: 0.10)
                : Color(red: 0.94, green: 0.94, blue: 0.98)
        case .forest:
            return scheme == .dark
                ? Color(red: 0.04, green: 0.09, blue: 0.07)
                : Color(red: 0.94, green: 0.97, blue: 0.94)
        case .sunset:
            return scheme == .dark
                ? Color(red: 0.10, green: 0.06, blue: 0.07)
                : Color(red: 0.98, green: 0.94, blue: 0.92)
        }
    }

    /// Page-level background gradient (resolved against the current color scheme).
    func backgroundGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors: [Color]
        switch self {
        case .bold:
            if scheme == .dark {
                colors = [Color.black, Color(red: 0.06, green: 0.06, blue: 0.06)]
            } else {
                // Neutral warm white with a hint of yellow — keeps the Bold feel without overpowering text.
                colors = [
                    Color(red: 0.97, green: 0.96, blue: 0.93),
                    Color(red: 0.94, green: 0.93, blue: 0.89),
                ]
            }
        case .classic:
            if scheme == .dark {
                colors = [Color(red: 0.07, green: 0.07, blue: 0.08), Color(red: 0.13, green: 0.13, blue: 0.15)]
            } else {
                colors = [Color(red: 0.98, green: 0.98, blue: 1.00), Color(red: 0.93, green: 0.95, blue: 0.99)]
            }
        case .midnight:
            if scheme == .dark {
                colors = [
                    Color(red: 0.05, green: 0.06, blue: 0.10),
                    Color(red: 0.10, green: 0.07, blue: 0.18),
                ]
            } else {
                colors = [
                    Color(red: 0.95, green: 0.95, blue: 1.00),
                    Color(red: 0.90, green: 0.88, blue: 0.98),
                ]
            }
        case .forest:
            if scheme == .dark {
                colors = [
                    Color(red: 0.04, green: 0.09, blue: 0.07),
                    Color(red: 0.06, green: 0.13, blue: 0.09),
                ]
            } else {
                colors = [
                    Color(red: 0.94, green: 0.98, blue: 0.94),
                    Color(red: 0.85, green: 0.94, blue: 0.86),
                ]
            }
        case .sunset:
            if scheme == .dark {
                colors = [
                    Color(red: 0.10, green: 0.06, blue: 0.07),
                    Color(red: 0.16, green: 0.08, blue: 0.08),
                ]
            } else {
                colors = [
                    Color(red: 0.99, green: 0.95, blue: 0.92),
                    Color(red: 0.98, green: 0.88, blue: 0.84),
                ]
            }
        }
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Accent color tinted for use as a soft surface fill.
    /// In light mode the opacity is boosted so the tint reads against the bright background.
    func accentSurface(_ opacity: Double, for scheme: ColorScheme) -> Color {
        let resolved = scheme == .dark ? opacity : min(0.85, opacity * 1.8 + 0.08)
        return accent.opacity(resolved)
    }

    /// Shadow
    func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.black.opacity(0.30)
            : Color.black.opacity(0.12)
    }

    func shadowRadius(for scheme: ColorScheme) -> CGFloat {
        scheme == .dark ? 14 : 10
    }
}

// MARK: - Storage

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

// MARK: - Typography

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

// MARK: - View Modifiers

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

    /// Primary text color (strongest contrast against the background).
    func bfTextPrimary(theme: AppTheme) -> some View {
        modifier(BFTextPrimaryModifier(theme: theme))
    }

    /// Secondary text color (labels, captions).
    func bfTextSecondary(theme: AppTheme) -> some View {
        modifier(BFTextSecondaryModifier(theme: theme))
    }

    /// Tertiary text color (hints, placeholders).
    func bfTextTertiary(theme: AppTheme) -> some View {
        modifier(BFTextTertiaryModifier(theme: theme))
    }

    /// Page-level background that resolves the theme gradient against the current color scheme.
    func bfBackground(theme: AppTheme) -> some View {
        modifier(BFBackgroundModifier(theme: theme))
    }
}

private struct BFTextPrimaryModifier: ViewModifier {
    let theme: AppTheme
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.textPrimary(for: scheme))
    }
}

private struct BFTextSecondaryModifier: ViewModifier {
    let theme: AppTheme
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.textSecondary(for: scheme))
    }
}

private struct BFTextTertiaryModifier: ViewModifier {
    let theme: AppTheme
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.textTertiary(for: scheme))
    }
}

private struct BFBackgroundModifier: ViewModifier {
    let theme: AppTheme
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.background(theme.backgroundGradient(for: scheme).ignoresSafeArea())
    }
}
