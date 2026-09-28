import SwiftUI

// MARK: - BF Color Tokens

/// Two-colour system: electric yellow and black. Neutrals carry structure;
/// yellow is the single accent. Status meaning rides a yellow ladder plus words.
enum BFColors {

    // MARK: Identity

    /// BetterFit yellow — the only chromatic accent.
    static let identity = Color(red: 1.0, green: 0.839, blue: 0.039)  // #FFD60A
    static let identityInk = Color.black
    static let identitySurface = Color(red: 1.0, green: 0.839, blue: 0.039).opacity(0.15)

    /// Product accent alias. Always yellow with black ink.
    static let accent = identity
    static let accentInk = identityInk
    static let accentSurface = identitySurface

    /// Deprecated alias — kept so call sites compile. Points at yellow.
    static let brandAccent = accent

    // MARK: Yellow ladder (status / recovery brightness)

    static let yellowBright = Color(red: 1.0, green: 0.910, blue: 0.376)   // #FFE860
    static let yellowDeep = Color(red: 0.788, green: 0.659, blue: 0.0)      // #C9A800
    static let yellowDim = Color(red: 0.478, green: 0.400, blue: 0.0)       // #7A6600

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

    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.090, green: 0.090, blue: 0.106)  // #17171B
            : Color.white
    }

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

    static func borderStrong(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.14)
            : Color.black.opacity(0.16)
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
            : Color(red: 0.380, green: 0.380, blue: 0.420)  // #61616B
    }

    static func textTertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.388, green: 0.388, blue: 0.427)  // #63636D
            : Color(red: 0.580, green: 0.580, blue: 0.620)  // #94949E
    }

    /// Yellow used as *text/icon* colour. On light fields use the deep step for AA.
    static func accentText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? identity : Color(red: 0.541, green: 0.443, blue: 0.0)  // #8A7100
    }

    // MARK: Glass (floating chrome only)

    static func glassFill(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.094, green: 0.094, blue: 0.114).opacity(0.72)
            : Color.white.opacity(0.72)
    }

    static func glassFillStrong(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.071, green: 0.071, blue: 0.086).opacity(0.86)
            : Color.white.opacity(0.88)
    }

    static func glassBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.12)
            : Color.black.opacity(0.10)
    }

    static func glassHighlight(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.06)
            : Color.white.opacity(0.60)
    }

    // MARK: Status (brightness on the yellow ladder + wording)

    static let success = yellowBright
    static let warning = identity
    /// Danger is expressed by inversion at the control. Call sites that need a
    /// fill should use `textPrimary` (dark) / white (light) rather than a red hue.
    static let danger = Color.white
    static let info = yellowDeep

    static func successSurface(for scheme: ColorScheme) -> Color {
        yellowBright.opacity(0.15)
    }

    static func warningSurface(for scheme: ColorScheme) -> Color {
        identity.opacity(0.15)
    }

    static func dangerSurface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.08)
    }

    // MARK: Recovery Scale

    /// Brightest = recovered, dimmest = sore. Always pair with a written label.
    static func recoveryColor(for status: RecoveryStatusLike, scheme: ColorScheme = .dark) -> Color {
        switch status {
        case .recovered:
            return scheme == .dark ? yellowBright : yellowDeep
        case .slightlyFatigued:
            return scheme == .dark ? identity : Color(red: 0.659, green: 0.549, blue: 0.0)  // #A88C00
        case .fatigued:
            return scheme == .dark ? yellowDeep : yellowDim
        case .sore:
            return scheme == .dark ? yellowDim : Color(red: 0.290, green: 0.239, blue: 0.0)  // #4A3D00
        }
    }

    // MARK: Heatmap ramp

    static func heat(level: Int, for scheme: ColorScheme) -> Color {
        let clamped = max(0, min(4, level))
        if scheme == .dark {
            switch clamped {
            case 0: return Color.white.opacity(0.05)
            case 1: return identity.opacity(0.22)
            case 2: return identity.opacity(0.45)
            case 3: return identity.opacity(0.70)
            default: return identity
            }
        } else {
            switch clamped {
            case 0: return Color.black.opacity(0.06)
            case 1: return yellowDeep.opacity(0.30)
            case 2: return yellowDeep.opacity(0.55)
            case 3: return yellowDeep.opacity(0.80)
            default: return yellowDeep
            }
        }
    }
}

// MARK: - RecoveryStatusLike

/// DS-local mirror so tokens compile without importing BetterFit into every file.
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
