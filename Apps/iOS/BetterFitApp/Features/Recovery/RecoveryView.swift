import BetterFit
import SwiftUI

struct RecoveryView: View {
    @Environment(\.colorScheme) var colorScheme
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                overallCard

                VStack(alignment: .leading, spacing: 10) {
                    Text("By region")
                        .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12),
                        ],
                        spacing: 12
                    ) {
                        ForEach(BodyRegion.allCases.filter { $0 != .other }, id: \.self) { region in
                            regionCard(region)
                        }
                    }
                }

                resetCard
            }
            .padding(16)
        }
        .bfPageBackground()
        .onAppear {
            refresh()
        }
    }

    private var overallCard: some View {
        let overall = betterFit.bodyMapManager.getOverallRecoveryPercentage()
        let progress = overall / 100.0

        return BFCard(theme: theme) {
            HStack(spacing: 16) {
                ZStack {
                    BFProgressRing(progress: progress, lineWidth: 10, tint: theme.accent, size: 86)

                    Text("\(Int(overall))%")
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Overall")
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                    Text(overallHeadline(overall))
                        .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                    Text("Fresh muscle groups are good to push; sore groups need rest.")
                        .font(.subheadline)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func regionCard(_ region: BodyRegion) -> some View {
        let status = map.regions[region] ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)

        VStack(alignment: .leading, spacing: 10) {
            Text(regionName(region))
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 8) {
                BFRecoveryDot(status: status)

                Text(status.bfLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(status.bfColor)

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
            shape
                .fill(BFColors.surface(for: colorScheme))
                .overlay { shape.stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
        }
    }

    private var resetCard: some View {
        BFCard(theme: theme) {
            Button(role: .destructive) {
                betterFit.bodyMapManager.reset()
                refresh()
            } label: {
                Label("Reset recovery map", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
        }
    }

    private func overallHeadline(_ overall: Double) -> String {
        switch overall {
        case 0..<35:
            return "Low recovery"
        case 35..<70:
            return "Moderate recovery"
        default:
            return "High recovery"
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
}

#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    return RecoveryView(betterFit: BetterFit(), theme: .forest)
}
