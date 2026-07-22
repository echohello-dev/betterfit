import SwiftUI

// MARK: - BF Typography

/// Type scale for the app. Bold, high-contrast headings; monospaced digits
/// for anything numeric so stats don't jitter.
enum BFTypography {

    // MARK: Display

    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // MARK: Body

    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyEmphasis = Font.system(size: 17, weight: .medium)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let subheadlineEmphasis = Font.system(size: 15, weight: .semibold)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let footnoteEmphasis = Font.system(size: 13, weight: .semibold)
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionEmphasis = Font.system(size: 12, weight: .semibold)

    // MARK: Numeric (monospaced digits — timers, weights, reps, stats)

    static let statLarge = Font.system(size: 28, weight: .bold).monospacedDigit()
    static let statMedium = Font.system(size: 20, weight: .bold).monospacedDigit()
    static let statSmall = Font.system(size: 15, weight: .semibold).monospacedDigit()
    static let timerDisplay = Font.system(size: 40, weight: .bold).monospacedDigit()
}

// MARK: - View helpers

extension View {
    /// Uppercased, tracked section label (e.g. "TODAY'S WORKOUT").
    func bfSectionLabel() -> some View {
        font(BFTypography.captionEmphasis)
            .textCase(.uppercase)
            .tracking(1.2)
    }
}
