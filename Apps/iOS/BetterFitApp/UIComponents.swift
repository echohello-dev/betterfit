import SwiftUI

// MARK: - Legacy chrome button (kept for call-site compatibility)

struct BFChromeIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        BFIconButton(
            systemImage: systemImage,
            accessibilityLabel: accessibilityLabel,
            action: action
        )
    }
}

// MARK: - BFCard (flat redesign, same signature)

struct BFCard<Content: View>: View {
    let theme: AppTheme
    @ViewBuilder let content: Content

    init(theme: AppTheme, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        BFDSCard(content: { content })
    }
}

// MARK: - ProgressRing (flat redesign, same signature)

struct ProgressRing: View {
    let progress: Double  // 0...1
    let lineWidth: CGFloat
    let theme: AppTheme

    init(progress: Double, lineWidth: CGFloat = 10, theme: AppTheme) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.theme = theme
    }

    var body: some View {
        BFProgressRing(progress: progress, lineWidth: lineWidth, tint: theme.accent)
    }
}

// MARK: - MetricPill (flat redesign, same signature)

struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String
    let theme: AppTheme

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: BFSpacing.sm) {
            Image(systemName: systemImage)
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textSecondary(for: scheme))
                Text(value)
                    .font(BFTypography.statSmall)
            }

            Spacer(minLength: 0)
        }
        .padding(BFSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .fill(BFColors.surface(for: scheme))
        )
        .overlay {
            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                .stroke(BFColors.border(for: scheme), lineWidth: 1)
        }
    }
}

// MARK: - FitnessIcon

struct FitnessIcon: View {
    let systemImage: String
    let size: Double
    let color: Color

    @State private var isAnimated = false

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(color)
            .scaleEffect(isAnimated ? 1.1 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimated = true
                }
            }
    }
}
