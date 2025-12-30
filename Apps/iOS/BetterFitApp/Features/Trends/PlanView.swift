import BetterFit
import Charts
import SwiftUI

// MARK: - Routine Day

struct RoutineDay: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let dayNumber: Int
    let isToday: Bool
    var workoutType: String?
    var isRest: Bool = false
}

// MARK: - Planned Exercise

struct PlannedExercise: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let targetWeight: String?
}

// MARK: - AI Suggestion

struct AISuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let actionLabel: String
}

// MARK: - Plan View

struct PlanView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var map: BodyMapRecovery = .init()
    @State private var showExercisePicker = false
    @State private var plannedExercises: [PlannedExercise] = []
    @State private var selectedDayIndex: Int = 2  // Today (Wednesday)
    @State private var showAIPlanner = false

    // MARK: - Mock Data

    private var weekDays: [RoutineDay] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        return [
            RoutineDay(
                dayOfWeek: "Mon", dayNumber: 30, isToday: false, workoutType: "Push", isRest: false),
            RoutineDay(
                dayOfWeek: "Tue", dayNumber: 31, isToday: false, workoutType: nil, isRest: true),
            RoutineDay(
                dayOfWeek: "Wed", dayNumber: 1, isToday: true, workoutType: "Pull", isRest: false),
            RoutineDay(
                dayOfWeek: "Thu", dayNumber: 2, isToday: false, workoutType: "Legs", isRest: false),
            RoutineDay(
                dayOfWeek: "Fri", dayNumber: 3, isToday: false, workoutType: nil, isRest: true),
            RoutineDay(
                dayOfWeek: "Sat", dayNumber: 4, isToday: false, workoutType: "Upper", isRest: false),
            RoutineDay(
                dayOfWeek: "Sun", dayNumber: 5, isToday: false, workoutType: nil, isRest: true),
        ]
    }

    private var aiSuggestions: [AISuggestion] {
        [
            AISuggestion(
                title: "Generate Weekly Plan",
                description: "AI creates a balanced routine based on your goals and recovery",
                icon: "sparkles",
                actionLabel: "Generate"
            ),
            AISuggestion(
                title: "Optimize Recovery",
                description: "Adjust your schedule for better muscle recovery",
                icon: "arrow.triangle.2.circlepath",
                actionLabel: "Optimize"
            ),
            AISuggestion(
                title: "Progressive Overload",
                description: "Suggest weight increases based on your recent performance",
                icon: "chart.line.uptrend.xyaxis",
                actionLabel: "Calculate"
            ),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header

                headerSection

                // MARK: - PT Recommendation

                ptRecommendationCard

                // MARK: - Weekly Schedule

                weekScheduleSection

                // MARK: - Today's Plan

                if !plannedExercises.isEmpty || selectedDayIndex == 2 {
                    todaysPlanSection
                }

                // MARK: - Quick AI Actions

                aiActionsSection

                // MARK: - Recovery Insights

                recoveryInsightsSection

                // MARK: - Weekly Stats

                weeklyStatsSection

                Spacer(minLength: 40)
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
        .onAppear {
            refresh()
            loadDemoExercises()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Training Plan")
                .bfHeading(theme: theme, size: 28, relativeTo: .largeTitle)

            Text("Week of Dec 30 - Jan 5")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - PT Recommendation Card

    private var ptRecommendationCard: some View {
        BFCard(theme: theme) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Coach Recommendation")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.accent)

                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                    }

                    Text("Your back is fully recovered. Today's a great day for Pull exercises!")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Week Schedule Section

    private var weekScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                Spacer(minLength: 0)

                Button {
                    showAIPlanner = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("AI Plan")
                            .font(.caption.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.accent.opacity(0.2)))
                    .foregroundStyle(theme.accent)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(weekDays.enumerated()), id: \.element.id) { index, day in
                        dayCard(day, index: index)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCard(_ day: RoutineDay, index: Int) -> some View {
        let isSelected = index == selectedDayIndex

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDayIndex = index
            }
        } label: {
            VStack(spacing: 8) {
                Text(day.dayOfWeek)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(day.isToday ? theme.accent : .secondary)

                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? theme.accent
                                : (day.isToday ? theme.accent.opacity(0.2) : Color.clear)
                        )
                        .frame(width: 36, height: 36)

                    Text("\(day.dayNumber)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(
                            isSelected ? .white : (day.isToday ? theme.accent : .primary))
                }

                if let workoutType = day.workoutType {
                    Text(workoutType)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(theme.accent)
                } else if day.isRest {
                    Text("Rest")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("—")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 60)
            .padding(.vertical, 12)
            .background {
                let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
                shape
                    .fill(.regularMaterial)
                    .overlay {
                        shape.stroke(
                            isSelected ? theme.accent : theme.cardStroke,
                            lineWidth: isSelected ? 2 : 1
                        )
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Plan Section

    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Exercises")
                    .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                Spacer(minLength: 0)

                Button {
                    showExercisePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                        Text("Add")
                            .font(.caption.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.accent))
                    .foregroundStyle(.white)
                }
            }

            if plannedExercises.isEmpty {
                emptyPlanCard
            } else {
                VStack(spacing: 8) {
                    ForEach(plannedExercises) { exercise in
                        plannedExerciseRow(exercise)
                    }
                }
            }
        }
    }

    private var emptyPlanCard: some View {
        BFCard(theme: theme) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(theme.accent.opacity(0.5))

                Text("No exercises planned")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("Add exercises or let AI generate a plan for you")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    showExercisePicker = true
                } label: {
                    Text("Add Exercises")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(theme.accent))
                        .foregroundStyle(.white)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func plannedExerciseRow(_ exercise: PlannedExercise) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "dumbbell.fill")
                    .font(.subheadline)
                    .foregroundStyle(theme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))

                HStack(spacing: 8) {
                    Text("\(exercise.sets) sets × \(exercise.reps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let weight = exercise.targetWeight {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(weight)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.accent)
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
        }
    }

    // MARK: - AI Actions Section

    private var aiActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(theme.accent)

                Text("AI Trainer")
                    .bfHeading(theme: theme, size: 20, relativeTo: .headline)
            }

            VStack(spacing: 10) {
                ForEach(aiSuggestions) { suggestion in
                    aiSuggestionCard(suggestion)
                }
            }
        }
    }

    @ViewBuilder
    private func aiSuggestionCard(_ suggestion: AISuggestion) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: suggestion.icon)
                    .font(.subheadline)
                    .foregroundStyle(theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.subheadline.weight(.semibold))

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Button {
                // AI action
            } label: {
                Text(suggestion.actionLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.accent.opacity(0.2)))
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
        }
    }

    // MARK: - Recovery Insights Section

    private var recoveryInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery Status")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            BFCard(theme: theme) {
                VStack(spacing: 12) {
                    overallRecoveryRow

                    Divider().opacity(0.3)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                        ],
                        spacing: 10
                    ) {
                        ForEach(BodyRegion.allCases.filter { $0 != .other }.prefix(6), id: \.self) {
                            region in
                            miniRegionCard(region)
                        }
                    }
                }
            }
        }
    }

    private var overallRecoveryRow: some View {
        let overall = betterFit.bodyMapManager.getOverallRecoveryPercentage()
        let progress = overall / 100.0

        return HStack(spacing: 14) {
            ZStack {
                ProgressRing(progress: progress, lineWidth: 6, theme: theme)
                    .frame(width: 50, height: 50)

                Text("\(Int(overall))%")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Overall Recovery")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(overallHeadline(overall))
                    .font(.subheadline.weight(.semibold))
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func miniRegionCard(_ region: BodyRegion) -> some View {
        let status = map.regions[region] ?? betterFit.bodyMapManager.getRecoveryStatus(for: region)

        VStack(spacing: 6) {
            Circle()
                .fill(statusColor(status))
                .frame(width: 10, height: 10)

            Text(regionName(region))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(statusColor(status).opacity(0.1))
        }
    }

    // MARK: - Weekly Stats Section

    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week's Progress")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                statCard(
                    icon: "flame.fill", label: "Workouts", value: "4", target: "/ 5", color: .orange
                )
                statCard(
                    icon: "scalemass.fill", label: "Volume", value: "12.4K", target: "lbs",
                    color: .blue)
                statCard(
                    icon: "clock.fill", label: "Time", value: "3.2", target: "hrs", color: .purple)
                statCard(
                    icon: "arrow.up.circle.fill", label: "PRs", value: "2", target: "new",
                    color: theme.accent)
            }
        }
    }

    @ViewBuilder
    private func statCard(icon: String, label: String, value: String, target: String, color: Color)
        -> some View
    {
        BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)

                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2.weight(.bold))

                    Text(target)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func overallHeadline(_ overall: Double) -> String {
        switch overall {
        case 0..<35:
            return "Take it easy today"
        case 35..<70:
            return "Ready for moderate work"
        default:
            return "Ready to push hard!"
        }
    }

    private func refresh() {
        map = betterFit.bodyMapManager.getRecoveryMap()
    }

    private func loadDemoExercises() {
        plannedExercises = [
            PlannedExercise(name: "Deadlift", sets: 4, reps: "5", targetWeight: "225 lbs"),
            PlannedExercise(name: "Pull-ups", sets: 4, reps: "8-10", targetWeight: nil),
            PlannedExercise(name: "Barbell Row", sets: 3, reps: "8", targetWeight: "135 lbs"),
            PlannedExercise(name: "Face Pulls", sets: 3, reps: "15", targetWeight: "30 lbs"),
        ]
    }

    private func addExercises(_ exercises: [SelectableExercise]) {
        let newExercises = exercises.map { exercise in
            PlannedExercise(
                name: exercise.name,
                sets: 3,
                reps: "8-12",
                targetWeight: nil
            )
        }
        plannedExercises.append(contentsOf: newExercises)
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
        PlanView(betterFit: BetterFit(), theme: .forest)
    }
}
