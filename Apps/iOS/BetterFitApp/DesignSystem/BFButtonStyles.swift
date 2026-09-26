import SwiftUI

// MARK: - BF Button Styles

/// Yellow fill, black label. Primary CTA ("Start workout", "Save").
struct BFPrimaryButtonStyle: ButtonStyle {
    var isFullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFTypography.headline)
            .foregroundStyle(BFColors.accentInk)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: BFControlSize.buttonLarge)
            .background(
                Capsule(style: .continuous)
                    .fill(BFColors.accent)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Raised surface fill with border, primary text. Secondary actions.
struct BFSecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var scheme
    var isFullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFTypography.headline)
            .foregroundStyle(BFColors.textPrimary(for: scheme))
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: BFControlSize.buttonLarge)
            .background(
                Capsule(style: .continuous)
                    .fill(BFColors.surfaceRaised(for: scheme))
            )
            .overlay {
                Capsule(style: .continuous)
                    .stroke(BFColors.border(for: scheme), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// No fill, accent text. Inline/tertiary actions.
struct BFGhostButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var scheme
    var color: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFTypography.subheadlineEmphasis)
            .foregroundStyle(color ?? BFColors.accentText(for: scheme))
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Inverted fill (primary text on opposite field). Destructive confirmations —
/// no alarm red; meaning comes from the label.
struct BFDestructiveButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFTypography.headline)
            .foregroundStyle(scheme == .dark ? BFColors.background(for: .dark) : .white)
            .frame(maxWidth: .infinity)
            .frame(height: BFControlSize.buttonLarge)
            .background(
                Capsule(style: .continuous)
                    .fill(BFColors.textPrimary(for: scheme))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - BF Icon Button

/// Circular icon button on a raised surface.
struct BFIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var size: CGFloat = 40
    var action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(BFColors.textPrimary(for: scheme))
                .frame(width: size, height: size)
                .background(Circle().fill(BFColors.surfaceRaised(for: scheme)))
                .overlay {
                    Circle().stroke(BFColors.border(for: scheme), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Convenience initializers

extension ButtonStyle where Self == BFPrimaryButtonStyle {
    static var bfPrimary: BFPrimaryButtonStyle { BFPrimaryButtonStyle() }
}

extension ButtonStyle where Self == BFSecondaryButtonStyle {
    static var bfSecondary: BFSecondaryButtonStyle { BFSecondaryButtonStyle() }
}

extension ButtonStyle where Self == BFGhostButtonStyle {
    static var bfGhost: BFGhostButtonStyle { BFGhostButtonStyle() }
}

extension ButtonStyle where Self == BFDestructiveButtonStyle {
    static var bfDestructive: BFDestructiveButtonStyle { BFDestructiveButtonStyle() }
}
