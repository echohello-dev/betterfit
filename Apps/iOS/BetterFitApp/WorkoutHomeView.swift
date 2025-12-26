import BetterFit
import SwiftUI

struct WorkoutHomeView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var selectedRegion: BodyRegion = .core
    @State private var statuses: [BodyRegion: RecoveryStatus] = [:]

    @State private var showCalendar = false
    @State private var selectedDate = Date.now

    @State private var showingSearch = false
    @State private var showSubscription = false

    // Gamification
    @State private var currentStreak = 0
    @State private var weeklyGoalProgress = 0.35  // 35% complete

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Section
                welcomeSection

                // Subscription Card
                subscriptionCard

                // Today's Goal Card
                todaysGoalCard

                // Gamification Card
                gamificationCard

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
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showCalendar) {
            CalendarSheetView(selectedDate: $selectedDate, theme: theme)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(theme: theme)
        }
        .onAppear {
            refreshStatuses()
            loadGameStats()
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
        titleRow
    }

    private var subscriptionCard: some View {
        Button {
            showSubscription = true
        } label: {
            BFCard(theme: theme) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("GO Club")
                            .font(.headline)
                            .foregroundStyle(theme.accent)
                        Text("Unlock advanced analytics")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var todaysGoalCard: some View {
        BFCard(theme: theme) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Goal")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)

                HStack(spacing: 20) {
                    GoalStat(icon: "figure.run", value: "0mi", theme: theme)
                    GoalStat(icon: "clock.fill", value: "60min", theme: theme)
                    GoalStat(
                        icon: "flame.fill", value: "\(suggestedWorkout.exercises.count * 500)",
                        theme: theme)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bars
                        HStack(spacing: 2) {
                            ForEach(0..<30, id: \.self) { _ in
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 3)
                            }
                        }

                        // Progress indicator
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 28, height: 28)
                            .offset(x: geometry.size.width * weeklyGoalProgress)
                    }
                }
                .frame(height: 30)
            }
        }
    }

    // MARK: - Gamification Card
    private var gamificationCard: some View {
        Button {
            startWorkout()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Bright yellow background
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.98, green: 0.93, blue: 0.25))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Walk during the Golden hour")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(2)

                    Text("Turn on location to know the best time for your walk.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.black.opacity(0.8))
                        .lineLimit(2)

                    Capsule()
                        .fill(.black)
                        .frame(width: 140, height: 50)
                        .overlay {
                            Text("Continue")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                        }
                }
                .padding(24)

                // Decorative sunrise/sunset graphic (optional)
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.orange.opacity(0.3))
                    .offset(x: 200, y: 40)
            }
            .frame(height: 260)
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
                        LiquidGlassBackground(theme: theme, cornerRadius: 20)
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

#Preview {
    WorkoutHomeView(betterFit: BetterFit(), theme: .forest)
}
