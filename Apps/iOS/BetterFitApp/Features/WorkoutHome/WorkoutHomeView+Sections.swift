import BetterFit
import SwiftUI

extension WorkoutHomeView {
    // MARK: - Sections

    var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.22))
                        .frame(width: 48, height: 48)
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Hello!")
                            .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                        Text(username)
                            .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                            .foregroundStyle(theme.accent)
                    }

                    Text("Regain your healthy body")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Compact Welcome (Active Workout)
    var compactWelcomeSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.22))
                    .frame(width: 36, height: 36)
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Workout in progress")
                    .font(.subheadline.weight(.semibold))
                Text(username)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Elapsed time (animated) - isolated view to prevent parent re-renders
            ElapsedTimeDisplay(
                betterFit: bf,
                theme: theme,
                elapsedTimeUpdateTrigger: $elapsedTimeUpdateTrigger,
                formatElapsed: formatElapsed
            )
        }
    }

    // MARK: - Compact Streak (Active Workout)
    var compactStreakSection: some View {
        HStack(spacing: 14) {
            Label {
                Text("\(currentStreak) day streak")
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(theme.accent)
            }

            Spacer()

            Button {
                showStreakSummary = true
            } label: {
                Text("View Details")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Workout Overview Section
    var workoutOverviewSection: some View {
        let overallRecovery = bf.bodyMapManager.getOverallRecoveryPercentage()
        let recoveryValue = Int(overallRecovery)
        let weekCount = workoutsThisWeek(date: selectedDate)
        let weeklyGoalTarget = 5
        let weeklyProgress =
            weeklyGoalTarget > 0
            ? Double(min(weekCount, weeklyGoalTarget)) / Double(weeklyGoalTarget)
            : 0

        let range = heatmapDateRange()
        let rangeStats = workoutRangeStats(start: range.start, end: range.end)
        let split = workoutCategorySplit(start: range.start, end: range.end)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(Int(weeklyProgress * 100))%")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                            .monospacedDigit()

                        Text("weekly goal")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer(minLength: 0)

                        Text("Weekly \(weekCount)/\(weeklyGoalTarget)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background { Capsule().fill(theme.cardBackground.opacity(0.35)) }
                            .overlay { Capsule().stroke(theme.cardStroke, lineWidth: 1) }
                    }

                    Text(overviewSummaryText(weeklyWorkouts: weekCount, recovery: recoveryValue))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 14) {
                        OverviewStat(
                            title: "This week",
                            value: "\(weekCount)",
                            systemImage: "calendar",
                            theme: theme
                        )
                        OverviewStat(
                            title: "Recovery",
                            value: "\(recoveryValue)%",
                            systemImage: "heart.fill",
                            theme: theme
                        )
                        OverviewStat(
                            title: "Active",
                            value: "\(rangeStats.activeDays)",
                            systemImage: "sparkles",
                            theme: theme
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                CategoryLegendDot(
                    label: "Cardio", percent: split.cardioPercent, color: theme.accent, theme: theme
                )
                CategoryLegendDot(
                    label: "Strength", percent: split.strengthPercent,
                    color: theme.accent.opacity(0.65), theme: theme)
                CategoryLegendDot(
                    label: "Lifting", percent: split.liftingPercent,
                    color: theme.accent.opacity(0.40), theme: theme)

                Spacer(minLength: 0)

                Text("\(heatmapRangeLabel()) • \(rangeStats.totalWorkouts)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Divider().opacity(0.35)
        }
    }

    var streakVitalsSection: some View {
        let overallRecovery = bf.bodyMapManager.getOverallRecoveryPercentage()
        let recoveryValue = "\(Int(overallRecovery))%"
        let range = heatmapDateRange()

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Streak")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                Label {
                    Text("\(currentStreak) days")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                } icon: {
                    Image(systemName: "flame.fill")
                }
                .foregroundStyle(theme.accent)
            }

            HStack(spacing: 10) {
                let today = Calendar.current.startOfDay(for: Date.now)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(streakVisibleDays, id: \.self) { date in
                                streakDayPill(for: date)
                                    .id(date)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onAppear {
                        guard !didAutoScrollStreakToToday else { return }
                        didAutoScrollStreakToToday = true
                        DispatchQueue.main.async {
                            proxy.scrollTo(today, anchor: .center)
                        }
                    }
                }
                .scrollClipDisabled()
                .frame(maxWidth: .infinity, alignment: .leading)

                BFChromeIconButton(
                    systemImage: "ellipsis",
                    accessibilityLabel: "Streak summary",
                    theme: theme
                ) {
                    showStreakSummary = true
                }
            }

            if longestStreak > 0 {
                Text("Longest: \(longestStreak) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Divider()
                .opacity(0.6)
                .padding(.top, 2)
                .padding(.bottom, 6)

            HStack {
                Menu {
                    Button("1 Week") {
                        heatmapRange = .week
                    }
                    Button("1 Month") {
                        heatmapRange = .month
                    }
                    Button("1 Year") {
                        heatmapRange = .year
                    }
                    Divider()
                    Button("Custom…") {
                        heatmapRange = .custom
                        showCustomRangeSheet = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(heatmapRangeLabel())
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule().fill(theme.cardBackground)
                    }
                    .overlay { Capsule().stroke(theme.cardStroke, lineWidth: 1) }
                }
            }

            Spacer(minLength: 12)

            ContributionHeatmap(
                startDate: range.start,
                endDate: range.end,
                valuesByDay: activityByDay,
                theme: theme
            )
            .frame(height: 86)

            Spacer(minLength: 12)

        }
    }

    var workoutRecapCard: some View {
        let active = bf.getActiveWorkout()
        let history = bf.getWorkoutHistory().sorted(by: { $0.date > $1.date })
        let last = history.first

        let workout = active ?? last ?? suggestedWorkout
        let isOngoing = active != nil
        let headline = isOngoing ? "Ongoing Workout" : (last == nil ? "Suggested" : "Last Workout")
        let primaryCTA = isOngoing ? "Resume" : "Start Workout"

        return BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(headline.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)

                    Button {
                        startWorkout()
                    } label: {
                        HStack(spacing: 6) {
                            Text(primaryCTA)
                                .font(.subheadline.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.accent)
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(recapTimeText(for: workout, isOngoing: isOngoing))
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .monospacedDigit()

                    if isOngoing {
                        Text("elapsed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(recapSubtitle(for: workout))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(workout.exercises.prefix(6)), id: \.id) { exercise in
                            recapExerciseThumb(exercise.exercise)
                        }

                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercises (\(workout.exercises.count))")
                        .font(.subheadline.weight(.semibold))

                    VStack(spacing: 10) {
                        ForEach(Array(workout.exercises.prefix(3)), id: \.id) { we in
                            recapExerciseRow(we)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Suggested Workouts Section
    var suggestedWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Workouts")
                .bfHeading(theme: theme, size: 24, relativeTo: .title2)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(suggestedWorkouts, id: \.name) { workout in
                        WorkoutSuggestionCard(workout: workout, theme: theme) {
                            selectWorkout(workout)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Swipeable Workout Card Stack
    var workoutCardStack: some View {
        let workouts = suggestedWorkouts
        let safeIndex = min(selectedWorkoutIndex, workouts.count - 1)

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Up Next")
                    .bfHeading(theme: theme, size: 18, relativeTo: .largeTitle)

                Spacer()

                Button {
                    showEquipmentSwapSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.arrow.right")
                        Text("Swap")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Menu {
                    Button("Customize") {}
                    Button("Generate New") { generateWorkout() }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }

            if !workouts.isEmpty {
                Text("\(workouts[safeIndex].exercises.count) Exercises")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Card stack with swipe gesture
            ZStack {
                ForEach(Array(workouts.enumerated().reversed()), id: \.offset) { index, workout in
                    let isTop = index == safeIndex
                    let offset = CGFloat(index - safeIndex)

                    WorkoutSwipeCard(
                        workout: workout,
                        theme: theme,
                        isTopCard: isTop
                    )
                    .offset(x: isTop ? cardSwipeOffset : 0)
                    .offset(y: offset * 8)
                    .scaleEffect(1 - abs(offset) * 0.05)
                    .opacity(index >= safeIndex && index <= safeIndex + 2 ? 1 : 0)
                    .zIndex(Double(workouts.count - index))
                    .gesture(
                        isTop ? swipeGesture : nil
                    )
                }
            }
            .frame(height: 180)

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<min(workouts.count, 3), id: \.self) { idx in
                    Circle()
                        .fill(idx == safeIndex ? theme.accent : theme.cardStroke)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                cardSwipeOffset = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                let workouts = suggestedWorkouts

                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    if value.translation.width < -threshold {
                        // Swipe left - next workout
                        if selectedWorkoutIndex < workouts.count - 1 {
                            selectedWorkoutIndex += 1
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right - previous workout
                        if selectedWorkoutIndex > 0 {
                            selectedWorkoutIndex -= 1
                        }
                    }
                    cardSwipeOffset = 0
                }
            }
    }

    func swapToNextWorkout() {
        let workouts = suggestedWorkouts
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            selectedWorkoutIndex = (selectedWorkoutIndex + 1) % workouts.count
        }
    }

    func applyEquipmentSwaps() {
        // Update the equipment swap manager with available equipment
        bf.equipmentSwapManager.setAvailableEquipment(availableEquipment)
    }

    // MARK: - Workout Preview Section
    var workoutPreviewSection: some View {
        let workouts = suggestedWorkouts
        guard !workouts.isEmpty else { return AnyView(EmptyView()) }
        let safeIndex = min(selectedWorkoutIndex, workouts.count - 1)
        let workout = workouts[safeIndex]

        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                // Target Muscles
                targetMusclesSection(for: workout)

                // Exercises list
                exercisesPreviewSection(for: workout)
            }
        )
    }

    func targetMusclesSection(for workout: Workout) -> some View {
        let muscleGroups = workout.exercises
            .flatMap { $0.exercise.muscleGroups }
            .reduce(into: [MuscleGroup: Int]()) { counts, group in
                counts[group, default: 0] += 1
            }
            .sorted { $0.value > $1.value }
            .prefix(3)

        let totalCount = max(1, muscleGroups.reduce(0) { $0 + $1.value })

        return VStack(alignment: .leading, spacing: 12) {
            Text("Target Muscles")
                .bfHeading(theme: theme, size: 18, relativeTo: .headline)

            HStack(spacing: 20) {
                ForEach(Array(muscleGroups), id: \.key) { group, count in
                    let percent = Int((Double(count) / Double(totalCount)) * 100)
                    TargetMuscleView(
                        muscle: prettifyMuscleGroup(group.rawValue),
                        percent: percent,
                        theme: theme
                    )
                }
            }
        }
    }

    func exercisesPreviewSection(for workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, we in
                if index > 0 && shouldShowSupersetDivider(at: index, in: workout) {
                    supersetDivider(at: index, in: workout)
                }

                ExercisePreviewRow(
                    exercise: we,
                    theme: theme
                )
            }
        }
    }

    func shouldShowSupersetDivider(at index: Int, in workout: Workout) -> Bool {
        // Show divider every 2 exercises to simulate superset grouping
        return index % 2 == 0
    }

    func supersetDivider(at index: Int, in workout: Workout) -> some View {
        let roundCount = (workout.exercises.count - index + 1) / 2
        return HStack {
            Text("Superset • \(max(1, roundCount)) Rounds")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    func startWorkoutFromSelection() {
        let workouts = suggestedWorkouts
        guard !workouts.isEmpty else { return }
        let safeIndex = min(selectedWorkoutIndex, workouts.count - 1)
        selectWorkout(workouts[safeIndex])
    }

    var titleRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Workout")
                .bfHeading(theme: theme, size: 36, relativeTo: .largeTitle)

            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    func recoveryStatusCard(for region: BodyRegion) -> some View {
        let status = statuses[region] ?? .recovered
        let percent = Int(statusPercent(status))

        return VStack(spacing: 12) {
            ZStack {
                ProgressRing(progress: statusPercent(status) / 100.0, lineWidth: 18, theme: theme)
                    .frame(width: 280, height: 280)

                VStack(spacing: 6) {
                    Text(regionDisplayName(region))
                        .bfHeading(theme: theme, size: 24, relativeTo: .title2)

                    Text("\(percent)%")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Text(statusLabel(status))
                        .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                        .foregroundStyle(theme.accent)

                    Text(statusSubtitle(status))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                startEmptyWorkout()
            } label: {
                Text("Empty Workout")
                    .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)

            Button {
                generateWorkout()
            } label: {
                Label("Generate", systemImage: "sparkles")
                    .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var myWeekCard: some View {
        BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("My Week")
                        .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    ForEach(weekDays, id: \.self) { date in
                        VStack(spacing: 6) {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(date.formatted(.dateTime.day()))
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 34, height: 34)
                                .background(dayBackground(for: date))
                                .clipShape(Circle())
                                .overlay { Circle().stroke(theme.cardStroke, lineWidth: 1) }
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Isolated Elapsed Time Display
/// Separate view component to prevent parent hierarchy re-renders on timer updates
private struct ElapsedTimeDisplay: View {
    let betterFit: BetterFit
    let theme: AppTheme
    @Binding var elapsedTimeUpdateTrigger: Bool
    let formatElapsed: (TimeInterval) -> String

    var body: some View {
        if let active = betterFit.getActiveWorkout() {
            let _ = elapsedTimeUpdateTrigger  // Force update on timer tick
            let elapsed = Date.now.timeIntervalSince(active.date)
            Text(formatElapsed(elapsed))
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(theme.accent)
                .animation(.none, value: elapsed)
        }
    }
}
