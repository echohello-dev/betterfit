import BetterFit
import SwiftUI

struct RecoveryView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()

    var body: some View {
        List {
            Section("Overall") {
                LabeledContent("Recovery") {
                    Text("\(Int(betterFit.bodyMapManager.getOverallRecoveryPercentage()))%")
                        .monospacedDigit()
                }
            }

            Section("By region") {
                ForEach(BodyRegion.allCases.filter { $0 != .other }, id: \.self) { region in
                    let status =
                        map.regions[region]
                        ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)
                    LabeledContent(regionName(region)) {
                        Text(statusText(status))
                            .foregroundStyle(statusColor(status))
                    }
                }
            }

            Section {
                Button("Reset recovery map") {
                    betterFit.bodyMapManager.reset()
                    refresh()
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Recovery")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh")
            }
        }
        .onAppear {
            refresh()
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
