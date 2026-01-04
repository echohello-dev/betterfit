import BetterFit
import SwiftUI

// MARK: - Personal Record

struct PersonalRecord: Identifiable {
    let id = UUID()
    let exercise: String
    let value: String
    let date: Date
    let improvement: String?
    let icon: String
}

// MARK: - Weekly Goal

struct WeeklyGoal: Identifiable {
    let id = UUID()
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let icon: String
    let color: Color
}

// MARK: - Achievement

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isEarned: Bool
    let earnedDate: Date?
    let progress: Double?
}

// MARK: - Profile View

struct ProfileView: View {
    let betterFit: BetterFit?
    let theme: AppTheme
    let isGuest: Bool
    let onShowSignIn: () -> Void
    let onLogout: (() -> Void)?

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    @State private var showingThemePicker = false
    @State private var showLogoutConfirmation = false
    @State private var showYearlyWrapped = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var isHeatmapExpanded = false
    @State private var heatmapRange: HeatmapRange = .year
    @State private var activityByDay: [Date: Int] = [:]

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled = false
    #endif

    // MARK: - Mock Data

    private var personalRecords: [PersonalRecord] {
        [
            PersonalRecord(
                exercise: "Bench Press", value: "225 lbs",
                date: .now.addingTimeInterval(-86400 * 7), improvement: "+10 lbs",
                icon: "figure.strengthtraining.traditional"),
            PersonalRecord(
                exercise: "Deadlift", value: "315 lbs", date: .now.addingTimeInterval(-86400 * 14),
                improvement: "+15 lbs", icon: "figure.strengthtraining.traditional"),
            PersonalRecord(
                exercise: "Squat", value: "275 lbs", date: .now.addingTimeInterval(-86400 * 3),
                improvement: "+5 lbs", icon: "figure.strengthtraining.traditional"),
            PersonalRecord(
                exercise: "Pull-ups", value: "15 reps", date: .now.addingTimeInterval(-86400 * 5),
                improvement: "+2 reps", icon: "figure.strengthtraining.functional"),
        ]
    }

    private var weeklyGoals: [WeeklyGoal] {
        [
            WeeklyGoal(
                title: "Workouts", current: 4, target: 5, unit: "sessions", icon: "figure.run",
                color: .orange),
            WeeklyGoal(
                title: "Volume", current: 45000, target: 50000, unit: "lbs", icon: "scalemass.fill",
                color: .blue),
            WeeklyGoal(
                title: "Active Time", current: 180, target: 240, unit: "min", icon: "clock.fill",
                color: .purple),
            WeeklyGoal(
                title: "Calories", current: 1800, target: 2500, unit: "cal", icon: "flame.fill",
                color: .red),
        ]
    }

