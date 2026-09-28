import BetterFit
import SwiftUI

// MARK: - Targets — weekly goals, week plan, streak, records

struct TargetsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let betterFit: BetterFit
    let theme: AppTheme
    var planManager: WorkoutPlanManager?

    // MARK: - Data

    private var weekStart: Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
    }

    private var weekWorkouts: [Workout] {
        betterFit.getWorkoutHistory().filter { $0.isCompleted && $0.date >= weekStart }
    }

    private var trailingWorkouts: [Workout] {
        guard let start = Calendar.current.date(byAdding: .day, value: -28, to: weekStart) else { return [] }
        return betterFit.getWorkoutHistory().filter {
            $0.isCompleted && $0.date >= start && $0.date < weekStart
        }
    }

    private var workoutsDone: Int {
        weekWorkouts.count
    }

    private var plannedWorkouts: Int {
        weekDays.filter { $0.workoutType != nil || !$0.exercises.isEmpty }.count
    }

    private var workoutsTarget: Int? {
        if plannedWorkouts > 0 { return plannedWorkouts }
        let average = Double(trailingWorkouts.count) / 4
        return average.rounded() >= 1 ? Int(average.rounded()) : nil
    }

    private var weekVolumeK: Double {
        weekWorkouts.reduce(0.0) { $0 + loadVolume($1) } / 1000
    }

    private var weekTimeH: Double {
        weekWorkouts.reduce(0.0) { $0 + ($1.duration ?? 0) } / 3600
    }

    private var volumeTargetK: Double? {
        let total = trailingWorkouts.reduce(0.0) { $0 + loadVolume($1) } / 1000
        return total > 0 ? total / 4 : nil
    }

    private var timeTargetH: Double? {
        let total = trailingWorkouts.reduce(0.0) { $0 + ($1.duration ?? 0) } / 3600
        return total > 0 ? total / 4 : nil
    }

    private var hasLoadData: Bool {
        betterFit.getWorkoutHistory().contains { loadVolume($0) > 0 }
    }

    private var hasDurationData: Bool {
        betterFit.getWorkoutHistory().contains { ($0.duration ?? 0) > 0 }
    }

    private func loadVolume(_ workout: Workout) -> Double {
        workout.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + (Double($1.reps) * ($1.weight ?? 0)) }
        }
    }

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
        let target: Double?
        let unit: String
    }

    private var targets: [WeeklyTarget] {
        var rows = [
            WeeklyTarget(
                label: "Workouts",
                value: Double(workoutsDone),
                target: workoutsTarget.map { Double($0) },
                unit: ""
            )
        ]
        if hasLoadData {
            rows.append(WeeklyTarget(
                label: "Volume",
                value: weekVolumeK,
                target: volumeTargetK,
                unit: "k"
            ))
        }
        if hasDurationData {
            rows.append(WeeklyTarget(
                label: "Time",
                value: weekTimeH,
                target: timeTargetH,
                unit: "h"
            ))
        }
        return rows
    }

    private var targetsSectionMeta: String {
        let fromPlan = plannedWorkouts > 0
        let fromAverage = volumeTargetK != nil
            || timeTargetH != nil
            || (!fromPlan && workoutsTarget != nil)
        switch (fromPlan, fromAverage) {
        case (true, true): return "Goals from your plan and 4-week averages"
        case (true, false): return "Goals from your plan"
        case (false, true): return "Goals from your 4-week averages"
        default: return "This week so far"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                weekSlab

                VStack(alignment: .leading, spacing: 0) {
                    BFSectionRule(label: "Weekly targets", trailing: targetsSectionMeta)
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
        }
    }

    // MARK: - Slab

    private var weekSlab: some View {
        BFSlab {
            VStack(alignment: .leading, spacing: 0) {
                BFEyebrow(text: "This week", color: BFColors.identityInk.opacity(0.6))
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(workoutsDone)")
                        .font(BFTypography.readout)
                        .foregroundStyle(BFColors.identityInk)
                    if let workoutsTarget {
                        Text("/ \(workoutsTarget)")
                            .font(BFTypography.screenTitle)
                            .monospacedDigit()
                            .foregroundStyle(BFColors.identityInk.opacity(0.5))
                    }
                }
                .padding(.top, 10)

                Text(slabMessage)
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.identityInk)
                    .padding(.top, 14)
                    .fixedSize(horizontal: false, vertical: true)

                if let workoutsTarget {
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
    }

    private var slabMessage: String {
        guard let workoutsTarget else {
            return "Workouts done this week."
        }
        let left = max(0, workoutsTarget - workoutsDone)
        if left == 0 {
            return "Weekly goal reached. Good work."
        }
        if left == 1 {
            return "Workouts done. One more reaches your goal."
        }
        return "Workouts done. \(left) more reach your goal."
    }

    // MARK: - Target row

    private func targetRow(_ item: WeeklyTarget) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(item.label)
                    .font(BFTypography.bodyEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                Spacer()
                Text(BFFormat.trimmed(item.value) + item.unit)
                    .font(BFTypography.subheadlineEmphasis)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                if let target = item.target {
                    Text("/ \(BFFormat.trimmed(target))\(item.unit)")
                        .font(BFTypography.footnote)
                        .monospacedDigit()
                        .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                }
            }
            if let target = item.target, target > 0 {
                let pct = item.value / target
                BFBar(progress: pct)
                Text("\(Int((pct * 100).rounded()))% of the week")
                    .font(BFTypography.caption)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }
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

}

#Preview {
    NavigationStack {
        TargetsView(betterFit: BetterFit(), theme: .defaultTheme)
    }
    .preferredColorScheme(.dark)
}
