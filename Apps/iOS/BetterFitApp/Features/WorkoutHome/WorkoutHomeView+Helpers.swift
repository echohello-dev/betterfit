import BetterFit
import SwiftUI

// MARK: - Workout Notifications
extension Notification.Name {
    static let workoutStarted = Notification.Name("BetterFit.workoutStarted")
    static let workoutCompleted = Notification.Name("BetterFit.workoutCompleted")
    static let workoutPaused = Notification.Name("BetterFit.workoutPaused")
    static let workoutResumed = Notification.Name("BetterFit.workoutResumed")
}

extension WorkoutHomeView {
    // MARK: - Helper Functions

    func refreshActiveWorkout() {
        activeWorkoutId = bf.getActiveWorkout()?.id
    }

    func loadGameStats() {
        currentStreak = bf.socialManager.getCurrentStreak()
        longestStreak = bf.socialManager.getLongestStreak()
        lastWorkoutDate = bf.socialManager.getLastWorkoutDate()
        username = bf.socialManager.getUserProfile().username
    }

    func refreshVitals() {
        let range = heatmapDateRange()
        activityByDay = makeDailyWorkoutCounts(startDate: range.start, endDate: range.end)
    }

    func heatmapDateRange() -> (start: Date, end: Date) {
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

    func heatmapRangeLabel() -> String {
        switch heatmapRange {
        case .week: return "1W"
        case .month: return "1M"
        case .year: return "1Y"
        case .custom: return "Custom"
        }
    }

    var suggestedWorkout: Workout {
        bf.getRecommendedWorkout() ?? defaultWorkout
    }

    var suggestedWorkouts: [Workout] {
        // Get multiple workout suggestions
        var workouts: [Workout] = []

        if let recommended = bf.getRecommendedWorkout() {
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

    var defaultWorkout: Workout {
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

    func startWorkout() {
        let workout = suggestedWorkout
        bf.startWorkout(workout)
        activeWorkoutId = workout.id
        NotificationCenter.default.post(name: .workoutStarted, object: workout.id)
    }

    func selectWorkout(_ workout: Workout) {
        bf.startWorkout(workout)
        activeWorkoutId = workout.id
        NotificationCenter.default.post(name: .workoutStarted, object: workout.id)
    }

    func overviewSummaryText(weeklyWorkouts: Int, recovery: Int) -> String {
        if weeklyWorkouts == 0 {
            return "Start with something light today — your body will thank you."
        }

        if recovery < 35 {
            return "You’re training consistently — consider keeping intensity moderate."
        }

        if weeklyWorkouts >= 4 {
            return "Strong week so far. Keep the momentum going."
        }

        return "Nice progress. A quick session today keeps the streak alive."
    }

    func workoutsThisWeek(date: Date) -> Int {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return 0
        }

        let history = bf.getWorkoutHistory()
        let completed = history.filter { $0.date >= interval.start && $0.date < interval.end }.count

        if let active = bf.getActiveWorkout(),
            active.date >= interval.start && active.date < interval.end
        {
            return completed + 1
        }

        return completed
    }

    func workoutRangeStats(start: Date, end: Date) -> WorkoutRangeStats {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        guard startDay <= endDay else { return WorkoutRangeStats(totalWorkouts: 0, activeDays: 0) }

        let counts = makeDailyWorkoutCounts(startDate: startDay, endDate: endDay)
        let total = counts.values.reduce(0, +)
        let activeDays = counts.values.filter { $0 > 0 }.count
        return WorkoutRangeStats(totalWorkouts: total, activeDays: activeDays)
    }

    func workoutCategorySplit(start: Date, end: Date) -> WorkoutCategorySplit {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        guard startDay <= endDay else {
            return WorkoutCategorySplit(cardioPercent: 0, strengthPercent: 0, liftingPercent: 0)
        }

        let history = bf.getWorkoutHistory().filter { $0.date >= startDay && $0.date <= endDay }
        let workouts: [Workout] = {
            if let active = bf.getActiveWorkout(), active.date >= startDay && active.date <= endDay
            {
                return history + [active]
            }
            return history
        }()

        guard !workouts.isEmpty else {
            return WorkoutCategorySplit(cardioPercent: 0, strengthPercent: 0, liftingPercent: 0)
        }

        var counts: [WorkoutCategory: Int] = [.cardio: 0, .strength: 0, .lifting: 0]
        for workout in workouts {
            counts[workoutCategory(for: workout), default: 0] += 1
        }

        let total = max(1, workouts.count)
        func pct(_ n: Int) -> Int { Int(round((Double(n) / Double(total)) * 100)) }

        let cardio = pct(counts[.cardio, default: 0])
        let strength = pct(counts[.strength, default: 0])
        let lifting = max(0, 100 - cardio - strength)
        return WorkoutCategorySplit(
            cardioPercent: cardio, strengthPercent: strength, liftingPercent: lifting)
    }

    func workoutCategory(for workout: Workout) -> WorkoutCategory {
        var score: [WorkoutCategory: Int] = [.cardio: 0, .strength: 0, .lifting: 0]

        for we in workout.exercises {
            let name = we.exercise.name.lowercased()
            if name.contains("run") || name.contains("treadmill") || name.contains("bike")
                || name.contains("cycle")
            {
                score[.cardio, default: 0] += 2
            }
            if name.contains("row") || name.contains("erg") || name.contains("jump") {
                score[.cardio, default: 0] += 1
            }

            switch we.exercise.equipmentRequired {
            case .barbell, .dumbbell, .kettlebell, .machine, .cable:
                score[.lifting, default: 0] += 2
            case .bands, .bodyweight:
                score[.strength, default: 0] += 2
            case .other:
                break
            }
        }

        return score.max { $0.value < $1.value }?.key ?? .strength
    }

    var streakDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        let end = calendar.startOfDay(for: min(selectedDate, today))
        let count = 21

        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: -(count - 1 - offset), to: end)
        }
    }

