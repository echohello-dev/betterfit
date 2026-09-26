import BetterFit
import SwiftUI

// MARK: - Body (recovery) — Ledger layout

struct RecoveryView: View {
    @Environment(\.colorScheme) private var colorScheme
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()

    private var regions: [(region: BodyRegion, status: RecoveryStatus, percent: Int)] {
        BodyRegion.allCases
            .filter { $0 != .other }
            .map { region in
                let status = map.regions[region] ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)
                let percent = Int((status.bfReadiness * 100).rounded())
                return (region, status, percent)
            }
            .sorted { $0.percent > $1.percent }
    }

    private var overall: Int {
        Int(betterFit.bodyMapManager.getOverallRecoveryPercentage().rounded())
    }

    private var readyNames: [String] {
        regions.filter { $0.percent >= 75 }.map { regionName($0.region) }
    }

    private var soreNames: [String] {
        regions.filter { $0.percent < 50 }.map { regionName($0.region) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BFReadout(
                    value: "\(overall)",
                    unit: "%",
                    label: "Overall recovery",
                    note: recoveryNote
                )

                spectrumStrip
                    .padding(.top, BFSpacing.xl)

                BFSectionRule(label: "By muscle group", trailing: "\(regions.count) tracked")

                ForEach(regions, id: \.region) { item in
                    recoveryRow(item)
                }

                BFSectionRule(label: "How this is measured")
                Text(
                    "Recovery combines the volume you lifted per muscle group, how long ago you trained it, "
                        + "and the sets you reported as hard. It is an estimate, not a diagnosis — train by how you feel."
                )
                    .font(BFTypography.footnote)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    betterFit.bodyMapManager.reset()
                    refresh()
                } label: {
                    Text("Reset recovery map")
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.accentText(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, BFSpacing.xxl)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BFSpacing.pageHorizontal)
            .padding(.bottom, 110)
        }
        .bfBackground(theme: theme)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Body")
                    .font(BFTypography.screenTitle)
                    .tracking(BFTypography.displayTracking)
            }
        }
        .onAppear { refresh() }
    }

    // MARK: - Spectrum

    private var spectrumStrip: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(regions, id: \.region) { item in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(item.status.bfColor(for: colorScheme))
                        .frame(height: 6)
                }
            }
            HStack {
                Text("Most recovered")
                Spacer()
                Text("Least")
            }
            .font(.system(size: 10, weight: .semibold))
            .textCase(.uppercase)
            .tracking(1.0)
            .foregroundStyle(BFColors.textTertiary(for: colorScheme))
        }
    }

    // MARK: - Row

    private func recoveryRow(_ item: (region: BodyRegion, status: RecoveryStatus, percent: Int)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: regionIcon(item.region))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(item.status.bfColor(for: colorScheme))
                    .frame(width: 32, alignment: .leading)

                Text(regionName(item.region))
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                Spacer(minLength: 0)

                Text(item.status.bfLabel)
                    .font(BFTypography.footnote)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                Text("\(item.percent)%")
                    .font(BFTypography.subheadlineEmphasis)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .frame(width: 42, alignment: .trailing)
            }

            BFBar(progress: Double(item.percent) / 100.0, color: item.status.bfColor(for: colorScheme))
                .padding(.leading, 44)
        }
        .padding(.vertical, 13)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
    }

    // MARK: - Helpers

    private var recoveryNote: String {
        let ready = list(readyNames)
        var note = ready.isEmpty
            ? "Nothing is fully recovered yet."
            : "\(ready) \(readyNames.count == 1 ? "is" : "are") ready to train."
        if let first = soreNames.first {
            note += " \(first) needs another day."
        }
        return note
    }

    private func list(_ names: [String]) -> String {
        switch names.count {
        case 0: return ""
        case 1: return names[0]
        case 2: return "\(names[0]) and \(names[1])"
        default: return names.dropLast().joined(separator: ", ") + " and \(names.last!)"
        }
    }

    private func refresh() {
        map = betterFit.bodyMapManager.getRecoveryMap()
    }

    private func regionName(_ region: BodyRegion) -> String {
        switch region {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .arms: return "Arms"
        case .core: return "Core"
        case .legs: return "Legs"
        case .other: return "Other"
        }
    }

    private func regionIcon(_ region: BodyRegion) -> String {
        switch region {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.climbing"
        case .shoulders: return "figure.arms.open"
        case .arms: return "dumbbell.fill"
        case .core: return "figure.core.training"
        case .legs: return "figure.run"
        case .other: return "circle"
        }
    }
}

#Preview {
    NavigationStack {
        RecoveryView(betterFit: BetterFit(), theme: .defaultTheme)
    }
    .preferredColorScheme(.dark)
}
