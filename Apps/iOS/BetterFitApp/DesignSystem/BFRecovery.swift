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
    /// Muscle recovery colour on the yellow ladder.
    var bfColor: Color {
        BFColors.recoveryColor(for: RecoveryStatusLike(self))
    }

    func bfColor(for scheme: ColorScheme) -> Color {
        BFColors.recoveryColor(for: RecoveryStatusLike(self), scheme: scheme)
    }

    /// Short label for chips/legends — always pair with the colour.
    var bfLabel: String {
        switch self {
        case .recovered: return "Recovered"
        case .slightlyFatigued: return "Fresh"
        case .fatigued: return "Fatigued"
        case .sore: return "Sore"
        }
    }

    /// 0…1 readiness used by ledger bars.
    var bfReadiness: Double {
        switch self {
        case .recovered: return 0.96
        case .slightlyFatigued: return 0.72
        case .fatigued: return 0.48
        case .sore: return 0.22
        }
    }
}

// MARK: - Recovery Dot

struct BFRecoveryDot: View {
    let status: RecoveryStatus
    var size: CGFloat = 10
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Circle()
            .fill(status.bfColor(for: scheme))
            .frame(width: size, height: size)
            .accessibilityLabel("Recovery: \(status.bfLabel)")
    }
}

// MARK: - Recovery Badge

struct BFRecoveryBadge: View {
    let status: RecoveryStatus
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text(status.bfLabel)
            .font(BFTypography.captionEmphasis)
            .foregroundStyle(status.bfColor(for: scheme))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(status.bfColor(for: scheme).opacity(0.22)))
            .overlay {
                Capsule().stroke(status.bfColor(for: scheme).opacity(0.45), lineWidth: 1)
            }
    }
}
