import SwiftUI

struct LiquidGlassBackground: View {
    let theme: AppTheme
    var cornerRadius: CGFloat = 16

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(theme.cardBackground)
            .overlay {
                // Subtle tint so the glass feels “alive” across themes.
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.accent.opacity(0.10),
                                theme.accent.opacity(0.04),
                                Color.white.opacity(0.02),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
            .overlay {
                // Specular edge highlight.
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.70),
                                Color.white.opacity(0.20),
                                Color.clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.screen)
                    .opacity(theme.preferredColorScheme == .dark ? 0.55 : 0.30)
            }
            .overlay {
                // Soft inner glow.
                shape
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blendMode(.softLight)
                    .clipShape(shape)
                    .opacity(theme.preferredColorScheme == .dark ? 0.65 : 0.45)
            }
            .shadow(
                color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.35 : 0.12),
                radius: theme.preferredColorScheme == .dark ? 18 : 12,
                x: 0,
                y: 8
            )
    }
}

struct LiquidGlassCircleBackground: View {
    let theme: AppTheme

    var body: some View {
        let shape = Circle()

        shape
            .fill(theme.cardBackground)
            .overlay {
                shape
                    .fill(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.10), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
            .overlay {
                shape
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.70), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.screen)
                    .opacity(theme.preferredColorScheme == .dark ? 0.50 : 0.25)
            }
            .shadow(
                color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.30 : 0.10),
                radius: theme.preferredColorScheme == .dark ? 14 : 10,
                x: 0,
                y: 6
            )
    }
}

struct BFChromeIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .frame(width: 34, height: 34)
        }
        .accessibilityLabel(accessibilityLabel)
        .modifier(BFChromeIconButtonStyle(theme: theme))
    }
}

private struct BFChromeIconButtonStyle: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            content
                .background { LiquidGlassCircleBackground(theme: theme) }
        }
    }
}

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
            .background {
                LiquidGlassBackground(theme: theme, cornerRadius: 16)
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
        .background {
            LiquidGlassBackground(theme: theme, cornerRadius: 14)
        }
    }
}
