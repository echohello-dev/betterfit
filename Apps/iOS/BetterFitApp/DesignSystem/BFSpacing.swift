import SwiftUI

// MARK: - BF Spacing & Radii

enum BFSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    /// Standard horizontal page padding.
    static let pageHorizontal: CGFloat = 20
}

enum BFRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let card: CGFloat = 16
    static let button: CGFloat = 14
    static let sheet: CGFloat = 24
    static let pill: CGFloat = 999
}

// MARK: - Control Sizes

enum BFControlSize {
    /// Primary CTA height.
    static let buttonLarge: CGFloat = 54
    static let buttonMedium: CGFloat = 44
    static let buttonSmall: CGFloat = 34
    /// Minimum tap target.
    static let minTapTarget: CGFloat = 44
}
