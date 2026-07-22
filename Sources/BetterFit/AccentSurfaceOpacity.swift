import Foundation

/// The opacity multiplier formula used by `AppTheme.accentSurface(_:for:)`.
/// Extracted as a pure function so it can be unit tested without SwiftUI dependencies.
///
/// In light mode the opacity is boosted so the tint reads against the bright background.
/// In dark mode the opacity is passed through as-is.
public func accentSurfaceOpacity(_ opacity: Double, isDark: Bool) -> Double {
    isDark ? opacity : min(0.85, opacity * 1.8 + 0.08)
}
