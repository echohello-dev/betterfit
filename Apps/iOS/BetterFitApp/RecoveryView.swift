import BetterFit
import SwiftUI

struct RecoveryView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()

    @State private var showingSearch = false

    var body: some View {
        List {
            Section("Overall") {
                LabeledContent("Recovery") {
                    Text("\(Int(betterFit.bodyMapManager.getOverallRecoveryPercentage()))%")
                        .monospacedDigit()
                }
                .listRowBackground(LiquidGlassBackground(theme: theme, cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)

            Section("By region") {
                ForEach(BodyRegion.allCases.filter { $0 != .other }, id: \.self) { region in
                    let status =
                        map.regions[region]
                        ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)
                    LabeledContent(regionName(region)) {
                        Text(statusText(status))
                            .foregroundStyle(statusColor(status))
                    }
                    .listRowBackground(LiquidGlassBackground(theme: theme, cornerRadius: 14))
                }
            }
            .listSectionSeparator(.hidden)

            Section {
                Button("Reset recovery map") {
                    betterFit.bodyMapManager.reset()
                    refresh()
                }
                .foregroundStyle(.red)
                .listRowBackground(LiquidGlassBackground(theme: theme, cornerRadius: 14))
            }
            .listSectionSeparator(.hidden)
        }
        .navigationTitle("Recovery")
        .scrollContentBackground(.hidden)
        .background(theme.backgroundGradient.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background { LiquidGlassCircleBackground(theme: theme) }
                }
                .accessibilityLabel("Refresh")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.body.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background { LiquidGlassCircleBackground(theme: theme) }
                }
                .accessibilityLabel("Search")
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
