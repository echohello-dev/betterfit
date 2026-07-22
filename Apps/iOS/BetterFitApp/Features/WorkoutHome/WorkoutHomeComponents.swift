import BetterFit
import SwiftUI

extension WorkoutHomeView {
    // MARK: - Compact Components

    struct CompactMuscleChip: View {
        @Environment(\.colorScheme) var colorScheme
        let muscle: String
        let percent: Int
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: muscleIcon)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(theme.accent)
                    .frame(width: 14)

                Text(muscle)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(-1)

                Text("\(percent)%")
                    .font(BFTypography.caption)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .fixedSize()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(BFColors.surfaceRaised(for: colorScheme), in: Capsule())
            .overlay { Capsule().stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
        }

        private var muscleIcon: String {
            switch muscle.lowercased() {
            case "back", "lats": return "figure.strengthtraining.traditional"
            case "hamstrings", "legs", "quadriceps", "calves": return "figure.walk"
            case "chest": return "figure.arms.open"
            case "shoulders": return "figure.wrestling"
            case "core", "abs": return "figure.core.training"
            case "biceps", "triceps", "arms": return "figure.boxing"
            default: return "figure.mixed.cardio"
            }
        }
    }

    struct CompactExerciseRow: View {
        @Environment(\.colorScheme) var colorScheme
        let exercise: WorkoutExercise
        let index: Int
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 10) {
                // Index circle
                ZStack {
                    Circle()
                        .fill(theme.accentSurface(0.15, for: colorScheme))
                        .frame(width: 28, height: 28)
                    Text("\(index + 1)")
                        .font(BFTypography.captionEmphasis)
                        .monospacedDigit()
                        .foregroundStyle(theme.accent)
                }

                // Exercise icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: categoryIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }

                // Name and category
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.exercise.name)
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    Text(categoryName)
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }

                Spacer()

                // Sets info
                Text(setsInfo)
                    .font(BFTypography.captionEmphasis)
                    .monospacedDigit()
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                // Category icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: categoryIcon)
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(categoryColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BFColors.surface(for: colorScheme))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                    }
            }
        }

        private var categoryName: String {
            let name = exercise.exercise.name.lowercased()
            if name.contains("run") || name.contains("cardio") { return "Cardio" }
            if name.contains("press") || name.contains("push") { return "Push" }
            if name.contains("row") || name.contains("pull") { return "Pull" }
            if name.contains("squat") || name.contains("leg") { return "Legs" }
            return "Compound"
        }

        private var setsInfo: String {
            let sets = exercise.sets.count
            let reps = exercise.sets.first?.reps ?? 0
            return "\(sets) sets × \(reps)"
        }

        private var gradientColors: [Color] {
            let name = exercise.exercise.name.lowercased()
            if name.contains("run") || name.contains("cardio") { return [.red, .orange] }
            if name.contains("press") || name.contains("push") { return [.blue, .cyan] }
            if name.contains("row") || name.contains("pull") { return [.purple, .pink] }
            if name.contains("squat") || name.contains("leg") { return [.orange, .yellow] }
            return [.green, .teal]
        }

        private var categoryIcon: String {
            let name = exercise.exercise.name.lowercased()
            if name.contains("run") { return "figure.run" }
            if name.contains("press") { return "arrow.up" }
            if name.contains("row") || name.contains("pull") { return "arrow.down" }
            if name.contains("squat") || name.contains("leg") { return "figure.walk" }
            return "dumbbell"
        }

        private var categoryColor: Color {
            let name = exercise.exercise.name.lowercased()
            if name.contains("run") || name.contains("cardio") { return .red }
            if name.contains("press") || name.contains("push") { return .blue }
            if name.contains("row") || name.contains("pull") { return .purple }
            if name.contains("squat") || name.contains("leg") { return .orange }
            return .green
        }
    }

    // MARK: - Components

    struct WorkoutSwipeCard: View {
        @Environment(\.colorScheme) var colorScheme
        let workout: Workout
        let theme: AppTheme
        let isTopCard: Bool

        var body: some View {
            HStack(spacing: 16) {
                // Workout icon/image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.accentSurface(0.15, for: colorScheme))
                        .frame(width: 100, height: 140)

                    VStack(spacing: 8) {
                        Image(systemName: iconForWorkout)
                            .font(.system(size: 36))
                            .foregroundStyle(theme.accent)

                        Text(workoutType)
                            .font(BFTypography.captionEmphasis)
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
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))

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
                RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                    .fill(BFColors.surface(for: colorScheme))
                    .overlay {
                        RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                            .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
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
                .font(BFTypography.captionEmphasis)
                .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(BFColors.surfaceRaised(for: colorScheme), in: Capsule())
                .overlay { Capsule().stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
        }
    }

    struct TargetMuscleView: View {
        @Environment(\.colorScheme) var colorScheme
        let muscle: String
        let percent: Int
        let theme: AppTheme

        var body: some View {
            VStack(spacing: 8) {
                // Body silhouette placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.accentSurface(0.12, for: colorScheme))
                        .frame(width: 60, height: 70)

                    Image(systemName: muscleIcon)
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                }

                VStack(spacing: 2) {
                    Text(muscle)
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                    Text("\(percent)%")
                        .font(BFTypography.caption)
                        .monospacedDigit()
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BFColors.surfaceRaised(for: colorScheme), in: Capsule())
                }
            }
        }

        private var muscleIcon: String {
            switch muscle.lowercased() {
            case "back", "lats": return "figure.strengthtraining.traditional"
            case "hamstrings", "legs", "quadriceps": return "figure.walk"
            case "chest": return "figure.arms.open"
            case "shoulders": return "figure.wrestling"
            case "core", "abs": return "figure.core.training"
            case "biceps", "triceps", "arms": return "figure.boxing"
            default: return "figure.mixed.cardio"
            }
        }
    }

    struct ExercisePreviewRow: View {
        @Environment(\.colorScheme) var colorScheme
        let exercise: WorkoutExercise
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 12) {
                // Exercise image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.accentSurface(0.12, for: colorScheme))
                        .frame(width: 64, height: 64)

                    Image(systemName: exerciseIcon)
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(BFTypography.subheadlineEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                    Text(exerciseDetails)
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }

                Spacer()

                Menu {
                    Button("Swap Exercise") {}
                    Button("Adjust Sets") {}
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .frame(width: 30, height: 30)
                }
            }
            .padding(12)
            .background {
                let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
                shape
                    .fill(BFColors.surface(for: colorScheme))
                    .overlay { shape.stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
            }
        }

        private var exerciseIcon: String {
            let name = exercise.exercise.name.lowercased()
            if name.contains("row") { return "figure.rowing" }
            if name.contains("curl") { return "dumbbell.fill" }
            if name.contains("press") { return "figure.strengthtraining.traditional" }
            if name.contains("squat") { return "figure.walk" }
            if name.contains("run") { return "figure.run" }
            return "dumbbell.fill"
        }

        private var exerciseDetails: String {
            let sets = exercise.sets.count
            let reps = exercise.sets.first?.reps ?? 0
            let weight = exercise.sets.first?.weight

            if let weightVal = weight, weightVal > 0 {
                return "\(sets) sets • \(reps) reps • \(Int(weightVal)) kg"
            } else {
                return "\(sets) sets • \(reps) reps"
            }
        }
    }

    struct SemiCircularGauge: View {
        @Environment(\.colorScheme) var colorScheme
        let value: Double
        let theme: AppTheme

        var body: some View {
            let clamped = min(max(value, 0), 1)

            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(
                        BFColors.border(for: colorScheme).opacity(0.5),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )

                Circle()
                    .trim(from: 0, to: 0.5 * clamped)
                    .stroke(
                        theme.accent,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )

                Rectangle()
                    .fill(theme.accentSurface(0.9, for: colorScheme))
                    .frame(width: 44, height: 2)
                    .offset(x: 22)
                    .rotationEffect(.degrees(180 * clamped))

                Circle()
                    .fill(BFColors.surface(for: colorScheme))
                    .frame(width: 10, height: 10)
                    .overlay { Circle().stroke(BFColors.border(for: colorScheme), lineWidth: 1) }
            }
            .padding(.top, 2)
            .padding(.horizontal, 2)
        }
    }

    struct OverviewStat: View {
        @Environment(\.colorScheme) var colorScheme
        let title: String
        let value: String
        let systemImage: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(BFTypography.captionEmphasis)
                    .foregroundStyle(theme.accent)

                VStack(alignment: .leading, spacing: 0) {
                    Text(value)
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                        .monospacedDigit()
                    Text(title)
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                }
            }
        }
    }

    struct CategoryLegendDot: View {
        @Environment(\.colorScheme) var colorScheme
        let label: String
        let percent: Int
        let color: Color
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text("\(label) \(percent)%")
                    .font(BFTypography.caption)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .monospacedDigit()
            }
        }
    }

    struct GoalStat: View {
        let icon: String
        let value: String
        let theme: AppTheme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(BFTypography.caption)
                Text(value)
                    .font(BFTypography.headline)
            }
            .foregroundStyle(.white)
        }
    }

    struct WorkoutSuggestionCard: View {
        @Environment(\.colorScheme) var colorScheme
        let workout: Workout
        let theme: AppTheme
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 12) {
                    // Preview image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.accentSurface(0.3, for: colorScheme))
                            .frame(height: 140)

                        Image(systemName: iconForWorkout)
                            .font(.system(size: 48))
                            .foregroundStyle(theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(BFTypography.headline)
                            .foregroundStyle(BFColors.textPrimary(for: colorScheme))
                            .lineLimit(2)

                        HStack(spacing: 12) {
                            Label(
                                "\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            Label("30min", systemImage: "clock")
                        }
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }

                    Spacer()
                }
                .frame(width: 200)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                        .fill(BFColors.surface(for: colorScheme))
                        .overlay {
                            RoundedRectangle(cornerRadius: BFRadius.card, style: .continuous)
                                .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
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
                    .font(BFTypography.headline)

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    struct SubscriptionView: View {
        let theme: AppTheme
        @Environment(\.dismiss) private var dismiss
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
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
                        .font(BFTypography.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

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
                                .font(BFTypography.headline)
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
                        .font(BFTypography.subheadline)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }
                    .padding()
                }
                .bfBackground(theme: theme)
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

    struct CustomHeatmapRangeSheet: View {
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
                .bfBackground(theme: theme)
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
                        .font(BFTypography.headline)
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

    struct ContributionHeatmap: View {
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
                .onChange(of: startDate) {
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
            @Environment(\.colorScheme) var colorScheme
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
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

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
            @Environment(\.colorScheme) var colorScheme
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
                                    .stroke(BFColors.border(for: colorScheme).opacity(0.7), lineWidth: 0.5)
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
                    return theme.accentSurface(0, for: colorScheme)
                case 1:
                    return theme.accentSurface(0.18, for: colorScheme)
                case 2:
                    return theme.accentSurface(0.34, for: colorScheme)
                case 3:
                    return theme.accentSurface(0.52, for: colorScheme)
                default:
                    return theme.accentSurface(0.75, for: colorScheme)
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

    // MARK: - Equipment Swap Sheet
    struct EquipmentSwapSheet: View {
        let theme: AppTheme
        @Binding var availableEquipment: Set<Equipment>
        let onApply: () -> Void

        @Environment(\.dismiss) private var dismiss
        @Environment(\.colorScheme) var colorScheme

        // Gym location presets
        private let gymPresets: [(name: String, icon: String, equipment: Set<Equipment>)] = [
            (
                "Full Gym",
                "building.2.fill",
                Set(Equipment.allCases)
            ),
            (
                "Home Gym",
                "house.fill",
                [.dumbbell, .kettlebell, .bands, .bodyweight]
            ),
            (
                "Hotel / Travel",
                "suitcase.fill",
                [.bodyweight, .bands]
            ),
            (
                "Outdoor / Park",
                "leaf.fill",
                [.bodyweight]
            ),
            (
                "Cable Only",
                "cable.coaxial",
                [.cable, .machine, .bodyweight]
            ),
        ]

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Location presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Select")
                                .font(BFTypography.headline)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                ],
                                spacing: 12
                            ) {
                                ForEach(gymPresets, id: \.name) { preset in
                                    GymPresetButton(
                                        name: preset.name,
                                        icon: preset.icon,
                                        isSelected: availableEquipment == preset.equipment,
                                        theme: theme
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            availableEquipment = preset.equipment
                                        }
                                    }
                                }
                            }
                        }

                        BFDivider()

                        // Individual equipment toggles
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Equipment")
                                .font(BFTypography.headline)

                            ForEach(Equipment.allCases, id: \.self) { equipment in
                                EquipmentToggleRow(
                                    equipment: equipment,
                                    isSelected: availableEquipment.contains(equipment),
                                    theme: theme
                                ) {
                                    withAnimation(.spring(response: 0.2)) {
                                        if availableEquipment.contains(equipment) {
                                            availableEquipment.remove(equipment)
                                        } else {
                                            availableEquipment.insert(equipment)
                                        }
                                    }
                                }
                            }
                        }

                        // Info text
                        Text(
                            "Exercises will be automatically swapped to alternatives based on your available equipment."
                        )
                        .font(BFTypography.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                        .padding(.top, 8)
                    }
                    .padding()
                }
                .bfBackground(theme: theme)
                .navigationTitle("Swap Equipment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Apply") {
                            onApply()
                            dismiss()
                        }
                        .font(BFTypography.headline)
                    }
                }
            }
        }
    }

    struct GymPresetButton: View {
        @Environment(\.colorScheme) var colorScheme
        let name: String
        let icon: String
        let isSelected: Bool
        let theme: AppTheme
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(
                            isSelected ? theme.accent : BFColors.textSecondary(for: colorScheme))

                    Text(name)
                        .font(BFTypography.captionEmphasis)
                        .foregroundStyle(
                            isSelected
                                ? BFColors.textPrimary(for: colorScheme)
                                : BFColors.textSecondary(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
                    if isSelected {
                        shape
                            .fill(theme.accentSurface(0.15, for: colorScheme))
                            .overlay {
                                shape.stroke(theme.accent, lineWidth: 2)
                            }
                    } else {
                        shape
                            .fill(BFColors.surface(for: colorScheme))
                            .overlay {
                                shape.stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                            }
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    struct EquipmentToggleRow: View {
        @Environment(\.colorScheme) var colorScheme
        let equipment: Equipment
        let isSelected: Bool
        let theme: AppTheme
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(systemName: iconForEquipment)
                        .font(.title3)
                        .foregroundStyle(
                            isSelected ? theme.accent : BFColors.textSecondary(for: colorScheme))
                        .frame(width: 32)

                    Text(equipment.rawValue.capitalized)
                        .font(BFTypography.body)
                        .foregroundStyle(BFColors.textPrimary(for: colorScheme))

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(
                            isSelected
                                ? theme.accent
                                : BFColors.textTertiary(for: colorScheme).opacity(0.5))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
                    shape
                        .fill(BFColors.surface(for: colorScheme))
                        .overlay {
                            shape.stroke(
                                isSelected ? theme.accentSurface(0.5, for: colorScheme) : BFColors.border(for: colorScheme),
                                lineWidth: 1
                            )
                        }
                }
            }
            .buttonStyle(.plain)
        }

        private var iconForEquipment: String {
            switch equipment {
            case .barbell: return "figure.strengthtraining.traditional"
            case .dumbbell: return "dumbbell.fill"
            case .kettlebell: return "figure.highintensity.intervaltraining"
            case .machine: return "gearshape.2.fill"
            case .cable: return "cable.coaxial"
            case .bodyweight: return "figure.core.training"
            case .bands: return "circle.dotted"
            case .other: return "ellipsis.circle"
            }
        }
    }
}
