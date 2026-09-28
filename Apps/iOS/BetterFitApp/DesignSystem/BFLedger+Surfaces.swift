import SwiftUI

// MARK: - Ledger surface primitives
// Rules, not cards. A mono gutter, one yellow field per screen, floating glass chrome.

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
