import Auth
import BetterFit
import SwiftUI

enum AppTab: String, CaseIterable {
    case workout
    case plan
    case search
    case me

    var title: String {
        switch self {
        case .workout: "Workout"
        case .plan: "Plan"
        case .search: "Search"
        case .me: "Me"
        }
    }

    var icon: String {
        switch self {
        case .workout: "figure.run"
        case .plan: "waveform"
        case .search: "magnifyingglass"
        case .me: "person.fill"
        }
    }
}

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    let isGuest: Bool
    let user: Auth.User?
    let onShowSignIn: () -> Void
    let onLogout: (() -> Void)?

    /// Whether Supabase is configured (passed from parent)
    var isSupabaseConfigured: Bool = true
    /// Binding to control banner dismissal state
    @Binding var showGuestBanner: Bool

    @State private var selectedTab: AppTab = .workout
    @State private var previousTab: AppTab = .workout
    @State private var searchQuery = ""
    @State private var showActiveWorkout = false
    @State private var activeWorkoutId: UUID?  // Track for button state updates
    @State private var isWorkoutPaused = false
    @State private var showStopConfirmation = false
    @State private var healthKitManager: HealthKitManager?

    // Shared workout plan manager across views
    @State private var planManager = WorkoutPlanManager()

    init(
        betterFit: BetterFit,
        theme: AppTheme,
        isGuest: Bool,
        user: Auth.User?,
        onShowSignIn: @escaping () -> Void,
        onLogout: (() -> Void)?,
        isSupabaseConfigured: Bool = true,
        showGuestBanner: Binding<Bool> = .constant(false)
    ) {
        self.betterFit = betterFit
        self.theme = theme
        self.isGuest = isGuest
        self.user = user
        self.onShowSignIn = onShowSignIn
        self.onLogout = onLogout
        self.isSupabaseConfigured = isSupabaseConfigured
        self._showGuestBanner = showGuestBanner
    }

    /// Returns the tab to navigate back to when dismissing search
    private var tabToReturnTo: AppTab {
        selectedTab == .search ? previousTab : selectedTab
    }

    /// Check if there's an active workout
    private var hasActiveWorkout: Bool {
        activeWorkoutId != nil || betterFit.getActiveWorkout() != nil
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(theme.accent)
        .onChange(of: selectedTab) { oldTab, newTab in
            if newTab == .search && oldTab != .search {
                previousTab = oldTab
            }
        }
        .safeAreaInset(edge: .bottom) {
            startWorkoutButton
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
        }
        .onAppear {
            if healthKitManager == nil {
                healthKitManager = HealthKitManager(healthKitService: betterFit.healthKitService)
            }
        }
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutButton: some View {
        if hasActiveWorkout {
            activeWorkoutControls
        } else {
            Button {
                startOrResumeWorkout()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")

                    Text("Start Workout")

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .opacity(0.7)
                }
                .padding(.horizontal, BFSpacing.xl)
            }
            .buttonStyle(.bfPrimary)
            .accessibilityLabel("Start Workout")
        }
    }

    @ViewBuilder
    private var activeWorkoutControls: some View {
        HStack(spacing: BFSpacing.md) {
            Button {
                togglePause()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                    Text(isWorkoutPaused ? "Resume" : "Pause")
                }
            }
            .buttonStyle(.bfPrimary)
            .accessibilityLabel(isWorkoutPaused ? "Resume Workout" : "Pause Workout")

            Button {
                showStopConfirmation = true
            } label: {
                Image(systemName: "stop.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: BFControlSize.buttonLarge, height: BFControlSize.buttonLarge)
                    .background(
                        RoundedRectangle(cornerRadius: BFRadius.button, style: .continuous)
                            .fill(BFColors.danger)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop Workout")
        }
        .confirmationDialog(
            "End Workout",
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Complete & Save") {
                completeWorkout()
            }
            Button("Discard Workout", role: .destructive) {
                cancelWorkout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Would you like to save this workout or discard it?")
        }
    }

    private func togglePause() {
        if isWorkoutPaused {
            betterFit.resumeWorkout()
            isWorkoutPaused = false
        } else {
            betterFit.pauseWorkout()
            isWorkoutPaused = true
        }
        NotificationCenter.default.post(
            name: isWorkoutPaused ? .workoutPaused : .workoutResumed,
            object: activeWorkoutId
        )
    }

    private func completeWorkout() {
        if let workout = betterFit.getActiveWorkout() {
            var completedWorkout = workout
            completedWorkout.isCompleted = true
            completedWorkout.duration = Date.now.timeIntervalSince(workout.date)
            betterFit.completeWorkout(completedWorkout)
        }
        activeWorkoutId = nil
        isWorkoutPaused = false
        NotificationCenter.default.post(name: .workoutCompleted, object: nil)
    }

    private func cancelWorkout() {
        betterFit.cancelWorkout()
        activeWorkoutId = nil
        isWorkoutPaused = false
        NotificationCenter.default.post(name: .workoutCompleted, object: nil)
    }

    private func startOrResumeWorkout() {
        if hasActiveWorkout {
            // Navigate to workout tab to show active workout
            selectedTab = .workout
        } else {
            // Start a new workout — prefer today's plan so home/plan stay in sync
            var workoutToStart: Workout
            if let todayPlan = planManager.getTodayPlan(), !todayPlan.exercises.isEmpty {
                workoutToStart = todayPlan.toWorkout()
            } else if let recommended = betterFit.getRecommendedWorkout() {
                workoutToStart = recommended
            } else {
                // Create a quick workout if no recommendation available
                workoutToStart = Workout(
                    name: "Quick Workout",
                    exercises: [],
                    date: Date()
                )
            }
            // Mirror the started workout into the plan so the home preview and Plan tab agree
            planManager.setSelectedWorkoutForToday(workoutToStart)
            betterFit.startWorkout(workoutToStart)

            // Update local state and post notification
            activeWorkoutId = workoutToStart.id
            NotificationCenter.default.post(
                name: .workoutStarted,
                object: workoutToStart.id
            )

            // Navigate to workout tab
            selectedTab = .workout
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .workout:
            NavigationStack {
                WorkoutHomeView(
                    betterFit: betterFit,
                    theme: theme,
                    healthKitManager: healthKitManager,
                    planManager: planManager,
                    isGuest: isGuest,
                    user: user,
                    onShowSignIn: onShowSignIn
                )
            }
        case .plan:
            NavigationStack {
                PlanView(betterFit: betterFit, theme: theme, planManager: planManager)
            }
        case .search:
            AppSearchView(
                theme: theme,
                betterFit: betterFit,
                query: $searchQuery,
                previousTabIcon: tabToReturnTo.icon,
                onDismiss: {
                    withAnimation { selectedTab = tabToReturnTo }
                }
            )
        case .me:
            NavigationStack {
                ProfileView(
                    betterFit: betterFit,
                    theme: theme,
                    isGuest: isGuest,
                    user: user,
                    onShowSignIn: onShowSignIn,
                    onLogout: onLogout
                )
            }
        }
    }
}


#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    let theme: AppTheme = .defaultTheme
    return RootTabView(
        betterFit: BetterFit(), theme: theme, isGuest: false,
        user: nil,
        onShowSignIn: {
            print("Show sign in")
        },
        onLogout: {
            print("Logout")
        }
    )
    .preferredColorScheme(.dark)
}
