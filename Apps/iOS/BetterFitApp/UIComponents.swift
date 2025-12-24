import SwiftUI

struct BFCard<Content: View>: View {
    let theme: AppTheme
    @ViewBuilder let content: Content

    init(theme: AppTheme, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.cardStroke, lineWidth: 1)
            }
    }
}

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
        ZStack {
            Circle()
                .stroke(theme.cardStroke.opacity(0.55), style: StrokeStyle(lineWidth: lineWidth))

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    AngularGradient(
                        colors: [theme.accent, theme.accent.opacity(0.55)], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: progress)
        }
        .accessibilityLabel("Recovery")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(theme.cardStroke, lineWidth: 1)
        }
    }
}
