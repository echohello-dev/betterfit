import SwiftUI

// MARK: - BF Card

/// Flat card: solid surface + hairline border + continuous radius. No glass, no blur.
struct BFDSCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme

    var padding: CGFloat = BFSpacing.lg
    var cornerRadius: CGFloat = BFRadius.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BFColors.surface(for: scheme))
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BFColors.border(for: scheme), lineWidth: 1)
            }
    }
}

// MARK: - BF Section Header

/// Uppercased label + optional trailing action.
struct BFSectionHeader<Action: View>: View {
    let title: String
    @ViewBuilder var action: Action

    @Environment(\.colorScheme) private var scheme

    init(title: String, @ViewBuilder action: () -> Action) {
        self.title = title
        self.action = action()
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .bfSectionLabel()
                .foregroundStyle(BFColors.textSecondary(for: scheme))
            Spacer(minLength: 0)
            action
        }
    }
}

extension BFSectionHeader where Action == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

// MARK: - BF Stat Tile

/// Icon + value + label. Used in grids for streaks, volume, recovery stats.
struct BFStatTile: View {
    let systemImage: String
    let value: String
    let label: String
    var tint: Color = BFColors.brandAccent

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        BFDSCard(padding: BFSpacing.md) {
            VStack(alignment: .leading, spacing: BFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)

                Text(value)
                    .font(BFTypography.statMedium)
                    .foregroundStyle(BFColors.textPrimary(for: scheme))

                Text(label)
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textSecondary(for: scheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - BF Chip

/// Filter/selection capsule. Selected = accent fill, unselected = surface.
struct BFChip: View {
    let title: String
    var systemImage: String? = nil
    var isSelected: Bool = false
    var action: () -> Void = {}

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(BFTypography.footnoteEmphasis)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? BFColors.brandAccent : BFColors.surfaceRaised(for: scheme))
            )
            .overlay {
                if !isSelected {
                    Capsule().stroke(BFColors.border(for: scheme), lineWidth: 1)
                }
            }
            .foregroundStyle(isSelected ? .white : BFColors.textPrimary(for: scheme))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - BF List Row

/// Circular icon + title + subtitle + optional trailing content. Exercise-row pattern.
struct BFListRow<Trailing: View>: View {
    let systemImage: String
    let title: String
    var subtitle: String? = nil
    var iconTint: Color = BFColors.brandAccent
    @ViewBuilder var trailing: Trailing

    @Environment(\.colorScheme) private var scheme

    init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        iconTint: Color = BFColors.brandAccent,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.iconTint = iconTint
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: BFSpacing.md) {
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconTint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFTypography.subheadlineEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: scheme))
                if let subtitle {
                    Text(subtitle)
                        .font(BFTypography.footnote)
                        .foregroundStyle(BFColors.textSecondary(for: scheme))
                }
            }

            Spacer(minLength: 0)

            trailing
        }
        .padding(.vertical, BFSpacing.sm)
        .contentShape(Rectangle())
    }
}

extension BFListRow where Trailing == EmptyView {
    init(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        iconTint: Color = BFColors.brandAccent
    ) {
        self.init(systemImage: systemImage, title: title, subtitle: subtitle, iconTint: iconTint) {
            EmptyView()
        }
    }
}

// MARK: - BF Chevron Row

/// Tappable settings/navigation row.
struct BFChevronRow: View {
    let systemImage: String
    let title: String
    var subtitle: String? = nil
    var iconTint: Color = BFColors.brandAccent
    var action: () -> Void = {}

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            BFListRow(
                systemImage: systemImage,
                title: title,
                subtitle: subtitle,
                iconTint: iconTint
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BFColors.textTertiary(for: scheme))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - BF Empty State

struct BFEmptyState: View {
    let systemImage: String
    let title: String
    var message: String? = nil

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: BFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(BFColors.textTertiary(for: scheme))

            Text(title)
                .font(BFTypography.headline)
                .foregroundStyle(BFColors.textPrimary(for: scheme))

            if let message {
                Text(message)
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textSecondary(for: scheme))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BFSpacing.xxxl)
    }
}

// MARK: - BF Progress Ring

/// Flat progress ring — solid track, accent fill, round caps.
struct BFProgressRing: View {
    let progress: Double  // 0...1
    var lineWidth: CGFloat = 10
    var tint: Color = BFColors.brandAccent
    var size: CGFloat? = nil

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Circle()
                .stroke(BFColors.surfaceRaised(for: scheme), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: progress)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - BF Divider

struct BFDivider: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Rectangle()
            .fill(BFColors.separator(for: scheme))
            .frame(height: 1)
    }
}

// MARK: - Page Background Modifier

extension View {
    /// Flat page background (replaces gradient backgrounds).
    func bfPageBackground() -> some View {
        modifier(BFPageBackgroundModifier())
    }
}

private struct BFPageBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.background(BFColors.background(for: scheme).ignoresSafeArea())
    }
}
