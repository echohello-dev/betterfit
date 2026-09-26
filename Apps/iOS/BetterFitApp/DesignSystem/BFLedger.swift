import SwiftUI

// MARK: - Ledger layout primitives
// Rules, not cards. A mono gutter, one yellow field per screen, floating glass chrome.

// MARK: Eyebrow

struct BFEyebrow: View {
    let text: String
    var color: Color? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text(text)
            .font(BFTypography.eyebrow)
            .textCase(.uppercase)
            .tracking(BFTypography.labelTracking)
            .foregroundStyle(color ?? BFColors.textSecondary(for: scheme))
    }
}

// MARK: Section rule

struct BFSectionRule: View {
    let label: String
    var trailing: String? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: BFSpacing.md) {
            BFEyebrow(text: label)
            Rectangle()
                .fill(BFColors.separator(for: scheme))
                .frame(height: 1)
            if let trailing {
                Text(trailing)
                    .font(BFTypography.caption)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textTertiary(for: scheme))
            }
        }
        .padding(.top, BFSpacing.xxl)
        .padding(.bottom, 10)
    }
}

// MARK: Spec strip

struct BFSpecItem: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct BFSpecStrip: View {
    let items: [BFSpecItem]
    var ink: Color? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 18) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.value)
                        .font(BFTypography.specValue)
                        .foregroundStyle(ink ?? BFColors.textPrimary(for: scheme))
                    Text(item.label)
                        .font(BFTypography.eyebrow)
                        .textCase(.uppercase)
                        .tracking(BFTypography.labelTracking)
                        .opacity(0.58)
                        .foregroundStyle(ink ?? BFColors.textSecondary(for: scheme))
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: Header block (action screens — neutral by default)

struct BFHeaderBlock: View {
    var eyebrow: String? = nil
    var title: String? = nil
    var specs: [BFSpecItem] = []
    /// When true, the header takes the yellow field (docked action goes quiet).
    var yellow = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let eyebrow {
                BFEyebrow(
                    text: eyebrow,
                    color: yellow ? BFColors.identityInk.opacity(0.62) : BFColors.accentText(for: scheme)
                )
            }
            if let title {
                Text(title)
                    .font(BFTypography.display)
                    .tracking(BFTypography.displayTracking)
                    .foregroundStyle(yellow ? BFColors.identityInk : BFColors.textPrimary(for: scheme))
                    .padding(.top, 10)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            if !specs.isEmpty {
                BFSpecStrip(items: specs, ink: yellow ? BFColors.identityInk : nil)
                    .padding(.top, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.top, 4)
        .padding(.bottom, 20)
        .background(yellow ? BFColors.identity : Color.clear)
        .overlay(alignment: .bottom) {
            if !yellow {
                Rectangle()
                    .fill(BFColors.separator(for: scheme))
                    .frame(height: 1)
            }
        }
    }
}

// MARK: Slab (full-bleed yellow field for outcome screens)

struct BFSlab<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .foregroundStyle(BFColors.identityInk)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BFSpacing.pageHorizontal)
            .padding(.vertical, 18)
            .background(BFColors.identity)
    }
}

// MARK: Readout (conclusion first)

struct BFReadout: View {
    let value: String
    var unit: String? = nil
    let label: String
    var note: String? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BFEyebrow(text: label)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(BFTypography.readout)
                    .foregroundStyle(BFColors.textPrimary(for: scheme))
                if let unit {
                    Text(unit)
                        .font(BFTypography.specValue)
                        .foregroundStyle(BFColors.textSecondary(for: scheme))
                }
            }
            .padding(.top, 10)
            if let note {
                Text(note)
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textSecondary(for: scheme))
                    .padding(.top, 12)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
}

// MARK: Bar (shared left-edge progress — never a ring on iPhone)

struct BFBar: View {
    let progress: Double
    var color: Color = BFColors.accent
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(BFColors.surfaceRaised(for: scheme))
                Capsule()
                    .fill(color)
                    .frame(width: max(2, geo.size.width * CGFloat(min(1, max(0, progress)))))
            }
        }
        .frame(height: 4)
    }
}

