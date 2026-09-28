import SwiftUI

// MARK: - Ledger row primitives
// Rules, not cards. A mono gutter, one yellow field per screen, floating glass chrome.

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

// MARK: Ledger row trailing

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
