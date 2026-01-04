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
        let _ = "\(Int(overallRecovery))%"
        let range = heatmapDateRange()

        return VStack(alignment: .leading, spacing: 12) {
            // Compact streak header with expand/collapse
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isHeatmapExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(theme.accent)

                    Text("\(currentStreak)")
                        .font(.title3.weight(.bold))
                        .monospacedDigit()

                    Text("day streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if longestStreak > currentStreak {
                        Text("• Best: \(longestStreak)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isHeatmapExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isHeatmapExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Day pills row
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

                    // Range selector
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

                        Spacer()
                    }

                    // Heatmap
                    ContributionHeatmap(
                        startDate: range.start,
                        endDate: range.end,
                        valuesByDay: activityByDay,
                        theme: theme
                    )
                    .frame(height: 86)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
                .opacity(0.6)
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
        // Isolated child view prevents cardSwipeOffset updates from re-rendering target muscles
        WorkoutCardStackContainer(
            suggestedWorkouts: suggestedWorkouts,
            selectedWorkoutIndex: $selectedWorkoutIndex,
            showEquipmentSwapSheet: $showEquipmentSwapSheet,
            theme: theme,
            planManager: planManager,
            generateWorkout: generateWorkout
        )
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
                // Target Muscles first (compact)
                compactTargetMusclesSection(for: workout)

                // Exercises list (compact, non-scrollable)
                compactExercisesSection(for: workout)
            }
        )
    }

    func compactTargetMusclesSection(for workout: Workout) -> some View {
        let muscleGroups = workout.exercises
            .flatMap { $0.exercise.muscleGroups }
            .reduce(into: [MuscleGroup: Int]()) { counts, group in
                counts[group, default: 0] += 1
            }
            .sorted { $0.value > $1.value }
            .prefix(4)

        let totalCount = max(1, muscleGroups.reduce(0) { $0 + $1.value })

        return VStack(alignment: .leading, spacing: 10) {
            Text("Target Muscles")
                .bfHeading(theme: theme, size: 18, relativeTo: .headline)

            HStack(spacing: 12) {
                ForEach(Array(muscleGroups), id: \.key) { group, count in
                    let percent = Int((Double(count) / Double(totalCount)) * 100)
                    CompactMuscleChip(
                        muscle: prettifyMuscleGroup(group.rawValue),
                        percent: percent,
                        theme: theme
                    )
                }
            }
        }
    }

    func compactExercisesSection(for workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text("Exercises")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                Spacer()

                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    showAddExerciseSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(theme.accent)
                }
            }

            // Compact exercise rows (non-scrollable)
            VStack(spacing: 8) {
                ForEach(Array(workout.exercises.prefix(4).enumerated()), id: \.element.id) { index, exercise in
                    CompactExerciseRow(
                        exercise: exercise,
                        index: index,
                        theme: theme
                    )
                }

                if workout.exercises.count > 4 {
                    Text("+\(workout.exercises.count - 4) more")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(theme.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
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
        let displayCount = min(workout.exercises.count, 5)
        let rowHeight: CGFloat = 88
        let headerHeight: CGFloat = 32
        let emptyStateHeight: CGFloat = 120  // Height for empty state (icon + text + button)
        let listHeight: CGFloat =
            displayCount > 0
            ? CGFloat(displayCount) * rowHeight + headerHeight
            : headerHeight + emptyStateHeight

        return VStack(alignment: .leading, spacing: 0) {
            UnifiedExerciseTimeline(
                exercises: Array(workout.exercises.prefix(5)),
                selectedIndex: nil,
                theme: theme,
                showHeader: true,
                headerTitle: "Exercises",
                onSelect: { _ in },
                onDelete: { _ in },
                onReplace: nil,
                onSuperset: nil,
                onComplete: nil,
                onMove: nil,
                onAdd: { showAddExerciseSheet = true }
            )
            .frame(height: listHeight)

            if workout.exercises.count > 5 {
                Button {
                    // Could expand to show all exercises
                } label: {
                    HStack(spacing: 4) {
                        Text("+\(workout.exercises.count - 5) more")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.accent)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
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

// MARK: - Isolated Workout Card Stack Container
/// Separate view component to prevent cardSwipeOffset from triggering re-renders of target muscles
private struct WorkoutCardStackContainer: View {
    let suggestedWorkouts: [Workout]
    @Binding var selectedWorkoutIndex: Int
    @Binding var showEquipmentSwapSheet: Bool
    let theme: AppTheme
    let planManager: WorkoutPlanManager?
    let generateWorkout: () -> Void

    @State private var cardSwipeOffset: CGFloat = 0

    var body: some View {
        let workouts = suggestedWorkouts
        let safeIndex = min(selectedWorkoutIndex, max(0, workouts.count - 1))

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Up Next")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                if !workouts.isEmpty {
                    Text("\(workouts[safeIndex].exercises.count) Exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showEquipmentSwapSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.arrow.right")
                        Text("Swap")
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Menu {
                    Button("Customize") {}
                    Button("Generate New") { generateWorkout() }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption.weight(.semibold))
                        .frame(width: 28, height: 28)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }

            // Playing card stack with offset and rotation
            ZStack {
                // Show up to 3 cards behind the current one
                ForEach(Array(workouts.enumerated().reversed()), id: \.offset) { index, workout in
                    let relativeIndex = index - safeIndex
                    let isTop = index == safeIndex
                    let isVisible = relativeIndex >= 0 && relativeIndex <= 2

                    if isVisible {
                        PlayingCardWorkoutCard(
                            workout: workout,
                            theme: theme,
                            isTopCard: isTop
                        )
                        .offset(x: isTop ? cardSwipeOffset : CGFloat(relativeIndex) * 8)
                        .offset(y: CGFloat(relativeIndex) * -4)
                        .rotationEffect(.degrees(Double(relativeIndex) * 2), anchor: .bottom)
                        .scaleEffect(1 - Double(relativeIndex) * 0.03)
                        .opacity(1 - Double(relativeIndex) * 0.15)
                        .zIndex(Double(workouts.count - index))
                        .gesture(isTop ? swipeGesture : nil)
                    }
                }
            }
            .frame(height: 172)
            .padding(.top, 8)

            // Page indicator - only show if more than 1 workout
            if workouts.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<min(workouts.count, 5), id: \.self) { idx in
                        Circle()
                            .fill(idx == safeIndex ? theme.accent : theme.cardStroke)
                            .frame(width: 6, height: 6)
                    }
                    if workouts.count > 5 {
                        Text("+\(workouts.count - 5)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                cardSwipeOffset = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                let oldIndex = selectedWorkoutIndex

                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    if value.translation.width < -threshold {
                        // Swipe left - next workout
                        if selectedWorkoutIndex < suggestedWorkouts.count - 1 {
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

                // Update plan when workout selection changes
                if oldIndex != selectedWorkoutIndex, let manager = planManager {
                    let newIndex = selectedWorkoutIndex
                    if newIndex < suggestedWorkouts.count {
                        let selectedWorkout = suggestedWorkouts[newIndex]
                        manager.setSelectedWorkoutForToday(selectedWorkout)
                    }
                }
            }
    }
}

// MARK: - Playing Card Style Workout Card
private struct PlayingCardWorkoutCard: View {
    let workout: Workout
    let theme: AppTheme
    let isTopCard: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Workout icon/image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 100, height: 140)

                VStack(spacing: 8) {
                    Image(systemName: iconForWorkout)
                        .font(.system(size: 36))
                        .foregroundStyle(theme.accent)

                    Text(workoutType)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }

            // Workout details
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.name)
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                    .lineLimit(2)

                // Quick stats row
                HStack(spacing: 16) {
                    Label("1h", systemImage: "clock")
                    Label("Equipment", systemImage: "dumbbell")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    workoutPill(workoutType)
                    workoutPill("Intermediate")
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 172)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thickMaterial)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
            } else {
                let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
                shape
                    .fill(.thickMaterial)
                    .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                    .shadow(
                        color: Color.black.opacity(
                            theme.preferredColorScheme == .dark ? 0.3 : 0.12),
                        radius: theme.preferredColorScheme == .dark ? 16 : 12,
                        x: 0,
                        y: 6
                    )
            }
        }
    }

    private var iconForWorkout: String {
        let name = workout.name.lowercased()
        if name.contains("run") { return "figure.run" }
        if name.contains("yoga") { return "figure.yoga" }
        if name.contains("strength") || name.contains("upper") { return "dumbbell.fill" }
        if name.contains("hiit") { return "flame.fill" }
        if name.contains("push") { return "figure.strengthtraining.traditional" }
        if name.contains("pull") { return "figure.rowing" }
        if name.contains("leg") { return "figure.walk" }
        return "figure.mixed.cardio"
    }

    private var workoutType: String {
        let name = workout.name.lowercased()
        if name.contains("cardio") || name.contains("run") { return "Cardio" }
        if name.contains("yoga") { return "Flexibility" }
        if name.contains("hiit") { return "HIIT" }
        return "Circuit Training"
    }

    func workoutPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
    }
}
