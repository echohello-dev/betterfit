import Foundation

// MARK: - Number formatting

/// Shared numeric display rules for the Ledger UI.
///
/// Values that read as whole numbers drop their decimal; anything else keeps a
/// single significant decimal so a plate change stays legible mid-set.
enum BFFormat {
    /// Whole numbers render as integers, everything else keeps one decimal.
    static func trimmed(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    /// Rounds to the nearest whole number. Used for headline aggregates where a
    /// fractional value would only add noise.
    static func rounded(_ value: Double) -> String {
        String(Int(value.rounded()))
    }
}
