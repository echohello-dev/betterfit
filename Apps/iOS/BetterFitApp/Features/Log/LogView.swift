import BetterFit
import SwiftUI

// MARK: - Log — streak, consistency, month ledger

struct LogView: View {
    @Environment(\.colorScheme) private var colorScheme
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var showAddPast = false

    private var streak: Int {
        betterFit.socialManager.getCurrentStreak()
    }

    private var history: [Workout] {
        betterFit.getWorkoutHistory().sorted { $0.date > $1.date }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }

    private var heatmapValues: [Int] {
        var values = Array(repeating: 0, count: 26 * 7)
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        for workout in history {
            let day = cal.startOfDay(for: workout.date)
            let daysAgo = cal.dateComponents([.day], from: day, to: today).day ?? 0
            guard daysAgo >= 0, daysAgo < values.count else { continue }
            let idx = values.count - 1 - daysAgo
            values[idx] = min(4, values[idx] + 1)
        }
        return values
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BFReadout(
                    value: "\(streak)",
                    unit: "days",
                    label: "Current streak",
                    note: streakNote
                )

                BFSectionRule(label: "Consistency", trailing: "26 weeks")
                LogContributionHeatmap(values: heatmapValues)
                    .padding(.vertical, 4)

                BFSectionRule(
                    label: monthTitle,
                    trailing: "\(monthSessions.count) sessions"
                )

                if monthLedger.isEmpty {
                    BFEmptyState(
                        systemImage: "calendar",
                        title: "No sessions this month",
                        message: "Completed workouts show up here."
                    )
                } else {
                    ForEach(Array(monthLedger.enumerated()), id: \.offset) { _, entry in
                        dayRow(entry)
                    }
                }

                BFAddRow(label: "Log a past workout") {
                    showAddPast = true
                }

                BFSectionRule(label: "All time")
                BFLedgerRow(systemImage: "dumbbell.fill", title: "Sessions") {
                    BFLedgerTrailing(value: "\(history.count)")
                }
                BFLedgerRow(systemImage: "scalemass.fill", title: "Volume lifted") {
                    BFLedgerTrailing(value: totalVolumeLabel, meta: "kg")
                }
                BFLedgerRow(systemImage: "clock.fill", title: "Time training") {
                    BFLedgerTrailing(value: totalHoursLabel, meta: totalHoursUnit)
                }
            }
            .padding(.horizontal, BFSpacing.pageHorizontal)
            .padding(.bottom, 110)
        }
        .bfBackground(theme: theme)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Log")
                    .font(BFTypography.screenTitle)
                    .tracking(BFTypography.displayTracking)
            }
        }
        .sheet(isPresented: $showAddPast) {
            Text("Log a past workout")
                .presentationDetents([.medium])
        }
    }

    // MARK: - Month ledger

    private struct DayEntry: Identifiable {
        let id = UUID()
        let day: Int
        let name: String
        let meta: String?
        let volume: String?
        let isRest: Bool
        let isToday: Bool
        let inStreak: Bool
    }

    private var monthSessions: [Workout] {
        let cal = Calendar.current
        let now = Date()
        return history.filter { cal.isDate($0.date, equalTo: now, toGranularity: .month) }
    }

    private var monthLedger: [DayEntry] {
        let cal = Calendar.current
        var entries: [DayEntry] = []

        for (idx, workout) in monthSessions.prefix(14).enumerated() {
            let day = cal.component(.day, from: workout.date)
            let mins = Int((workout.duration ?? 0) / 60)
            let vol = workout.exercises.reduce(0.0) { sum, ex in
                sum + ex.sets.reduce(0.0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }
            }
            entries.append(DayEntry(
                day: day,
                name: workout.name,
                meta: mins > 0 ? "\(mins) min · \(workout.exercises.count) exercises" : "\(workout.exercises.count) exercises",
                volume: vol > 0 ? String(format: "%.1fk", vol / 1000) : nil,
                isRest: false,
                isToday: cal.isDateInToday(workout.date),
                inStreak: idx < max(streak, 1)
            ))
        }
        return entries
    }

    private func dayRow(_ entry: DayEntry) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(entry.inStreak ? BFColors.accent : Color.clear)
                    .frame(width: 32, height: 32)
                Text("\(entry.day)")
                    .font(.system(size: 14, weight: .bold).monospacedDigit())
                    .foregroundStyle(
                        entry.inStreak
                            ? BFColors.accentInk
                            : entry.isToday
                            ? BFColors.accentText(for: colorScheme)
                            : BFColors.textTertiary(for: colorScheme)
                    )
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.name)
                        .font(BFTypography.bodyEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    Spacer()
                    if let volume = entry.volume {
                        HStack(spacing: 2) {
                            Text(volume)
                                .font(BFTypography.subheadlineEmphasis)
                                .monospacedDigit()
                            Text("kg")
                                .font(BFTypography.caption)
                                .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                        }
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    }
                }
                if let meta = entry.meta {
                    Text(meta)
                        .font(BFTypography.footnote)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.vertical, 14)
        .opacity(entry.isRest ? 0.45 : 1)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
    }

    // MARK: - Stats

    private var streakNote: String {
        if streak == 0 {
            return "Start a session today to open a new run."
        }
        return "Keep going. Consistency compounds — one session at a time."
    }

    private var totalVolumeLabel: String {
        let vol = history.reduce(0.0) { sum, workout in
            sum + workout.exercises.reduce(0.0) { exerciseTotal, ex in
                exerciseTotal + ex.sets.reduce(0.0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }
            }
        }
        if vol >= 1_000_000 { return String(format: "%.2fM", vol / 1_000_000) }
        if vol >= 1000 { return String(format: "%.0fk", vol / 1000) }
        return vol > 0 ? String(format: "%.0f", vol) : "—"
    }

    private var totalHoursLabel: String {
        let secs = history.reduce(0.0) { $0 + ($1.duration ?? 0) }
        let hours = secs / 3600
        return hours > 0 ? String(format: "%.0f", hours) : "—"
    }

    private var totalHoursUnit: String {
        totalHoursLabel == "1" ? "hour" : "hours"
    }
}

// MARK: - Compact contribution heatmap (Log)

private struct LogContributionHeatmap: View {
    let values: [Int]
    var cell: CGFloat = 9
    var gap: CGFloat = 3
    @Environment(\.colorScheme) private var scheme

    private let rows = 7

    var body: some View {
        let cols = max(1, Int(ceil(Double(values.count) / Double(rows))))
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("Training consistency heatmap")
    }
}

#Preview {
    NavigationStack {
        LogView(betterFit: BetterFit(), theme: .defaultTheme)
    }
    .preferredColorScheme(.dark)
}
