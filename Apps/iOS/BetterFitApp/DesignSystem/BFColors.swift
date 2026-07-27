import SwiftUI

// MARK: - BF Color Tokens

/// Flat, dark-first color system. All colors resolve against the color scheme.
/// Accent stays theme-driven (AppTheme.accent); everything else is semantic.
enum BFColors {

    // MARK: Page Backgrounds

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.043, green: 0.043, blue: 0.051)  // #0B0B0D
            : Color(red: 0.965, green: 0.965, blue: 0.973)  // #F6F6F8
    }

    static func backgroundElevated(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.075, green: 0.075, blue: 0.086)  // #131316
            : Color.white
    }

    // MARK: Surfaces

    /// Card / list-row fill.
    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.090, green: 0.090, blue: 0.106)  // #17171B
            : Color.white
    }

    /// Pressed/hover state, inset wells, segmented controls.
    static func surfaceRaised(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.122, green: 0.122, blue: 0.145)  // #1F1F25
            : Color(red: 0.937, green: 0.937, blue: 0.953)  // #EFEFF3
    }

    // MARK: Strokes

    static func border(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.07)
            : Color.black.opacity(0.08)
    }

    static func separator(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.06)
            : Color.black.opacity(0.06)
    }

    // MARK: Text

    static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white
            : Color(red: 0.075, green: 0.075, blue: 0.090)  // #131317
    }

    static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.612, green: 0.612, blue: 0.651)  // #9C9CA6
            : Color(red: 0.380, green: 0.380, blue: 0.420)
    }

    static func textTertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.388, green: 0.388, blue: 0.427)  // #63636D
            : Color(red: 0.580, green: 0.580, blue: 0.620)
    }

    // MARK: Brand / Semantic

    /// Fitbod-style ember orange. Used by the `.fitbod` AppTheme accent;
    /// exposed here for places that need a fixed brand color.
    static let brandAccent = Color(red: 1.0, green: 0.353, blue: 0.235)  // #FF5A3C

    /// Identity yellow. Reserved for brand moments only (logo, launch, achievements).
    /// Per design spec, never use as a default product surface or action colour.
    static let identity = Color(red: 1.0, green: 0.839, blue: 0.039)  // #FFD60A

    /// Foreground paired with `identity`. The spec mandates black content on large
    /// yellow fields; this colour is the canonical ink.
    static let identityInk = Color.black

    /// Tinted surface that signals an identity moment on the dark canvas without
    /// committing to a full yellow field.
    static let identitySurface = Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.16)

    static let success = Color(red: 0.290, green: 0.871, blue: 0.502)    // #4ADE80
    static let warning = Color(red: 0.961, green: 0.722, blue: 0.239)    // #F5B83D
    static let danger = Color(red: 0.941, green: 0.267, blue: 0.220)     // #F04438
    static let info = Color(red: 0.180, green: 0.565, blue: 0.980)       // #2E90FA

    // MARK: Recovery Scale

    /// Muscle recovery colors — recovered (blue) → sore (red).
    static func recoveryColor(for status: RecoveryStatusLike) -> Color {
        switch status {
        case .recovered: return info
        case .slightlyFatigued: return success
        case .fatigued: return warning
        case .sore: return danger
        }
    }
}

// MARK: - RecoveryStatusLike

/// DS-local mirror so tokens compile without importing BetterFit into every file.
/// Map `RecoveryStatus` → this at call sites via `RecoveryStatusLike(status)`.
enum RecoveryStatusLike {
    case recovered
    case slightlyFatigued
    case fatigued
    case sore
}

// MARK: - ColorScheme helpers

extension ColorScheme {
    var isDark: Bool { self == .dark }
}
