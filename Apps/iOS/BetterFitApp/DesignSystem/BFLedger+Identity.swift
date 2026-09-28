import SwiftUI

// MARK: - Ledger identity primitives
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