    private var achievements: [Achievement] {
        [
            Achievement(
                title: "Iron Warrior", description: "Complete 100 workouts", icon: "shield.fill",
                isEarned: true, earnedDate: .now.addingTimeInterval(-86400 * 30), progress: nil),
            Achievement(
                title: "Streak Master", description: "Maintain a 30-day streak", icon: "flame.fill",
                isEarned: true, earnedDate: .now.addingTimeInterval(-86400 * 10), progress: nil),
            Achievement(
                title: "Heavy Hitter", description: "Lift 1M total pounds", icon: "bolt.fill",
                isEarned: false, earnedDate: nil, progress: 0.75),
            Achievement(
                title: "Early Bird", description: "Complete 20 morning workouts",
                icon: "sunrise.fill", isEarned: false, earnedDate: nil, progress: 0.45),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Profile Header

                profileHeader

                // MARK: - Guest Notification

                if isGuest {
                    guestNotificationCard
                }

                // MARK: - Health Stats

                healthStatsSection

                // MARK: - Current Streak

                streakSection

                // MARK: - Weekly Targets

                weeklyTargetsSection

                // MARK: - Personal Records

                personalRecordsSection

                // MARK: - Achievements

                achievementsSection

                // MARK: - Yearly Wrapped

                yearlyWrappedSection

                // MARK: - Settings

                settingsSection

                // MARK: - Account

                accountSection

                Spacer(minLength: 40)
            }
            .padding(16)
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Me")
        .confirmationDialog(
            "Sign Out",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                onLogout?()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView(
                selectedTheme: Binding(
                    get: { AppTheme.fromStorage(storedTheme) },
                    set: { storedTheme = $0.rawValue }
                )
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showYearlyWrapped) {
            YearlyWrappedView(theme: theme, year: selectedYear)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.2))
                    .frame(width: 80, height: 80)

                if isGuest {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 36))
                        .foregroundStyle(theme.accent)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(theme.accent)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isGuest ? "Guest" : "Johnny")
                    .bfHeading(theme: theme, size: 24, relativeTo: .title2)

                if !isGuest {
                    Text("Member since Jan 2024")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)

                        Text("Pro Member")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.accent)
                    }
                } else {
                    Text("Sign in to track your progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Guest Notification Card

    private var guestNotificationCard: some View {
        BFCard(theme: theme) {
            HStack(spacing: 14) {
                Image(systemName: "person.badge.plus")
                    .font(.title2)
                    .foregroundStyle(theme.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Create an Account")
                        .font(.subheadline.weight(.semibold))

                    Text("Sync your workouts, track PRs, and unlock achievements")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Button {
                    onShowSignIn()
                } label: {
                    Text("Sign Up")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(theme.accent))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Health Stats Section

    private var healthStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)

                Text("Health Overview")
                    .bfHeading(theme: theme, size: 20, relativeTo: .headline)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                healthStatCard(
                    icon: "figure.stand",
                    label: "BMI",
                    value: "23.4",
                    subtitle: "Normal",
                    color: .green,
                    source: "Apple Health"
                )
                healthStatCard(
                    icon: "scalemass.fill",
                    label: "Strength Score",
                    value: "78",
                    subtitle: "Advanced",
                    color: theme.accent,
                    source: "Calculated"
                )
                healthStatCard(
                    icon: "heart.fill",
                    label: "Resting HR",
                    value: "62",
                    subtitle: "bpm",
                    color: .red,
                    source: "Apple Health"
                )
                healthStatCard(
                    icon: "figure.walk",
                    label: "Active Cal",
                    value: "2,450",
                    subtitle: "Today",
                    color: .orange,
                    source: "Apple Health"
                )
            }
        }
    }

    @ViewBuilder
    private func healthStatCard(
        icon: String, label: String, value: String, subtitle: String, color: Color, source: String
    ) -> some View {
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
                        .monospacedDigit()

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(color)
                }

                Text(source)
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        let currentStreak = betterFit?.socialManager.getCurrentStreak() ?? 24
        let longestStreak = betterFit?.socialManager.getLongestStreak() ?? 42
        let range = heatmapDateRange()

        return VStack(alignment: .leading, spacing: 12) {
            // Compact streak header with expand/collapse
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isHeatmapExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.orange.opacity(0.2))
                            .frame(width: 48, height: 48)

                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(currentStreak)")
                                .font(.system(size: 28, weight: .bold))
                                .monospacedDigit()

                            Text("day streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if longestStreak > currentStreak {
                            Text("Best: \(longestStreak) days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: isHeatmapExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text("This Week")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { day in
                                Circle()
                                    .fill(day < 4 ? theme.accent : theme.accent.opacity(0.2))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                .padding(14)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
                    shape
                        .fill(.regularMaterial)
                        .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                }
            }
            .buttonStyle(.plain)

            // Expanded heatmap content
            if isHeatmapExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Range selector
                    HStack {
                        Menu {
                            Button("1 Week") { heatmapRange = .week }
                            Button("1 Month") { heatmapRange = .month }
                            Button("1 Year") { heatmapRange = .year }
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

                        Text("\(activityByDay.values.reduce(0, +)) workouts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Heatmap
                    ProfileContributionHeatmap(
                        startDate: range.start,
                        endDate: range.end,
                        valuesByDay: activityByDay,
                        theme: theme
                    )
                    .frame(height: 86)
                }
                .padding(14)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
                    shape
                        .fill(.regularMaterial)
                        .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            refreshActivityData()
        }
        .onChange(of: heatmapRange) {
            refreshActivityData()
        }
    }

    private func refreshActivityData() {
        guard let bf = betterFit else {
            activityByDay = [:]
            return
        }

        let range = heatmapDateRange()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: range.start)
        let end = calendar.startOfDay(for: range.end)

        var counts: [Date: Int] = [:]
        for workout in bf.getWorkoutHistory() {
            let day = calendar.startOfDay(for: workout.date)
            guard day >= start, day <= end else { continue }
            counts[day, default: 0] += 1
        }

        if bf.getActiveWorkout() != nil {
            let today = calendar.startOfDay(for: Date.now)
            if today >= start, today <= end {
                counts[today, default: 0] += 1
            }
        }

        activityByDay = counts
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
            return (today, today)
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

    // MARK: - Weekly Targets Section

    private var weeklyTargetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly Targets")
                    .bfHeading(theme: theme, size: 20, relativeTo: .headline)

                Spacer(minLength: 0)

                Button {
                    // Edit targets
                } label: {
                    Text("Edit")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accent)
                }
            }

            VStack(spacing: 10) {
                ForEach(weeklyGoals) { goal in
                    weeklyGoalRow(goal)
                }
            }
        }
    }

    @ViewBuilder
    private func weeklyGoalRow(_ goal: WeeklyGoal) -> some View {
        let progress = min(goal.current / goal.target, 1.0)
        let isCompleted = goal.current >= goal.target

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(goal.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: goal.icon)
                    .font(.subheadline)
                    .foregroundStyle(goal.color)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(goal.title)
                        .font(.subheadline.weight(.semibold))

                    Spacer(minLength: 0)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    Text(formatGoalValue(goal.current, unit: goal.unit))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isCompleted ? .green : .primary)

                    Text("/ \(formatGoalValue(goal.target, unit: goal.unit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(goal.color.opacity(0.2))
                            .frame(height: 6)

                        Capsule()
                            .fill(isCompleted ? .green : goal.color)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
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

    private func formatGoalValue(_ value: Double, unit: String) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return "\(Int(value))"
    }

    // MARK: - Personal Records Section

    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)

                    Text("Personal Records")
                        .bfHeading(theme: theme, size: 20, relativeTo: .headline)
                }

                Spacer(minLength: 0)

                Button {
                    // View all PRs
                } label: {
                    Text("View All")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.accent)
                }
            }

            VStack(spacing: 8) {
                ForEach(personalRecords.prefix(3)) { record in
                    prRow(record)
                }
            }
        }
    }

    @ViewBuilder
    private func prRow(_ record: PersonalRecord) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.yellow.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: record.icon)
                    .font(.subheadline)
                    .foregroundStyle(.yellow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.exercise)
                    .font(.subheadline.weight(.semibold))

                Text(record.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text(record.value)
                    .font(.subheadline.weight(.bold))

                if let improvement = record.improvement {
                    Text(improvement)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
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

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "medal.fill")
                        .font(.caption)
                        .foregroundStyle(theme.accent)

                    Text("Achievements")
                        .bfHeading(theme: theme, size: 20, relativeTo: .headline)
                }

                Spacer(minLength: 0)

                Text("8/24")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements) { achievement in
                        achievementCard(achievement)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func achievementCard(_ achievement: Achievement) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isEarned ? theme.accent.opacity(0.2) : Color.gray.opacity(0.1)
                    )
                    .frame(width: 56, height: 56)

                if let progress = achievement.progress, !achievement.isEarned {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(achievement.isEarned ? theme.accent : .gray)
            }

            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if achievement.isEarned {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if let progress = achievement.progress {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay {
                    shape.stroke(
                        achievement.isEarned ? theme.accent.opacity(0.5) : theme.cardStroke,
                        lineWidth: 1
                    )
                }
        }
    }

    // MARK: - Yearly Wrapped Section

    private var yearlyWrappedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Year in Review")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            Button {
                showYearlyWrapped = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [theme.accent, theme.accent.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)

                        VStack(spacing: 2) {
                            Text("2024")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)

                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("2024 Wrapped")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(
                            "See your fitness journey highlights, top achievements, and stats from the year"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                        HStack(spacing: 4) {
                            Text("View your recap")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.accent)

                            Image(systemName: "arrow.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(theme.accent)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(14)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
                    shape
                        .fill(.regularMaterial)
                        .overlay { shape.stroke(theme.accent.opacity(0.3), lineWidth: 1) }
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            BFCard(theme: theme) {
                VStack(spacing: 0) {
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette.fill")
                                .font(.subheadline)
                                .foregroundStyle(theme.accent)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Theme")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Text(AppTheme.fromStorage(storedTheme).displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                    }
                    .buttonStyle(.plain)

                    Divider().opacity(0.3)

                    settingsRow(icon: "bell.fill", label: "Notifications", value: "On") {
                        // Notifications settings
                    }

                    Divider().opacity(0.3)

                    settingsRow(icon: "heart.fill", label: "Apple Health", value: "Connected") {
                        // Health settings
                    }

                    Divider().opacity(0.3)

                    settingsRow(icon: "ruler.fill", label: "Units", value: "Imperial") {
                        // Units settings
                    }

                    #if DEBUG
                        Divider()
                            .opacity(0.3)

                        Toggle(isOn: $workoutHomeDemoModeEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "testtube.2")
                                    .font(.subheadline)
                                    .foregroundStyle(.purple)
                                    .frame(width: 24)

                                Text("Demo Mode")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Spacer(minLength: 0)
                            }
                            .padding(12)
                        }
                        .toggleStyle(.switch)
                        .tint(theme.accent)
                    #endif
                }
            }
        }
    }

    @ViewBuilder
    private func settingsRow(
        icon: String, label: String, value: String, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(theme.accent)
                    .frame(width: 24)

                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .bfHeading(theme: theme, size: 20, relativeTo: .headline)

            BFCard(theme: theme) {
                VStack(spacing: 0) {
                    settingsRow(icon: "person.fill", label: "Edit Profile", value: "") {
                        // Edit profile
                    }

                    Divider().opacity(0.3)

                    Button {
                        // Privacy action
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                                .frame(width: 24)

                            Text("Privacy Policy")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .opacity(0.3)

                    Button {
                        // Terms action
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .frame(width: 24)

                            Text("Terms of Service")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                    }
                    .buttonStyle(.plain)

                    if !isGuest {
                        Divider()
                            .opacity(0.3)

                        Button(role: .destructive) {
                            showLogoutConfirmation = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.subheadline)
                                    .frame(width: 24)

                                Text("Sign Out")
                                    .font(.subheadline.weight(.semibold))

                                Spacer(minLength: 0)
                            }
                            .padding(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text("BetterFit v1.0.0 (Build 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }
}

// MARK: - Yearly Wrapped View

struct YearlyWrappedView: View {
    let theme: AppTheme
    let year: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    VStack(spacing: 16) {
                        Text("Your \(year) Wrapped")
                            .bfHeading(theme: theme, size: 32, relativeTo: .largeTitle)

                        Text("What a year! Here's your fitness journey at a glance.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // Big Numbers
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        wrappedStatCard(
                            value: "156", label: "Workouts", icon: "figure.run", color: .orange)
                        wrappedStatCard(
                            value: "1.2M", label: "Pounds Lifted", icon: "scalemass.fill",
                            color: .blue)
                        wrappedStatCard(
                            value: "124", label: "Hours Active", icon: "clock.fill", color: .purple)
                        wrappedStatCard(
                            value: "42", label: "Day Streak", icon: "flame.fill", color: .red)
                    }
                    .padding(.horizontal, 16)

                    // Top Exercise
                    VStack(spacing: 12) {
                        Text("Your #1 Exercise")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("Bench Press")
                            .bfHeading(theme: theme, size: 28, relativeTo: .title)

                        Text("You did 248 sets this year!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MVP Month
                    VStack(spacing: 12) {
                        Text("MVP Month")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text("October")
                            .bfHeading(theme: theme, size: 28, relativeTo: .title)

                        Text("24 workouts • 180K lbs lifted")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func wrappedStatCard(value: String, label: String, icon: String, color: Color)
        -> some View
    {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 36, weight: .bold))
                .monospacedDigit()

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
            shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    return NavigationStack {
        ProfileView(
            betterFit: BetterFit(),
            theme: .sunset,
            isGuest: false,
            onShowSignIn: { print("Show sign in") },
            onLogout: { print("Logout") }
        )
    }
}

// MARK: - Profile Contribution Heatmap

private struct ProfileContributionHeatmap: View {
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
    }
}
