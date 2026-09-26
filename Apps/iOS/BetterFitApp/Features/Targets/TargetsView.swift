import BetterFit
import SwiftUI

// MARK: - Targets — weekly goals, week plan, streak, records

struct TargetsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let betterFit: BetterFit
    let theme: AppTheme
    var planManager: WorkoutPlanManager?

    private var workoutsDone: Int {
        let cal = Calendar.current
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return betterFit.getWorkoutHistory().filter {
            $0.isCompleted && $0.date >= weekStart
        }.count
    }

    private var workoutsTarget: Int { 4 }

    private var streakCurrent: Int {
        betterFit.socialManager.getCurrentStreak()
    }

    private var streakBest: Int {
        max(betterFit.socialManager.getLongestStreak(), streakCurrent)
    }

    private var weekDays: [WorkoutPlanDay] {
        planManager?.getCurrentWeekDays() ?? []
    }

    // MARK: - Weekly targets

    private struct WeeklyTarget {
        let label: String
        let value: Double
        let target: Double
        let unit: String
    }

    private var targets: [WeeklyTarget] {
        [
            WeeklyTarget(label: "Workouts", value: Double(workoutsDone), target: Double(workoutsTarget), unit: ""),
            WeeklyTarget(label: "Volume", value: 48.2, target: 80, unit: "k"),
            WeeklyTarget(label: "Time", value: 2.4, target: 4, unit: "h"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                weekSlab

                VStack(alignment: .leading, spacing: 0) {
                    BFSectionRule(label: "Weekly targets", trailing: "\(targets.count) set")
                    ForEach(Array(targets.enumerated()), id: \.offset) { _, item in
                        targetRow(item)
                    }

                    if !weekDays.isEmpty {
                        BFSectionRule(label: "The week", trailing: "Mon–Sun")
                        ForEach(weekDays) { day in
                            weekDayRow(day)
                        }
                    }

                    BFSectionRule(label: "Streak")
                    BFLedgerRow(
                        systemImage: "flame.fill",
                        title: "Current streak",
                        meta: "Best is \(streakBest) days"
                    ) {
                        BFLedgerTrailing(value: "\(streakCurrent) days")
                    }

                    BFSectionRule(label: "Records this month")
                    BFLedgerRow(
                        systemImage: "medal.fill",
                        title: "Keep training",
                        meta: "Personal records appear here"
                    ) {
                        EmptyView()
                    }
                }
                .padding(.horizontal, BFSpacing.pageHorizontal)
                .padding(.bottom, 110)
            }
        }
        .bfBackground(theme: theme)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Targets")
                    .font(BFTypography.screenTitle)
                    .tracking(BFTypography.displayTracking)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {}
                    .font(BFTypography.subheadlineEmphasis)
                    .foregroundStyle(BFColors.accentText(for: colorScheme))
            }
        }
    }

    // MARK: - Slab

    private var weekSlab: some View {
        let left = max(0, workoutsTarget - workoutsDone)
        return BFSlab {
            VStack(alignment: .leading, spacing: 0) {
                BFEyebrow(text: "This week", color: BFColors.identityInk.opacity(0.6))
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(workoutsDone)")
                        .font(BFTypography.readout)
                        .foregroundStyle(BFColors.identityInk)
                    Text("/ \(workoutsTarget)")
                        .font(BFTypography.screenTitle)
                        .monospacedDigit()
                        .foregroundStyle(BFColors.identityInk.opacity(0.5))
                }
                .padding(.top, 10)

                Text(left == 0
                   ? "Weekly goal reached. Good work."
                   : left == 1
                   ? "Workouts done. One more reaches your goal."
                   : "Workouts done. \(left) more reach your goal.")
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.identityInk)
                    .padding(.top, 14)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    ForEach(0..<workoutsTarget, id: \.self) { index in
                        Rectangle()
                            .fill(index < workoutsDone ? BFColors.identityInk : BFColors.identityInk.opacity(0.22))
                            .frame(height: 8)
                    }
                }
                .padding(.top, 18)
            }
        }
    }

    // MARK: - Target row

    private func targetRow(_ item: WeeklyTarget) -> some View {
        let pct = item.target > 0 ? item.value / item.target : 0
        return VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(item.label)
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                Spacer()
                Text(format(item.value) + item.unit)
                    .font(BFTypography.subheadlineEmphasis)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                Text("/ \(format(item.target))\(item.unit)")
                    .font(BFTypography.footnote)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            BFBar(progress: pct)
            Text("\(Int((pct * 100).rounded()))% of the week")
                .font(BFTypography.caption)
                .monospacedDigit()
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
        }
        .padding(.vertical, 14)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BFColors.separator(for: colorScheme))
                .frame(height: 1)
        }
    }

    // MARK: - Week day

    private func weekDayRow(_ day: WorkoutPlanDay) -> some View {
        let name: String = {
            if day.isRest { return "Rest" }
            if let type = day.workoutType { return type.rawValue }
            if day.exercises.isEmpty { return "Rest" }
            return "Session"
        }()
        let isRest = day.isRest || (day.exercises.isEmpty && day.workoutType == nil)
        return BFLedgerRow(
            gutter: dayLabel(day.date),
            gutterAccent: day.isToday,
            title: name,
            meta: day.isToday ? "Today" : day.isCompleted ? "Completed" : isRest ? "Scheduled rest" : "Scheduled",
            dim: isRest
        ) {
            if day.isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(BFColors.accentText(for: colorScheme))
            }
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return String(formatter.string(from: date).prefix(2)).uppercased()
    }

    private func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

#Preview {
    NavigationStack {
        TargetsView(betterFit: BetterFit(), theme: .defaultTheme)
    }
    .preferredColorScheme(.dark)
}
