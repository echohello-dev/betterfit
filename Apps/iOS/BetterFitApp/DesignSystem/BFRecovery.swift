import BetterFit
import SwiftUI

// MARK: - RecoveryStatus + BFColors bridge

extension RecoveryStatusLike {
    init(_ status: RecoveryStatus) {
        switch status {
        case .recovered: self = .recovered
        case .slightlyFatigued: self = .slightlyFatigued
        case .fatigued: self = .fatigued
        case .sore: self = .sore
        }
    }
}

extension RecoveryStatus {
    /// Muscle recovery color — recovered (blue) → sore (red).
    var bfColor: Color {
        BFColors.recoveryColor(for: RecoveryStatusLike(self))
    }

    /// Short label for chips/legends.
    var bfLabel: String {
        switch self {
        case .recovered: return "Recovered"
        case .slightlyFatigued: return "Fresh"
        case .fatigued: return "Fatigued"
        case .sore: return "Sore"
        }
    }
}

// MARK: - Recovery Dot

/// Small colored dot indicating a region's recovery status.
struct BFRecoveryDot: View {
    let status: RecoveryStatus
    var size: CGFloat = 10

    var body: some View {
        Circle()
            .fill(status.bfColor)
            .frame(width: size, height: size)
            .accessibilityLabel("Recovery: \(status.bfLabel)")
    }
}

// MARK: - Recovery Badge

/// Colored capsule with status label (e.g. "Recovered", "Sore").
struct BFRecoveryBadge: View {
    let status: RecoveryStatus

    var body: some View {
        Text(status.bfLabel)
            .font(BFTypography.captionEmphasis)
            .foregroundStyle(status.bfColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(status.bfColor.opacity(0.15)))
    }
}
