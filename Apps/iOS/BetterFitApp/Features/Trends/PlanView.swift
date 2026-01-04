import BetterFit
import Charts
import SwiftUI

// MARK: - Plan View

struct PlanView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    let planManager: WorkoutPlanManager

    @State private var map: BodyMapRecovery = .init()
    @State private var showExercisePicker = false
    @State private var selectedDayIndex: Int = 0
    @State private var showAdjustSetsSheet = false
    @State private var exerciseToAdjust: PlannedExercise?

    // MARK: - Computed Properties

    private var weekDays: [WorkoutPlanDay] {
        planManager.getCurrentWeekDays()
    }

    private var selectedPlanDay: WorkoutPlanDay? {
        guard weekDays.indices.contains(selectedDayIndex) else { return nil }
        return weekDays[selectedDayIndex]
    }

    private var plannedExercises: [PlannedExercise] {
        selectedPlanDay?.exercises ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Compact week strip + quick stats
                weekStripWithStats

                // Selected day's exercises (main focus)
                selectedDaySection

                // Compact recovery row
                compactRecoveryRow

                Spacer(minLength: 100)
            }
            .padding(16)
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Plan")
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView(theme: theme) { exercises in
                addExercises(exercises)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showAdjustSetsSheet) {
            if let exercise = exerciseToAdjust {
                AdjustSetsSheet(theme: theme, exercise: exercise) { updated in
                    if let date = selectedPlanDay?.date,
                        let index = plannedExercises.firstIndex(where: { $0.id == exercise.id })
                    {
                        var exercises = plannedExercises
                        exercises[index] = updated
                        planManager.updateExercises(for: date, exercises: exercises)
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            refresh()
            if let todayIndex = weekDays.firstIndex(where: { $0.isToday }) {
                selectedDayIndex = todayIndex
            }
        }
    }

    // MARK: - Week Strip with Stats

    private var weekStripWithStats: some View {
        VStack(spacing: 16) {
            // Week selector
            HStack(spacing: 6) {
                ForEach(Array(weekDays.enumerated()), id: \.element.id) { index, day in
                    compactDayButton(day, index: index)
                }
            }

            // Inline stats row
            HStack(spacing: 0) {
                inlineStat(value: "4/5", label: "workouts")
                Spacer(minLength: 0)
                inlineStat(value: "12.4K", label: "lbs lifted")
                Spacer(minLength: 0)
                inlineStat(value: "3.2h", label: "trained")
            }
            .padding(.horizontal, 4)
        }
    }

    @ViewBuilder
    private func compactDayButton(_ day: WorkoutPlanDay, index: Int) -> some View {
        let isSelected = index == selectedDayIndex
        let hasWorkout = day.workoutType != nil || !day.exercises.isEmpty

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDayIndex = index
            }
        } label: {
            VStack(spacing: 4) {
                Text(day.dayOfWeek.prefix(1))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(day.isToday ? theme.accent : .secondary)

                ZStack {
                    Circle()
                        .fill(isSelected ? theme.accent : Color.clear)
                        .frame(width: 32, height: 32)

                    if day.isToday && !isSelected {
                        Circle()
                            .stroke(theme.accent, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }

                    Text("\(day.dayNumber)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected ? .white : .primary)
                }

                // Workout indicator dot
                Circle()
                    .fill(hasWorkout ? theme.accent : theme.cardStroke)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func inlineStat(value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selected Day Section

    private var selectedDaySection: some View {
        let dayName =
            selectedPlanDay?.isToday == true
            ? "Today"
            : (selectedPlanDay?.fullDayName ?? "")

        return VStack(alignment: .leading, spacing: 12) {
            // Day header with add button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayName)
                        .font(.title3.weight(.bold))

                    if let workoutType = selectedPlanDay?.workoutType {
                        Text(workoutType.rawValue)
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                    } else if selectedPlanDay?.isRest == true {
                        Text("Rest Day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)

                Button {
                    showExercisePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                }
            }

            // Exercises or empty state
            if plannedExercises.isEmpty {
                emptyDayCard
            } else {
                exercisesList
            }
        }
    }

    private var emptyDayCard: some View {
        Button {
            showExercisePicker = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundStyle(theme.accent)

                Text("Add exercises")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.cardStroke, style: StrokeStyle(lineWidth: 1, dash: [6]))
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private var exercisesList: some View {
        UnifiedExerciseTimeline(
            exercises: plannedExercises,
            selectedIndex: nil,
            theme: theme,
            showHeader: false,
            headerTitle: "",
            onSelect: { _ in },
            onDelete: { index in
                if let date = selectedPlanDay?.date {
                    withAnimation {
                        planManager.removeExercise(at: index, from: date)
                    }
                }
            },
            onReplace: { _ in },
            onSuperset: { _ in },
            onComplete: nil,
            onMove: { indices, newOffset in
                if let date = selectedPlanDay?.date {
                    withAnimation {
                        planManager.moveExercise(from: indices, to: newOffset, on: date)
                    }
                }
            },
            onAdd: { showExercisePicker = true },
            onAdjustSets: { index in
                exerciseToAdjust = plannedExercises[index]
                showAdjustSetsSheet = true
            }
        )
        .frame(height: CGFloat(min(plannedExercises.count, 5)) * 88)
    }

    // MARK: - Compact Recovery Row

    private var compactRecoveryRow: some View {
        let overall = betterFit.bodyMapManager.getOverallRecoveryPercentage()

        return HStack(spacing: 12) {
            // Recovery ring
            ZStack {
                ProgressRing(progress: overall / 100.0, lineWidth: 4, theme: theme)
                    .frame(width: 36, height: 36)

                Text("\(Int(overall))%")
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Recovery")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(recoveryHeadline(overall))
                    .font(.caption.weight(.semibold))
            }

            Spacer(minLength: 0)

            // Muscle status dots
            HStack(spacing: 6) {
                ForEach(BodyRegion.allCases.filter { $0 != .other }.prefix(6), id: \.self) {
                    region in
                    let status =
                        map.regions[region]
                        ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)
                    Circle()
                        .fill(statusColor(status))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(theme.cardStroke, lineWidth: 1)
                }
        }
    }

    // MARK: - Helpers

    private func recoveryHeadline(_ overall: Double) -> String {
        switch overall {
        case 0..<35: return "Rest recommended"
        case 35..<70: return "Moderate intensity"
        default: return "Ready to push"
        }
    }

    private func refresh() {
        map = betterFit.bodyMapManager.getRecoveryMap()
    }

    private func addExercises(_ exercises: [SelectableExercise]) {
        guard let selectedDay = selectedPlanDay else { return }
        for exercise in exercises {
            let newExercise = PlannedExercise(
                name: exercise.name,
                category: exercise.category,
                sets: 3,
                reps: "8-12",
                targetWeight: nil,
                muscleGroups: exercise.muscleGroups
            )
            planManager.addExercise(newExercise, to: selectedDay.date)
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
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    return NavigationStack {
        PlanView(betterFit: BetterFit(), theme: .forest, planManager: WorkoutPlanManager())
    }
}
