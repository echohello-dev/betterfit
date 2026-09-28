import SwiftUI

// MARK: - Ledger action primitives
// Rules, not cards. A mono gutter, one yellow field per screen, floating glass chrome.
// Glass is reserved for floating chrome (nav, action dock, revealed swipe actions);
// scrolling controls use flat raised surfaces.

// MARK: Quick actions strip

struct BFQuickAction: Identifiable {
    let id = UUID()
    let systemImage: String
    let label: String
    var action: () -> Void = {}
}

struct BFQuickActions: View {
    let items: [BFQuickAction]
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button(action: item.action) {
                        HStack(spacing: 7) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(BFColors.accentText(for: scheme))
                            Text(item.label)
                                .font(BFTypography.footnoteEmphasis)
                                .foregroundStyle(BFColors.textPrimary(for: scheme))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: BFControlSize.minTapTarget)
                        .background {
                            Capsule()
                                .fill(BFColors.surfaceRaised(for: scheme))
                                .overlay {
                                    Capsule().stroke(BFColors.border(for: scheme), lineWidth: 1)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BFSpacing.pageHorizontal)
        }
    }
}

// MARK: Glass dock

/// Floating action dock. Content is a single HStack of equal-height controls
/// (primary pill + square companions). Sits above the tab bar via safeAreaInset.
struct BFGlassDock<Content: View>: View {
    var horizontalPadding: CGFloat = 12
    @ViewBuilder var content: Content
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, minHeight: BFControlSize.buttonLarge, alignment: .center)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            Capsule(style: .continuous)
                .fill(reduceTransparency
                      ? BFColors.backgroundElevated(for: scheme)
                      : BFColors.glassFillStrong(for: scheme))
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(BFColors.glassBorder(for: scheme), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(scheme == .dark ? 0.45 : 0.14), radius: 18, y: 6)
        }
        .padding(.horizontal, horizontalPadding)
    }
}

/// Primary docked action. Standalone = compact centered pill; otherwise fills
/// available width. Yellow by default; `quiet` renders neutral glass so a screen
/// that leads with a full yellow field never shows two yellow fills at once.
struct BFDockPrimaryButton: View {
    let title: String
    var systemImage: String? = "play.fill"
    /// When true, sizes to the label (rounded pill). When false, expands full width.
    var standalone = true
    /// One-yellow rule (design.md): set when the screen leads with a full yellow field.
    var quiet = false
    var action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .bold))
                }
                Text(title)
                    .font(BFTypography.headline)
            }
            .foregroundStyle(quiet ? BFColors.textPrimary(for: scheme) : BFColors.accentInk)
            .padding(.horizontal, standalone ? 36 : 20)
            .frame(maxWidth: standalone ? nil : .infinity)
            .frame(height: BFControlSize.buttonLarge)
            .background {
                Capsule(style: .continuous)
                    .fill(quiet ? BFColors.glassHighlight(for: scheme) : BFColors.accent)
                    .overlay {
                        if quiet {
                            Capsule(style: .continuous)
                                .stroke(BFColors.glassBorder(for: scheme), lineWidth: 1)
                        }
                    }
            }
            .contentShape(Capsule())
            .shadow(
                color: Color.black.opacity(standalone ? 0.4 : 0.2),
                radius: standalone ? 20 : 10,
                y: standalone ? 8 : 4
            )
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: standalone, vertical: true)
    }
}

// MARK: Dock companion button

struct BFDockButton: View {
    let systemImage: String
    let label: String
    var action: () -> Void = {}
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(BFColors.textPrimary(for: scheme))
                .frame(width: BFControlSize.buttonLarge, height: BFControlSize.buttonLarge)
                .background {
                    Circle()
                        .fill(BFColors.glassHighlight(for: scheme))
                        .overlay {
                            Circle().stroke(BFColors.glassBorder(for: scheme), lineWidth: 1)
                        }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(width: BFControlSize.buttonLarge, height: BFControlSize.buttonLarge)
        .accessibilityLabel(label)
    }
}

// MARK: Source switch (Suggested / Frequent)

struct BFSourceSwitch: View {
    @Binding var selection: String
    let options: [(id: String, label: String)]
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.id) { option in
                Button {
                    selection = option.id
                } label: {
                    Text(option.label)
                        .font(BFTypography.footnoteEmphasis)
                        .foregroundStyle(
                            selection == option.id
                                ? BFColors.textPrimary(for: scheme)
                                : BFColors.textSecondary(for: scheme)
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: BFControlSize.minTapTarget)
                        .background {
                            if selection == option.id {
                                Capsule().fill(BFColors.background(for: scheme))
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(BFColors.surfaceRaised(for: scheme)))
    }
}
