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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                titleRow

                ringPager

                actionButtons

                myWeekCard

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(theme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    GlassEffectContainer(spacing: 16) {
                        HStack(spacing: 10) {
                            BFChromeIconButton(
                                systemImage: "magnifyingglass",
                                accessibilityLabel: "Search",
                                theme: theme
                            ) {
                                showingSearch = true
                            }

                            BFChromeIconButton(
                                systemImage: "calendar",
                                accessibilityLabel: "Calendar",
                                theme: theme
                            ) {
                                showCalendar = true
                            }

                            BFChromeIconButton(
                                systemImage: "plus",
                                accessibilityLabel: "Add",
                                theme: theme
                            ) {
                                quickAddWorkout()
                            }
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        BFChromeIconButton(
                            systemImage: "magnifyingglass",
                            accessibilityLabel: "Search",
                            theme: theme
                        ) {
                            showingSearch = true
                        }

                        BFChromeIconButton(
                            systemImage: "calendar",
                            accessibilityLabel: "Calendar",
                            theme: theme
                        ) {
                            showCalendar = true
                        }

                        BFChromeIconButton(
                            systemImage: "plus",
                            accessibilityLabel: "Add",
                            theme: theme
                        ) {
                            quickAddWorkout()
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
        .onAppear {
            refreshStatuses()
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

    private var ringPager: some View {
        TabView(selection: $selectedRegion) {
            ForEach(displayRegions, id: \.self) { region in
                ringPage(for: region)
                    .tag(region)
                    .padding(.vertical, 8)
            }
        }
        .frame(height: 340)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }

    private func ringPage(for region: BodyRegion) -> some View {
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
