import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// MARK: - BF Typography
//
// Type pairings (design system):
//   Display  → BBH Hegarty (hero, titles)
//   UI       → system SF (body, controls, labels)
//   Numeric  → system SF monospaced digits (timers, weights, reps, stats)

enum BFTypography {

    // MARK: Display (BBH Hegarty)

    /// Full-bleed identity headline.
    static var hero: Font { display(56, relativeTo: .largeTitle) }
    /// Slab / session titles.
    static var display: Font { display(44, relativeTo: .largeTitle) }
    static var largeTitle: Font { display(34, relativeTo: .largeTitle) }
    static var title1: Font { display(28, relativeTo: .title) }
    static var title2: Font { display(22, relativeTo: .title2) }
    /// Screen head (Plan / Body / Log).
    static var screenTitle: Font { display(26, relativeTo: .title2) }

    // MARK: UI (system)

    static let title3 = Font.system(size: 20, weight: .semibold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyEmphasis = Font.system(size: 17, weight: .semibold)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let subheadlineEmphasis = Font.system(size: 15, weight: .semibold)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let footnoteEmphasis = Font.system(size: 13, weight: .semibold)
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionEmphasis = Font.system(size: 12, weight: .semibold)
    /// Uppercase micro label (section rules, eyebrows).
    static let eyebrow = Font.system(size: 11, weight: .bold)

    // MARK: Numeric (tabular / mono digits)

    static let readout = Font.system(size: 64, weight: .bold).monospacedDigit()
    static let timerDisplay = Font.system(size: 40, weight: .bold).monospacedDigit()
    static let stepperValue = Font.system(size: 34, weight: .bold).monospacedDigit()
    static let setValue = Font.system(size: 28, weight: .bold).monospacedDigit()
    static let statLarge = Font.system(size: 28, weight: .bold).monospacedDigit()
    static let specValue = Font.system(size: 22, weight: .bold).monospacedDigit()
    static let statMedium = Font.system(size: 20, weight: .bold).monospacedDigit()
    static let statSmall = Font.system(size: 15, weight: .semibold).monospacedDigit()
    static let gutter = Font.system(size: 15, weight: .bold).monospacedDigit()

    // MARK: Tracking

    /// Display tracking with Regular cut (looser so glyphs don't collide).
    static let displayTracking: CGFloat = 0.2
    /// Uppercase section / eyebrow tracking.
    static let labelTracking: CGFloat = 1.2

    // MARK: Resolution

    private static let displayCandidates: [String] = [
        "BBHHegarty-ExtraBold",
        "BBHHegarty-Bold",
        "BBH Hegarty",
        "BBHHegarty",
        "BBH-Hegarty",
        "BBHHegarty-Regular",
    ]

    private static let resolvedDisplayName: String? = {
        #if canImport(UIKit)
            return displayCandidates.first { UIFont(name: $0, size: 24) != nil }
        #else
            return nil
        #endif
    }()

    /// BBH Hegarty when registered; heavy rounded system face otherwise.
    static func display(_ size: CGFloat, relativeTo textStyle: Font.TextStyle = .largeTitle) -> Font {
        if let name = resolvedDisplayName {
            return .custom(name, size: size, relativeTo: textStyle)
        }
        return .system(size: size, weight: .black, design: .rounded)
    }
}

// MARK: - View helpers

extension View {
    /// Uppercased, tracked section label (e.g. "THE WORK").
    func bfSectionLabel() -> some View {
        font(BFTypography.captionEmphasis)
            .textCase(.uppercase)
            .tracking(BFTypography.labelTracking)
    }

    /// Display heading in BBH Hegarty with design-system tracking.
    func bfDisplay(_ size: CGFloat = 44) -> some View {
        font(BFTypography.display(size))
            .tracking(BFTypography.displayTracking)
    }

    /// Theme-aware display heading (kept for existing call sites).
    func bfDisplay(_ theme: AppTheme, size: CGFloat = 44) -> some View {
        bfDisplay(size)
    }
}
