import BetterFit
import SwiftUI

struct RecoveryView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()

    @State private var showingSearch = false

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
        .navigationTitle("Recovery")
        .navigationBarTitleDisplayMode(.large)
        .background(theme.backgroundGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    GlassEffectContainer(spacing: 16) {
                        HStack(spacing: 10) {
                            BFChromeIconButton(
                                systemImage: "magnifyingglass",
                                accessibilityLabel: "Search",
                                theme: theme
                            ) {
                                showingSearch = true
                            }

                            BFChromeIconButton(
                                systemImage: "arrow.clockwise",
                                accessibilityLabel: "Refresh",
                                theme: theme
                            ) {
                                refresh()
                            }
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        BFChromeIconButton(
                            systemImage: "magnifyingglass",
                            accessibilityLabel: "Search",
                            theme: theme
                        ) {
                            showingSearch = true
                        }

                        BFChromeIconButton(
                            systemImage: "arrow.clockwise",
                            accessibilityLabel: "Refresh",
                            theme: theme
                        ) {
                            refresh()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: betterFit)
                .presentationDetents([.large])
        }
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
                    ProgressRing(progress: progress, lineWidth: 10, theme: theme)
                        .frame(width: 86, height: 86)

                    Text("\(Int(overall))%")
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Overall")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(overallHeadline(overall))
                        .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                    Text("Fresh muscle groups are good to push; sore groups need rest.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                Circle()
                    .fill(statusColor(status))
                    .frame(width: 10, height: 10)

                Text(statusText(status))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusColor(status))

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                .shadow(
                    color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.22 : 0.08),
                    radius: theme.preferredColorScheme == .dark ? 14 : 10,
                    x: 0,
                    y: 6
                )
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

    private func statusText(_ status: RecoveryStatus) -> String {
        switch status {
        case .recovered: return "Recovered"
        case .slightlyFatigued: return "Slightly fatigued"
        case .fatigued: return "Fatigued"
        case .sore: return "Sore"
        }
    }

    private func statusColor(_ status: RecoveryStatus) -> Color {
        switch status {
        case .recovered: return theme.accent
        case .slightlyFatigued: return .yellow
        case .fatigued: return .orange
        case .sore: return .red
        }
    }
}

#Preview {
    RecoveryView(betterFit: BetterFit(), theme: .forest)
}
