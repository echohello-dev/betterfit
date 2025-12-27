import BetterFit
import SwiftUI

// swiftlint:disable file_length type_body_length identifier_name

struct WorkoutHomeView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var selectedRegion: BodyRegion = .core
    @State private var statuses: [BodyRegion: RecoveryStatus] = [:]

    @State private var showCalendar = false
    @State private var selectedDate = Date.now

    @State private var showStreakSummary = false

    @State private var showingSearch = false

    // Gamification
    @State private var currentStreak = 0
    @State private var longestStreak = 0
    @State private var lastWorkoutDate: Date?
    @State private var username: String = "User"
    @State private var weeklyGoalProgress = 0.35  // 35% complete

    // Activity heatmap (GitHub-style)
    @State private var activityByDay: [Date: Int] = [:]

    private enum HeatmapRange: String {
        case week
        case month
        case year
        case custom
    }

    @State private var heatmapRange: HeatmapRange = .month
    @State private var showCustomRangeSheet = false
    @State private var customRangeStart: Date =
        Calendar.current.date(byAdding: .year, value: -3, to: Date.now) ?? Date.now
    @State private var customRangeEnd: Date = Date.now


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Section
                welcomeSection

                // Streak + Vitals (merged, no card background)
                streakVitalsSection

                // Workout recap
                workoutRecapCard

                // Suggested Workouts Section
                suggestedWorkoutsSection

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)  // Space for floating nav bar
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    GlassEffectContainer(spacing: 16) {
                        HStack(spacing: 10) {
                            BFChromeIconButton(
                                systemImage: "chart.bar.fill",
                                accessibilityLabel: "Stats",
                                theme: theme
                            ) {
                                // Show stats
                            }
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        BFChromeIconButton(
                            systemImage: "chart.bar.fill",
                            accessibilityLabel: "Stats",
                            theme: theme
                        ) {
                            // Show stats
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: betterFit)
                .presentationDetents([PresentationDetent.large])
        }
        .sheet(isPresented: $showCalendar) {
            CalendarSheetView(selectedDate: $selectedDate, theme: theme)
                .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
        }
        .sheet(isPresented: $showStreakSummary) {
            StreakSummarySheetView(
                betterFit: betterFit,
                selectedDate: $selectedDate,
                theme: theme,
                openCalendar: { showCalendar = true }
            )
            .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
        }
        .sheet(isPresented: $showCustomRangeSheet) {
            CustomHeatmapRangeSheet(
                theme: theme,
                start: $customRangeStart,
                end: $customRangeEnd
            )
            .presentationDetents([PresentationDetent.medium])
        }
        .onAppear {
            refreshStatuses()
            loadGameStats()
            refreshVitals()
        }
        .onChange(of: heatmapRange) {
            refreshVitals()
        }
        .onChange(of: customRangeStart) {
            if heatmapRange == .custom {
                refreshVitals()
            }
        }
        .onChange(of: customRangeEnd) {
            if heatmapRange == .custom {
                refreshVitals()
            }
        }
    }

    private var titleRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Workout")
                .bfHeading(theme: theme, size: 36, relativeTo: .largeTitle)

            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Helper Functions
    private func loadGameStats() {
        currentStreak = betterFit.socialManager.getCurrentStreak()
        longestStreak = betterFit.socialManager.getLongestStreak()
        lastWorkoutDate = betterFit.socialManager.getLastWorkoutDate()
        username = betterFit.socialManager.getUserProfile().username
    }

    private func refreshVitals() {
        let range = heatmapDateRange()
        activityByDay = makeDailyWorkoutCounts(startDate: range.start, endDate: range.end)
    }

    private func heatmapDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)

        switch heatmapRange {
        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            return (start, today)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: today) ?? today
            return (calendar.startOfDay(for: start), today)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: today) ?? today
            return (calendar.startOfDay(for: start), today)
        case .custom:
            let start = calendar.startOfDay(for: min(customRangeStart, customRangeEnd))
            let end = calendar.startOfDay(for: min(max(customRangeStart, customRangeEnd), today))
            return (start, end)
        }
    }

    private func heatmapRangeLabel() -> String {
        switch heatmapRange {
        case .week: return "1W"
        case .month: return "1M"
        case .year: return "1Y"
        case .custom: return "Custom"
        }
    }

    private var suggestedWorkout: Workout {
        betterFit.getRecommendedWorkout() ?? defaultWorkout
    }

    private var suggestedWorkouts: [Workout] {
        // Get multiple workout suggestions
        var workouts: [Workout] = []

        if let recommended = betterFit.getRecommendedWorkout() {
            workouts.append(recommended)
        }

        // Add some variety workouts
        workouts.append(contentsOf: [
            Workout(
                name: "Morning Yoga Flow",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Sun Salutations", equipmentRequired: .bodyweight,
                            muscleGroups: [.abs, .quads]),
                        sets: [ExerciseSet(reps: 10, weight: 0)]
                    )
                ]
            ),
            Workout(
                name: "HIIT Blast",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Burpees", equipmentRequired: .bodyweight,
                            muscleGroups: [.quads, .abs, .chest]),
                        sets: [ExerciseSet(reps: 15, weight: 0)]
                    )
                ]
            ),
            Workout(
                name: "Upper Body Strength",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Push-ups", equipmentRequired: .bodyweight,
                            muscleGroups: [.chest, .triceps]),
                        sets: [ExerciseSet(reps: 12, weight: 0)]
                    )
                ]
            ),
        ])

        return workouts
    }

    private var defaultWorkout: Workout {
        Workout(
            name: "Steady Running",
            exercises: [
                WorkoutExercise(
                    exercise: Exercise(
                        name: "Running", equipmentRequired: .bodyweight,
                        muscleGroups: [.quads, .calves]),
                    sets: [ExerciseSet(reps: 1, weight: 0)]
                )
            ]
        )
    }

    private func startWorkout() {
        let workout = suggestedWorkout
        betterFit.startWorkout(workout)
        // Navigate to active workout screen
    }

    private func selectWorkout(_ workout: Workout) {
        betterFit.startWorkout(workout)
        // Navigate to active workout screen
    }

    private var welcomeSection: some View {
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

    private var streakVitalsSection: some View {
        let overallRecovery = betterFit.bodyMapManager.getOverallRecoveryPercentage()
        let recoveryValue = "\(Int(overallRecovery))%"
        let range = heatmapDateRange()

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Streak")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                Spacer(minLength: 0)

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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(streakWeekDays, id: \.self) { date in
                            streakDayPill(for: date)
                        }
                    }
                    .padding(.vertical, 2)
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

            Divider().opacity(0.6)

            HStack {
                Text("Vitals")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                Spacer(minLength: 0).padding(.vertical, 4)

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

            ContributionHeatmap(
                startDate: range.start,
                endDate: range.end,
                valuesByDay: activityByDay,
                theme: theme
            )
            .frame(height: 86)

            HStack(spacing: 12) {
                MetricPill(
                    title: "Recovery", value: recoveryValue, systemImage: "heart.fill",
                    theme: theme)

                MetricPill(
                    title: "Streak", value: "\(currentStreak)d", systemImage: "flame.fill",
                    theme: theme)

                MetricPill(
                    title: "Work",
                    value: "\(betterFit.socialManager.getUserProfile().totalWorkouts)",
                    systemImage: "figure.strengthtraining.traditional", theme: theme)
            }
        }
    }

    private var streakDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        let end = calendar.startOfDay(for: min(selectedDate, today))
        let count = 21

        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: -(count - 1 - offset), to: end)
        }
    }

    private var streakWeekDays: [Date] {
        let calendar = sundayFirstCalendar
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start
            ?? calendar.startOfDay(for: selectedDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var sundayFirstCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 1
        return calendar
    }

    private var workoutRecapCard: some View {
        let active = betterFit.getActiveWorkout()
        let history = betterFit.getWorkoutHistory().sorted(by: { $0.date > $1.date })
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

    private func recapTimeText(for workout: Workout, isOngoing: Bool) -> String {
        if isOngoing {
            let seconds = max(0, Date.now.timeIntervalSince(workout.date))
            return formatElapsed(seconds)
        }

        if let duration = workout.duration, duration > 0 {
            return formatElapsed(duration)
        }

        // Best-effort fallback: show relative time since last workout.
        return workout.date.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
    }

    private func recapSubtitle(for workout: Workout) -> String {
        let groups = primaryMuscleGroups(for: workout)
        if groups.isEmpty {
            return workout.name
        }
        return groups.joined(separator: ", ")
    }

    private func primaryMuscleGroups(for workout: Workout) -> [String] {
        let groups = workout.exercises
            .flatMap { $0.exercise.muscleGroups }
            .map { $0.rawValue }

        var counts: [String: Int] = [:]
        for g in groups {
            counts[g, default: 0] += 1
        }

        return
            counts
            .sorted { $0.value > $1.value }
            .map { prettifyMuscleGroup($0.key) }
            .prefix(3)
            .map { $0 }
    }

    private func prettifyMuscleGroup(_ raw: String) -> String {
        switch raw {
        case "abs": return "Core"
        case "quads": return "Quadriceps"
        default:
            return raw.prefix(1).uppercased() + raw.dropFirst()
        }
    }

    private func recapExerciseThumb(_ exercise: Exercise) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.accent.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(
                        theme.cardStroke, lineWidth: 1)
                }

            Image(systemName: thumbIcon(for: exercise))
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.accent)
        }
        .frame(width: 64, height: 52)
        .accessibilityLabel(exercise.name)
    }

    private func recapExerciseRow(_ workoutExercise: WorkoutExercise) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: thumbIcon(for: workoutExercise.exercise))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(workoutExercise.exercise.name)
                    .font(.subheadline.weight(.semibold))

                Text(recapExerciseDetail(workoutExercise))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                .shadow(
                    color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.22 : 0.08),
                    radius: theme.preferredColorScheme == .dark ? 14 : 10,
                    x: 0,
                    y: 6
                )
        }
    }

    private func recapExerciseDetail(_ workoutExercise: WorkoutExercise) -> String {
        let groups = workoutExercise.exercise.muscleGroups.prefix(2).map {
            prettifyMuscleGroup($0.rawValue)
        }
        if !workoutExercise.sets.isEmpty {
            let sets = workoutExercise.sets.count
            return "\(groups.joined(separator: ", ")) • \(sets) sets"
        }
        return groups.joined(separator: ", ")
    }

    private func thumbIcon(for exercise: Exercise) -> String {
        let name = exercise.name.lowercased()
        if name.contains("run") || name.contains("treadmill") { return "figure.run" }
        if name.contains("bench") || name.contains("press") { return "dumbbell.fill" }
        if name.contains("row") { return "figure.strengthtraining.traditional" }
        if name.contains("yoga") { return "figure.yoga" }

        switch exercise.equipmentRequired {
        case .barbell, .dumbbell, .kettlebell:
            return "dumbbell.fill"
        case .machine, .cable:
            return "figure.strengthtraining.traditional"
        case .bands:
            return "circle.dotted"
        case .bodyweight:
            return "figure.core.training"
        case .other:
            return "bolt.fill"
        }
    }

    private func formatElapsed(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let hrs = minutes / 60
        let mins = minutes % 60
        let secs = total % 60

        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    private func makeDailyWorkoutCounts(startDate: Date, endDate: Date) -> [Date: Int] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [:] }

        var counts: [Date: Int] = [:]

        for workout in betterFit.getWorkoutHistory() {
            let day = calendar.startOfDay(for: workout.date)
            guard day >= start, day <= end else { continue }
            counts[day, default: 0] += 1
        }

        if betterFit.getActiveWorkout() != nil {
            // Best-effort: count today's in-progress session if it's inside the selected range.
            let today = calendar.startOfDay(for: Date.now)
            if today >= start, today <= end {
                counts[today, default: 0] += 1
            }
        }

        return counts
    }

    private struct ContributionHeatmap: View {
        let startDate: Date
        let endDate: Date
        let valuesByDay: [Date: Int]
        let theme: AppTheme

        @State private var didAutoScrollToEnd = false

        private let cell: CGFloat = 11
        private let gap: CGFloat = 4

        var body: some View {
            let calendar = Calendar.current
            let rangeStart = calendar.startOfDay(for: startDate)
            let rangeEnd = calendar.startOfDay(for: endDate)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(
                            monthStarts(
                                rangeStart: rangeStart, rangeEnd: rangeEnd, calendar: calendar),
                            id: \.self
                        ) { monthStart in
                            MonthBlock(
                                monthStart: monthStart,
                                rangeStart: rangeStart,
                                rangeEnd: rangeEnd,
                                valuesByDay: valuesByDay,
                                cell: cell,
                                gap: gap,
                                theme: theme
                            )
                            .id(monthStart)
                        }

                        Color.clear
                            .frame(width: 1, height: 1)
                            .id("heatmap-end")
                    }
                    .padding(.vertical, 2)
                }
                .onAppear {
                    guard !didAutoScrollToEnd else { return }
                    didAutoScrollToEnd = true
                    DispatchQueue.main.async {
                        proxy.scrollTo("heatmap-end", anchor: .trailing)
                    }
                }
                .onChange(of: endDate) {
                    DispatchQueue.main.async {
                        proxy.scrollTo("heatmap-end", anchor: .trailing)
                    }
                }
            }
            .mask { RoundedRectangle(cornerRadius: 16, style: .continuous) }
        }

        private func monthStarts(rangeStart: Date, rangeEnd: Date, calendar: Calendar) -> [Date] {
            guard rangeStart <= rangeEnd else { return [] }
            guard
                let startOfStartMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: rangeStart)),
                let startOfEndMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: rangeEnd))
            else {
                return []
            }

            var months: [Date] = []
            var cursor = startOfStartMonth
            while cursor <= startOfEndMonth {
                months.append(cursor)
                guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else {
                    break
                }
                cursor = next
            }
            return months
        }

        private struct MonthBlock: View {
            let monthStart: Date
            let rangeStart: Date
            let rangeEnd: Date
            let valuesByDay: [Date: Int]
            let cell: CGFloat
            let gap: CGFloat
            let theme: AppTheme

            var body: some View {
                let calendar = Calendar.current
                let monthEnd = endOfMonth(for: monthStart, calendar: calendar)
                let clampedEnd = min(monthEnd, rangeEnd)
                let clampedStart = max(monthStart, rangeStart)

                VStack(alignment: .leading, spacing: 8) {
                    Text(monthStart.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .top, spacing: gap) {
                        ForEach(
                            weekStarts(
                                forMonthStart: monthStart, monthEnd: clampedEnd, calendar: calendar),
                            id: \.self
                        ) { weekStart in
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { dayOffset in
                                    let date =
                                        calendar.date(
                                            byAdding: .day, value: dayOffset, to: weekStart)
                                        ?? weekStart
                                    DayCell(
                                        date: date,
                                        rangeStart: clampedStart,
                                        rangeEnd: clampedEnd,
                                        valuesByDay: valuesByDay,
                                        cell: cell,
                                        theme: theme
                                    )
                                }
                            }
                        }
                    }
                }
            }

            private func endOfMonth(for date: Date, calendar: Calendar) -> Date {
                guard
                    let start = calendar.date(
                        from: calendar.dateComponents([.year, .month], from: date)),
                    let next = calendar.date(byAdding: .month, value: 1, to: start),
                    let end = calendar.date(byAdding: .day, value: -1, to: next)
                else {
                    return date
                }
                return end
            }

            private func weekStarts(
                forMonthStart monthStart: Date, monthEnd: Date, calendar: Calendar
            ) -> [Date] {
                guard
                    let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthStart)?
                        .start,
                    let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthEnd)?.start
                else {
                    return []
                }

                var weeks: [Date] = []
                var cursor = firstWeekStart
                while cursor <= lastWeekStart {
                    weeks.append(cursor)
                    guard let next = calendar.date(byAdding: .day, value: 7, to: cursor) else {
                        break
                    }
                    cursor = next
                }
                return weeks
            }
        }

        private struct DayCell: View {
            let date: Date
            let rangeStart: Date
            let rangeEnd: Date
            let valuesByDay: [Date: Int]
            let cell: CGFloat
            let theme: AppTheme

            var body: some View {
                let calendar = Calendar.current
                let day = calendar.startOfDay(for: date)
                let isInRange =
                    day >= calendar.startOfDay(for: rangeStart)
                    && day <= calendar.startOfDay(for: rangeEnd)

                Group {
                    if isInRange {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(color(for: valuesByDay[day, default: 0]))
                            .overlay {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .stroke(theme.cardStroke.opacity(0.7), lineWidth: 0.5)
                            }
                            .accessibilityLabel(
                                accessibilityText(day: day, count: valuesByDay[day, default: 0]))
                    } else {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.clear)
                    }
                }
                .frame(width: cell, height: cell)
            }

            private func color(for count: Int) -> Color {
                switch count {
                case 0:
                    return theme.accent.opacity(0)
                case 1:
                    return theme.accent.opacity(0.18)
                case 2:
                    return theme.accent.opacity(0.34)
                case 3:
                    return theme.accent.opacity(0.52)
                default:
                    return theme.accent.opacity(0.75)
                }
            }

            private func accessibilityText(day: Date, count: Int) -> String {
                if count == 0 {
                    return "\(day.formatted(date: .abbreviated, time: .omitted)): no workouts"
                }
                if count == 1 {
                    return "\(day.formatted(date: .abbreviated, time: .omitted)): 1 workout"
                }
                return "\(day.formatted(date: .abbreviated, time: .omitted)): \(count) workouts"
            }
        }
    }

    private struct CustomHeatmapRangeSheet: View {
        let theme: AppTheme
        @Binding var start: Date
        @Binding var end: Date

        @Environment(\.dismiss) private var dismiss

        @State private var draftStart: Date = Date.now
        @State private var draftEnd: Date = Date.now

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        DatePicker("Start", selection: $draftStart, displayedComponents: [.date])
                        DatePicker("End", selection: $draftEnd, displayedComponents: [.date])
                    }

                    Section {
                        Button("Preset: Last 3 Years") {
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date.now)
                            draftEnd = today
                            draftStart =
                                calendar.date(byAdding: .year, value: -3, to: today) ?? today
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.backgroundGradient.ignoresSafeArea())
                .navigationTitle("Custom Range")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            start = draftStart
                            end = draftEnd
                            dismiss()
                        }
                        .font(.headline)
                    }
                }
            }
            .onAppear {
                draftStart = start
                draftEnd = end

                // If the stored custom range is effectively unset, default to last 3 years.
                if abs(draftStart.timeIntervalSince(draftEnd)) < 1 {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date.now)
                    draftEnd = today
                    draftStart = calendar.date(byAdding: .year, value: -3, to: today) ?? today
                }
            }
        }
    }

    private func streakDayPill(for date: Date) -> some View {
        let calendar = sundayFirstCalendar
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isInStreak = isDateInCurrentStreak(date)

        let selectedFill: Color = theme.preferredColorScheme == .dark ? .white : .black
        let selectedText: Color = theme.preferredColorScheme == .dark ? .black : .white

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 6) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption.weight(.semibold))

                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
            }
            .frame(width: 60, height: 64)
            .foregroundStyle(isSelected ? selectedText : (isInStreak ? Color.primary : Color.secondary))
            .background {
                let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
                if isSelected {
                    shape.fill(selectedFill)
                } else {
                    shape.fill(theme.cardBackground)
                        .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                }
            }
            .overlay(alignment: .topTrailing) {
                if isInStreak {
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Suggested Workouts Section
    private var suggestedWorkoutsSection: some View {
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

    private func recoveryStatusCard(for region: BodyRegion) -> some View {
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

    private var actionButtons: some View {
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

    // MARK: - Supporting Views

    struct GoalStat: View {
        let icon: String
        let value: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
        }
    }

    struct WorkoutSuggestionCard: View {
        let workout: Workout
        let theme: AppTheme
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 12) {
                    // Preview image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.accent.opacity(0.3))
                            .frame(height: 140)

                        Image(systemName: iconForWorkout)
                            .font(.system(size: 48))
                            .foregroundStyle(theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        HStack(spacing: 12) {
                            Label(
                                "\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            Label("30min", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()
                }
                .frame(width: 200)
                .padding(12)
                .background {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                    } else {
                        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
                        shape
                            .fill(.ultraThinMaterial)
                            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                            .shadow(
                                color: Color.black.opacity(
                                    theme.preferredColorScheme == .dark ? 0.22 : 0.08),
                                radius: theme.preferredColorScheme == .dark ? 14 : 10,
                                x: 0,
                                y: 6
                            )
                    }
                }
            }
            .buttonStyle(.plain)
        }

        private var iconForWorkout: String {
            let name = workout.name.lowercased()
            if name.contains("run") { return "figure.run" }
            if name.contains("yoga") { return "figure.yoga" }
            if name.contains("strength") || name.contains("upper") { return "dumbbell.fill" }
            if name.contains("hiit") { return "flame.fill" }
            return "figure.mixed.cardio"
        }
    }

    struct SubscriptionView: View {
        let theme: AppTheme
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // GO Club branding
                        ZStack {
                            Circle()
                                .fill(theme.accent)
                                .frame(width: 120, height: 120)

                            Text("GO")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 40)

                        Text("Start your fitness journey")
                            .bfHeading(theme: theme, size: 32, relativeTo: .largeTitle)
                            .multilineTextAlignment(.center)

                        Text(
                            "First week free, then just $19.99/year\nLess than your monthly coffee habit!"
                        )
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                        VStack(spacing: 16) {
                            FeatureRow(icon: "sparkles", title: "AI-Powered Workouts", theme: theme)
                            FeatureRow(icon: "heart.fill", title: "Recovery Tracking", theme: theme)
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis", title: "Progress Analytics",
                                theme: theme)
                            FeatureRow(
                                icon: "trophy.fill", title: "Achievements & Streaks", theme: theme)
                        }
                        .padding(.vertical)

                        Button {
                            // Start trial
                            dismiss()
                        } label: {
                            Text("Start Free Trial")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accent)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)

                        Button("Maybe Later") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .background(theme.backgroundGradient.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    struct FeatureRow: View {
        let icon: String
        let title: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(theme.accent)
                    .frame(width: 40)

                Text(title)
                    .font(.body.weight(.semibold))

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    private var myWeekCard: some View {
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

    private var displayRegions: [BodyRegion] {
        BodyRegion.allCases.filter { $0 != .other }
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func dayBackground(for date: Date) -> AnyShapeStyle {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return AnyShapeStyle(theme.accent.opacity(0.25))
        }
        return AnyShapeStyle(theme.cardBackground)
    }

    private func isDateInCurrentStreak(_ date: Date) -> Bool {
        guard currentStreak > 0, let lastWorkoutDate else {
            return false
        }

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let lastDay = calendar.startOfDay(for: lastWorkoutDate)
        let difference = calendar.dateComponents([.day], from: day, to: lastDay).day ?? Int.max

        return difference >= 0 && difference < currentStreak
    }

    private func refreshStatuses() {
        var next: [BodyRegion: RecoveryStatus] = [:]
        for region in displayRegions {
            next[region] = betterFit.bodyMapManager.getRecoveryStatus(for: region)
        }
        statuses = next

        if statuses[selectedRegion] == nil {
            selectedRegion = displayRegions.first ?? .core
        }
    }

    private func statusPercent(_ status: RecoveryStatus) -> Double {
        switch status {
        case .recovered: return 100
        case .slightlyFatigued: return 75
        case .fatigued: return 50
        case .sore: return 25
        }
    }

    private func statusLabel(_ status: RecoveryStatus) -> String {
        switch status {
        case .recovered: return "Recovered"
        case .slightlyFatigued: return "Slightly fatigued"
        case .fatigued: return "Fatigued"
        case .sore: return "Sore"
        }
    }

    private func statusSubtitle(_ status: RecoveryStatus) -> String {
        switch status {
        case .recovered: return "Fresh muscle group"
        case .slightlyFatigued: return "Trainable with moderation"
        case .fatigued: return "Consider reduced intensity"
        case .sore: return "Rest recommended"
        }
    }

    private func regionDisplayName(_ region: BodyRegion) -> String {
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

    private func quickAddWorkout() {
        // Placeholder action; we can later wire this to a workout builder.
        generateWorkout()
    }

    private func startEmptyWorkout() {
        // Placeholder. For now, just refresh recovery so the screen feels alive.
        refreshStatuses()
    }

    private func generateWorkout() {
        // Keep a tiny demo flow: use BetterFit's API path where possible.
        if let workout = betterFit.getRecommendedWorkout() {
            betterFit.startWorkout(workout)
            betterFit.completeWorkout(workout)
        } else {
            // Fall back to a minimal sample.
            let benchPress = Exercise(
                name: "Bench Press",
                equipmentRequired: .barbell,
                muscleGroups: [.chest, .triceps]
            )

            let workout = Workout(
                name: "Quick Session",
                exercises: [
                    WorkoutExercise(exercise: benchPress, sets: [ExerciseSet(reps: 8, weight: 60)])
                ]
            )

            betterFit.startWorkout(workout)
            betterFit.completeWorkout(workout)
        }

        refreshStatuses()
    }
}

// swiftlint:enable type_body_length identifier_name

#Preview {
    let theme: AppTheme = .defaultTheme
    NavigationStack {
        WorkoutHomeView(betterFit: BetterFit(), theme: theme)
    }
    .tint(theme.accent)
    .preferredColorScheme(theme.preferredColorScheme)
}
