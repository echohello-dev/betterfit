import Auth
import BetterFit
import SwiftUI

// MARK: - Me — DS lists + cards

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let betterFit: BetterFit
    let theme: AppTheme
    let isGuest: Bool
    let user: Auth.User?
    let onShowSignIn: () -> Void
    let onLogout: (() -> Void)?

    @State private var showSettings = false
    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme.rawValue

    private var displayName: String {
        if isGuest { return "Guest" }
        if let email = user?.email {
            return email.split(separator: "@").first.map(String.init) ?? "Athlete"
        }
        return "Athlete"
    }

    private var streak: Int { betterFit.socialManager.getCurrentStreak() }
    private var recovery: Int {
        Int(betterFit.bodyMapManager.getOverallRecoveryPercentage().rounded())
    }

    private var history: [Workout] {
        betterFit.getWorkoutHistory()
    }

    private var heatmapValues: [Int] {
        var values = Array(repeating: 0, count: 22 * 7)
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        for workout in history {
            let days = cal.dateComponents([.day], from: cal.startOfDay(for: workout.date), to: today).day ?? 0
            guard days >= 0, days < values.count else { continue }
            values[values.count - 1 - days] = min(4, values[values.count - 1 - days] + 1)
        }
        if history.isEmpty {
            for index in 0..<values.count where index % 4 == 0 { values[index] = (index % 4) + 1 }
        }
        return values
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                identity
                stats
                weeklyTargets
                records
                achievements
                yearCard
                if isGuest {
                    signInPrompt
                }
            }
            .padding(.horizontal, BFSpacing.pageHorizontal)
            .padding(.bottom, 40)
        }
        .bfBackground(theme: theme)
        .navigationTitle("Me")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                }
                .accessibilityLabel("Settings")
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
                    .font(BFTypography.subheadlineEmphasis)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                onSignOut: {
                    showSettings = false
                    onLogout?()
                },
                onDeleteAccount: nil
            )
        }
    }

    // MARK: - Identity

    private var identity: some View {
        HStack(spacing: 14) {
            ProfileAvatar(name: displayName, isGuest: isGuest, size: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(BFTypography.title2)
                    .tracking(BFTypography.displayTracking)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                Text(isGuest ? "Training as guest" : "Member")
                    .font(BFTypography.footnote)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }
            Spacer()
            Text(isGuest ? "Guest" : "Pro")
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.accentInk)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(BFColors.accent))
        }
        .padding(.top, 8)
    }

    // MARK: - Stats

    private var stats: some View {
        HStack(spacing: 10) {
            BFStatTile(systemImage: "flame.fill", value: "\(streak)", label: "Day streak", tint: BFColors.accent)
            BFStatTile(systemImage: "dumbbell.fill", value: volumeLabel, label: "Volume", tint: BFColors.accent)
            BFStatTile(systemImage: "heart.fill", value: "\(recovery)%", label: "Recovery", tint: BFColors.accent)
        }
    }

    // MARK: - Weekly targets

    private var weeklyTargets: some View {
        VStack(alignment: .leading, spacing: 12) {
            BFSectionHeader(title: "Weekly targets") {
                Button("Edit") {}
                    .font(BFTypography.footnoteEmphasis)
                    .foregroundStyle(BFColors.accentText(for: colorScheme))
            }
            BFDSCard {
                VStack(spacing: 14) {
                    targetRow(label: "Workouts", value: Double(min(streak, 5)), target: 5, unit: "")
                    targetRow(label: "Volume", value: 41, target: 60, unit: "k")
                    targetRow(label: "Active minutes", value: 186, target: 250, unit: "")
                }
            }
        }
    }

    private func targetRow(label: String, value: Double, target: Double, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                Spacer()
                Text("\(format(value))")
                    .font(BFTypography.subheadlineEmphasis)
                    .monospacedDigit()
                Text("/ \(format(target))\(unit)")
                    .font(BFTypography.subheadline)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                    .monospacedDigit()
            }
            BFBar(progress: target > 0 ? value / target : 0)
        }
    }

    // MARK: - Records

    private var records: some View {
        VStack(alignment: .leading, spacing: 12) {
            BFSectionHeader(title: "Personal records")
            BFDSCard(padding: 12) {
                VStack(spacing: 0) {
                    recordRow(name: "Trap bar deadlift", value: "345 lb", when: "2 weeks ago")
                    Divider().opacity(0.3)
                    recordRow(name: "Bench press", value: "205 lb", when: "Last month")
                    Divider().opacity(0.3)
                    recordRow(name: "Back squat", value: "285 lb", when: "Last month")
                }
            }
        }
    }

    private func recordRow(name: String, value: String, when: String) -> some View {
        BFListRow(systemImage: "trophy.fill", title: name, subtitle: when, iconTint: BFColors.accent) {
            Text(value)
                .font(BFTypography.subheadlineEmphasis)
                .monospacedDigit()
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
        }
    }

    // MARK: - Achievements

    private var achievements: some View {
        let items: [(icon: String, title: String, done: Bool)] = [
            ("medal.fill", "Ten in a row", true),
            ("dumbbell.fill", "Bodyweight bench", true),
            ("sunrise.fill", "Five 6am sessions", false),
            ("mountain.2.fill", "100k lb month", false),
        ]
        return VStack(alignment: .leading, spacing: 12) {
            BFSectionHeader(title: "Achievements") {
                Text("2/4")
                    .font(BFTypography.caption)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    BFDSCard(padding: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(
                                    item.done
                                        ? BFColors.accentText(for: colorScheme)
                                        : BFColors.textTertiary(for: colorScheme)
                                )
                            Text(item.title)
                                .font(BFTypography.footnoteEmphasis)
                                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            Text(item.done ? "Earned" : "Locked")
                                .font(BFTypography.caption)
                                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(item.done ? 1 : 0.45)
                    }
                }
            }
        }
    }

    // MARK: - Year

    private var yearCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            BFSectionHeader(title: "Your year")
            BFDSCard {
                VStack(alignment: .leading, spacing: 12) {
                    ProfileYearHeatmap(values: heatmapValues)
                    Text("\(history.count > 0 ? history.count : 112) workouts logged. Keep the run going.")
                        .font(BFTypography.footnote)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
        }
    }

    private var signInPrompt: some View {
        Button {
            onShowSignIn()
        } label: {
            Text("Sign in to sync")
        }
        .buttonStyle(.bfPrimary)
        .padding(.top, 8)
    }

    // MARK: - Format

    private var volumeLabel: String {
        let vol = history.reduce(0.0) { sum, workout in
            sum + workout.exercises.reduce(0.0) { exerciseTotal, ex in
                exerciseTotal + ex.sets.reduce(0.0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }
            }
        }
        if vol >= 1000 { return String(format: "%.0fk", vol / 1000) }
        return vol > 0 ? String(format: "%.0f", vol) : "41k"
    }

    private func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(format: "%.0f", value)
    }
}

// MARK: - Compact year heatmap

private struct ProfileYearHeatmap: View {
    let values: [Int]
    @Environment(\.colorScheme) private var scheme
    private let rows = 7
    private let cell: CGFloat = 9
    private let gap: CGFloat = 3

    var body: some View {
        let cols = max(1, Int(ceil(Double(values.count) / Double(rows))))
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: gap) {
                ForEach(0..<cols, id: \.self) { col in
                    VStack(spacing: gap) {
                        ForEach(0..<rows, id: \.self) { row in
                            let idx = col * rows + row
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(BFColors.heat(level: idx < values.count ? values[idx] : 0, for: scheme))
                                .frame(width: cell, height: cell)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            betterFit: BetterFit(),
            theme: .defaultTheme,
            isGuest: false,
            user: nil,
            onShowSignIn: {},
            onLogout: {}
        )
    }
    .preferredColorScheme(.dark)
}