// MARK: Ledger row

struct BFLedgerRow<Trailing: View>: View {
    var gutter: String? = nil
    var gutterAccent = false
    var systemImage: String? = nil
    let title: String
    var meta: String? = nil
    var dim = false
    var accentEdge = false
    @ViewBuilder var trailing: Trailing

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            if let systemImage {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(BFColors.surfaceRaised(for: scheme))
                        .overlay {
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .stroke(BFColors.border(for: scheme), lineWidth: 1)
                        }
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BFColors.accentText(for: scheme))
                }
                .frame(width: 38, height: 38)
            } else if let gutter {
                Text(gutter)
                    .font(BFTypography.gutter)
                    .foregroundStyle(
                        gutterAccent
                            ? BFColors.accentText(for: scheme)
                            : BFColors.textTertiary(for: scheme)
                    )
                    .frame(width: 32, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: scheme))
                    .lineLimit(2)
                if let meta {
                    Text(meta)
                        .font(BFTypography.footnote)
                        .foregroundStyle(BFColors.textSecondary(for: scheme))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing
        }
        .padding(.vertical, 14)
        .opacity(dim ? 0.45 : 1)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: scheme))
                .frame(height: 1)
        }
        .overlay(alignment: .leading) {
            if accentEdge {
                Rectangle()
                    .fill(BFColors.accent)
                    .frame(width: 3)
                    .offset(x: -BFSpacing.pageHorizontal)
            }
        }
    }
}

extension BFLedgerRow where Trailing == EmptyView {
    init(
        gutter: String? = nil,
        gutterAccent: Bool = false,
        systemImage: String? = nil,
        title: String,
        meta: String? = nil,
        dim: Bool = false,
        accentEdge: Bool = false
    ) {
        self.gutter = gutter
        self.gutterAccent = gutterAccent
        self.systemImage = systemImage
        self.title = title
        self.meta = meta
        self.dim = dim
        self.accentEdge = accentEdge
        self.trailing = EmptyView()
    }
}

struct BFLedgerTrailing: View {
    let value: String
    var meta: String? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text(value)
                .font(BFTypography.subheadlineEmphasis)
                .monospacedDigit()
                .foregroundStyle(BFColors.textPrimary(for: scheme))
            if let meta {
                Text(meta)
                    .font(BFTypography.caption)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textTertiary(for: scheme))
            }
        }
    }
}

// MARK: Add row

struct BFAddRow: View {
    var label = "Add exercise"
    var action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 32, alignment: .leading)
                Text(label)
                    .font(BFTypography.bodyEmphasis)
                Spacer()
            }
            .foregroundStyle(BFColors.accentText(for: scheme))
            .padding(.vertical, 16)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(BFColors.separator(for: scheme))
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

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
                                .fill(BFColors.glassFill(for: scheme))
                                .overlay {
                                    Capsule().stroke(BFColors.glassBorder(for: scheme), lineWidth: 1)
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

/// Primary yellow action. Standalone = compact centered pill; otherwise fills available width.
struct BFDockPrimaryButton: View {
    let title: String
    var systemImage: String? = "play.fill"
    /// When true, sizes to the label (rounded pill). When false, expands full width.
    var standalone = true
    var action: () -> Void

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
            .foregroundStyle(BFColors.accentInk)
            .padding(.horizontal, standalone ? 36 : 20)
            .frame(maxWidth: standalone ? nil : .infinity)
            .frame(height: BFControlSize.buttonLarge)
            .background(Capsule(style: .continuous).fill(BFColors.accent))
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

// MARK: Ledger head

struct BFLedgerHead<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(BFTypography.screenTitle)
                .tracking(BFTypography.displayTracking)
                .foregroundStyle(BFColors.textPrimary(for: scheme))
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, BFSpacing.pageHorizontal)
        .padding(.bottom, 14)
    }
}

extension BFLedgerHead where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.trailing = EmptyView()
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