    var streakWeekDays: [Date] {
        let calendar = sundayFirstCalendar
        let start =
            calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start
            ?? calendar.startOfDay(for: selectedDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var streakVisibleDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)

        // Keep today centered by showing a few days on either side.
        // Future days are displayed but disabled.
        let halfWindow = 10
        let start = calendar.date(byAdding: .day, value: -halfWindow, to: today) ?? today
        return (0..<(halfWindow * 2 + 1)).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    var sundayFirstCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 1
        return calendar
    }

    func recapTimeText(for workout: Workout, isOngoing: Bool) -> String {
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

    func recapSubtitle(for workout: Workout) -> String {
        let groups = primaryMuscleGroups(for: workout)
        if groups.isEmpty {
            return workout.name
        }
        return groups.joined(separator: ", ")
    }

    func primaryMuscleGroups(for workout: Workout) -> [String] {
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

    func prettifyMuscleGroup(_ raw: String) -> String {
        switch raw {
        case "abs": return "Core"
        case "quads": return "Quadriceps"
        default:
            return raw.prefix(1).uppercased() + raw.dropFirst()
        }
    }

    func recapExerciseThumb(_ exercise: Exercise) -> some View {
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

    func recapExerciseRow(_ workoutExercise: WorkoutExercise) -> some View {
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

    func recapExerciseDetail(_ workoutExercise: WorkoutExercise) -> String {
        let groups = workoutExercise.exercise.muscleGroups.prefix(2).map {
            prettifyMuscleGroup($0.rawValue)
        }
        if !workoutExercise.sets.isEmpty {
            let sets = workoutExercise.sets.count
            return "\(groups.joined(separator: ", ")) • \(sets) sets"
        }
        return groups.joined(separator: ", ")
    }

    func thumbIcon(for exercise: Exercise) -> String {
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

    func formatElapsed(_ seconds: TimeInterval) -> String {
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

    func makeDailyWorkoutCounts(startDate: Date, endDate: Date) -> [Date: Int] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [:] }

        var counts: [Date: Int] = [:]

        for workout in bf.getWorkoutHistory() {
            let day = calendar.startOfDay(for: workout.date)
            guard day >= start, day <= end else { continue }
            counts[day, default: 0] += 1
        }

        if bf.getActiveWorkout() != nil {
            // Best-effort: count today's in-progress session if it's inside the selected range.
            let today = calendar.startOfDay(for: Date.now)
            if today >= start, today <= end {
                counts[today, default: 0] += 1
            }
        }

        return counts
    }

    func streakDayPill(for date: Date) -> some View {
        let calendar = sundayFirstCalendar
        let today = Calendar.current.startOfDay(for: Date.now)
        let isToday = Calendar.current.isDate(date, inSameDayAs: today)
        let isFuture = date > today
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

                HStack(spacing: 4) {
                    Text(date.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption.weight(.semibold))

                    Text(date.formatted(.dateTime.day()))
                        .font(.subheadline.weight(.bold))
                        .monospacedDigit()
                }
            }
            .frame(width: 60, height: 64)
            .foregroundStyle(
                isSelected ? selectedText : (isFuture ? Color.secondary : Color.primary)
            )
            .background {
                let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
                if isSelected {
                    shape.fill(selectedFill)
                } else {
                    shape.fill(theme.cardBackground)
                        .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                }
            }
            .overlay {
                if isToday, !isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.accent.opacity(0.45), lineWidth: 1)
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
            .opacity(isFuture ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    var displayRegions: [BodyRegion] {
        BodyRegion.allCases.filter { $0 != .other }
    }

    var weekDays: [Date] {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    func dayBackground(for date: Date) -> AnyShapeStyle {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return AnyShapeStyle(theme.accent.opacity(0.25))
        }
        return AnyShapeStyle(theme.cardBackground)
    }

    func isDateInCurrentStreak(_ date: Date) -> Bool {
        guard currentStreak > 0, let lastWorkoutDate else {
            return false
        }

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let lastDay = calendar.startOfDay(for: lastWorkoutDate)
        let difference = calendar.dateComponents([.day], from: day, to: lastDay).day ?? Int.max

        return difference >= 0 && difference < currentStreak
    }

    func refreshStatuses() {
        var next: [BodyRegion: RecoveryStatus] = [:]
        for region in displayRegions {
            next[region] = bf.bodyMapManager.getRecoveryStatus(for: region)
        }
        statuses = next

        if statuses[selectedRegion] == nil {
            selectedRegion = displayRegions.first ?? .core
        }
    }

    func statusPercent(_ status: RecoveryStatus) -> Double {
        switch status {
        case .recovered: return 100
        case .slightlyFatigued: return 75
        case .fatigued: return 50
        case .sore: return 25
        }
    }

    func statusLabel(_ status: RecoveryStatus) -> String {
        switch status {
        case .recovered: return "Recovered"
        case .slightlyFatigued: return "Slightly fatigued"
        case .fatigued: return "Fatigued"
        case .sore: return "Sore"
        }
    }

    func statusSubtitle(_ status: RecoveryStatus) -> String {
        switch status {
        case .recovered: return "Fresh muscle group"
        case .slightlyFatigued: return "Trainable with moderation"
        case .fatigued: return "Consider reduced intensity"
        case .sore: return "Rest recommended"
        }
    }

    func regionDisplayName(_ region: BodyRegion) -> String {
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

    func quickAddWorkout() {
        // Placeholder action; we can later wire this to a workout builder.
        generateWorkout()
    }

    func startEmptyWorkout() {
        // Placeholder. For now, just refresh recovery so the screen feels alive.
        refreshStatuses()
    }

    func generateWorkout() {
        // Keep a tiny demo flow: use BetterFit's API path where possible.
        if let workout = bf.getRecommendedWorkout() {
            bf.startWorkout(workout)
            bf.completeWorkout(workout)
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

            bf.startWorkout(workout)
            bf.completeWorkout(workout)
        }

        refreshStatuses()
    }

    func ensureDemoSeededIfNeeded() {
        guard isDemoMode else { return }
        guard !didSeedDemoData else { return }

        let seeded = BetterFit()
        seedDemoData(into: seeded)
        demoBetterFit = seeded
        didSeedDemoData = true
    }

    func seedDemoData(into bf: BetterFit) {
        // Profile
        var profile = bf.socialManager.getUserProfile()
        profile.username = "Demo"
        bf.socialManager.updateUserProfile(profile)

        // Templates + plan so the built-in recommendation path returns something.
        let bench = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )
        let row = Exercise(
            name: "Cable Row",
            equipmentRequired: .cable,
            muscleGroups: [.back, .lats]
        )
        let squat = Exercise(
            name: "Back Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        let press = Exercise(
            name: "Overhead Press",
            equipmentRequired: .dumbbell,
            muscleGroups: [.shoulders, .triceps]
        )
        let curl = Exercise(
            name: "Dumbbell Curl",
            equipmentRequired: .dumbbell,
            muscleGroups: [.biceps]
        )
        let hinge = Exercise(
            name: "Romanian Deadlift",
            equipmentRequired: .barbell,
            muscleGroups: [.hamstrings, .glutes]
        )
        let core = Exercise(
            name: "Plank",
            equipmentRequired: .bodyweight,
            muscleGroups: [.abs]
        )

        let pushDay = WorkoutTemplate(
            name: "Push Day",
            description: "Chest + shoulders + triceps",
            exercises: [
                TemplateExercise(
                    exercise: bench,
                    targetSets: [
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 6, weight: 65),
                    ]
                ),
                TemplateExercise(
                    exercise: press,
                    targetSets: [TargetSet(reps: 10, weight: 18), TargetSet(reps: 10, weight: 18)]
                ),
            ],
            tags: ["strength", "upper"]
        )

        let pullDay = WorkoutTemplate(
            name: "Pull Day",
            description: "Back + biceps",
            exercises: [
                TemplateExercise(
                    exercise: row,
                    targetSets: [TargetSet(reps: 12, weight: 45), TargetSet(reps: 10, weight: 50)]
                ),
                TemplateExercise(
                    exercise: curl,
                    targetSets: [TargetSet(reps: 12, weight: 12), TargetSet(reps: 10, weight: 12)]
                ),
            ],
            tags: ["strength", "upper"]
        )

        let legsDay = WorkoutTemplate(
            name: "Leg Day",
            description: "Quads + hamstrings + glutes",
            exercises: [
                TemplateExercise(
                    exercise: squat,
                    targetSets: [TargetSet(reps: 5, weight: 90), TargetSet(reps: 5, weight: 90)]
                ),
                TemplateExercise(
                    exercise: hinge,
                    targetSets: [TargetSet(reps: 8, weight: 80), TargetSet(reps: 8, weight: 80)]
                ),
                TemplateExercise(exercise: core, targetSets: [TargetSet(reps: 60, weight: nil)]),
            ],
            tags: ["strength", "lower"]
        )

        [pushDay, pullDay, legsDay].forEach { bf.templateManager.addTemplate($0) }

        let plan = TrainingPlan(
            name: "Demo Plan",
            description: "A simple 3-day split with realistic history.",
            weeks: [
                TrainingWeek(weekNumber: 1, workouts: [pushDay.id, pullDay.id, legsDay.id])
            ],
            goal: .hypertrophy
        )
        bf.planManager.addPlan(plan)
        bf.planManager.setActivePlan(plan.id)

        // Workout history (3x/week for ~12 weeks, with occasional doubles).
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date.now)
        let start = calendar.date(byAdding: .day, value: -84, to: today) ?? today

        func demoMix(_ x: UInt64) -> UInt64 {
            var z = x &+ 0x9E37_79B9_7F4A_7C15
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }

        func demoUnit(_ a: Int, _ b: Int = 0) -> Double {
            let mixed = demoMix(UInt64(bitPattern: Int64(a * 1_000_003 + b * 97)))
            return Double(mixed % 10_000) / 10_000.0
        }

        let run = Exercise(
            name: "Easy Run",
            equipmentRequired: .bodyweight,
            muscleGroups: [.quads, .calves]
        )

        var workoutEvents: [Workout] = []
        for dayOffset in 0...84 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: start) else {
                continue
            }

            let r = demoUnit(dayOffset)
            let isStrengthDay = r < 0.42
            let isCardioDay = !isStrengthDay && r < 0.57
            guard isStrengthDay || isCardioDay else { continue }

            let hour = 6 + Int(demoUnit(dayOffset, 1) * 11)  // 6...16
            let minute = Int(demoUnit(dayOffset, 2) * 60)
            let dateWithTime =
                calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
                ?? day

            if isCardioDay {
                let minutes = 22 + Int(demoUnit(dayOffset, 3) * 35)  // 22...56
                let workout = Workout(
                    name: demoUnit(dayOffset, 4) < 0.5 ? "Easy Run" : "Bike Ride",
                    exercises: [
                        WorkoutExercise(exercise: run, sets: [ExerciseSet(reps: 1, weight: nil)])
                    ],
                    date: dateWithTime,
                    duration: TimeInterval(minutes * 60),
                    isCompleted: true
                )
                workoutEvents.append(workout)
            } else {
                let templatePick = Int(demoUnit(dayOffset, 5) * 3) % 3
                let template = [pushDay, pullDay, legsDay][templatePick]

                var workout = template.createWorkout()
                workout.date = dateWithTime
                workout.duration = TimeInterval((32 + Int(demoUnit(dayOffset, 6) * 28)) * 60)  // 32...60m
                workout.isCompleted = true
                workoutEvents.append(workout)

                // Occasionally add a second shorter session on the same day.
                if demoUnit(dayOffset, 7) < 0.12 {
                    let extraMinute = Int(demoUnit(dayOffset, 8) * 50)
                    let extraDate =
                        calendar.date(byAdding: .minute, value: 90 + extraMinute, to: dateWithTime)
                        ?? dateWithTime

                    let bonus = Workout(
                        name: demoUnit(dayOffset, 9) < 0.5 ? "Core Finisher" : "Mobility",
                        exercises: [
                            WorkoutExercise(exercise: core, sets: [ExerciseSet(reps: 60)]),
                            WorkoutExercise(
                                exercise: Exercise(
                                    name: "Hollow Hold",
                                    equipmentRequired: .bodyweight,
                                    muscleGroups: [.abs]
                                ),
                                sets: [ExerciseSet(reps: 45)]
                            ),
                        ],
                        date: extraDate,
                        duration: TimeInterval(15 * 60),
                        isCompleted: true
                    )
                    workoutEvents.append(bonus)
                }
            }
        }

        workoutEvents.forEach { bf.completeWorkout($0) }
    }
}
