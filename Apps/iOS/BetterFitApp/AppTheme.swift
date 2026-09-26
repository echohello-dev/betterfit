import BetterFit
import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Appearance Preference

extension AppearancePreference {
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

// MARK: - AppTheme
// Yellow density variants only. No secondary brand hues.

enum AppTheme: String, CaseIterable, Identifiable {
    /// Balanced yellow — default product look.
    case fitbod
    /// More yellow: headers can take the slab.
    case bold
    /// Quieter yellow: accent lives on the docked action only.
    case classic
    /// Legacy storage keys — all resolve to yellow neutrals.
    case midnight
    case forest
    case sunset

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fitbod: return "Balanced"
        case .bold: return "Bold"
        case .classic: return "Restrained"
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .sunset: return "Warm"
        }
    }

    /// Whether this theme spends yellow on full-bleed headers.
    var prefersYellowHeaders: Bool {
        self == .bold
    }

    /// Whether the docked primary action should stay quiet (header took the yellow).
    var quietPrimaryAction: Bool {
        prefersYellowHeaders
    }

    // MARK: Accent (always yellow)

    var accent: Color { BFColors.accent }

    var accentInk: Color { BFColors.accentInk }

    // MARK: Semantic Color Tokens

    func textPrimary(for scheme: ColorScheme) -> Color {
        BFColors.textPrimary(for: scheme)
    }

    func textSecondary(for scheme: ColorScheme) -> Color {
        BFColors.textSecondary(for: scheme)
    }

    func textTertiary(for scheme: ColorScheme) -> Color {
        BFColors.textTertiary(for: scheme)
    }

    func cardBackground(for scheme: ColorScheme) -> Color {
        BFColors.surface(for: scheme)
    }

    func cardStroke(for scheme: ColorScheme) -> Color {
        BFColors.border(for: scheme)
    }

    func backgroundBase(for scheme: ColorScheme) -> Color {
        switch self {
        case .midnight:
            return scheme == .dark
                ? Color(red: 0.05, green: 0.06, blue: 0.10)
                : BFColors.background(for: scheme)
        case .forest:
            return scheme == .dark
                ? Color(red: 0.04, green: 0.09, blue: 0.07)
                : BFColors.background(for: scheme)
        case .sunset:
            return scheme == .dark
                ? Color(red: 0.10, green: 0.06, blue: 0.07)
                : BFColors.background(for: scheme)
        default:
            return BFColors.background(for: scheme)
        }
    }

    func backgroundGradient(for scheme: ColorScheme) -> LinearGradient {
        let flat = backgroundBase(for: scheme)
        return LinearGradient(colors: [flat, flat], startPoint: .top, endPoint: .bottom)
    }

    func accentSurface(_ opacity: Double, for scheme: ColorScheme) -> Color {
        accent.opacity(accentSurfaceOpacity(opacity, isDark: scheme == .dark))
    }

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
    static let defaultTheme: AppTheme = .fitbod

    /// Themes shown in the picker (yellow density + atmosphere).
    static var selectableThemes: [AppTheme] {
        [.fitbod, .bold, .classic, .midnight, .forest, .sunset]
    }

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

    func bfTextPrimary(theme: AppTheme) -> some View {
        modifier(BFTextPrimaryModifier(theme: theme))
    }

    func bfTextSecondary(theme: AppTheme) -> some View {
        modifier(BFTextSecondaryModifier(theme: theme))
    }

    func bfTextTertiary(theme: AppTheme) -> some View {
        modifier(BFTextTertiaryModifier(theme: theme))
    }

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

// MARK: - Helpers

private func accentSurfaceOpacity(_ base: Double, isDark: Bool) -> Double {
    isDark ? base : min(1.0, base * 1.4)
}
