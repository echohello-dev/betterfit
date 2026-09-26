import Auth
import BetterFit
import SwiftUI

enum AppTab: String, CaseIterable {
    case workout
    case body
    case targets
    case log

    var title: String {
        switch self {
        case .workout: "Workout"
        case .body: "Body"
        case .targets: "Targets"
        case .log: "Log"
        }
    }

    var icon: String {
        switch self {
        case .workout: "dumbbell.fill"
        case .body: "figure.run"
        case .targets: "target"
        case .log: "calendar"
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

    var isSupabaseConfigured: Bool = true
    @Binding var showGuestBanner: Bool

    @State private var selectedTab: AppTab = .workout
    @State private var showActiveWorkout = false
    @State private var activeWorkoutId: UUID?
    @State private var isWorkoutPaused = false
    @State private var showStopConfirmation = false
    @State private var showActiveSession = false
    @State private var showSearch = false
    @State private var showProfile = false
    @State private var searchQuery = ""
    @State private var healthKitManager: HealthKitManager?
    @State private var planManager = WorkoutPlanManager()
    @State private var summaryData: WorkoutSummaryData?
    @State private var showSummary = false

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

    private var hasActiveWorkout: Bool {
        activeWorkoutId != nil || betterFit.getActiveWorkout() != nil
    }

    /// Physical bottom inset for the floating Start pill:
    /// home indicator (~34) + tab bar (~49) + 8pt gap.
    private static let startPillBottomInset: CGFloat = 78

    var body: some View {
        tabView
            .tint(BFColors.accentText(for: .dark))
            // Full-width Start button matching the floating tab bar width.
            .overlay(alignment: .bottom) {
                // Hide Plan's Start button while the live workout UI owns the tab.
                if selectedTab == .workout && !showActiveSession {
                    startWorkoutDock
                        .padding(.horizontal, 16)
                        .padding(.bottom, Self.startPillBottomInset)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onAppear {
                if healthKitManager == nil {
                    healthKitManager = HealthKitManager(healthKitService: betterFit.healthKitService)
                }
            }
        // Active session is embedded in the Workout tab (Plan → Workout mode).
        .sheet(isPresented: $showSummary) {
            if let summaryData {
                WorkoutSummaryView(data: summaryData) {
                    showSummary = false
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            AppSearchView(
                theme: theme,
                betterFit: betterFit,
                query: $searchQuery,
                previousTabIcon: "xmark",
                onDismiss: { showSearch = false }
            )
        }
        .sheet(isPresented: $showProfile) {
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

    // MARK: - Tab view

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }

    // MARK: - Start workout pill (standalone)

    @ViewBuilder
    private var startWorkoutDock: some View {
        if hasActiveWorkout {
            activeWorkoutControls
        } else {
            BFDockPrimaryButton(title: "Start workout", systemImage: "play.fill", standalone: false) {
                startOrResumeWorkout()
            }
            .accessibilityLabel("Start workout")
        }
    }

    @ViewBuilder
    private var activeWorkoutControls: some View {
        HStack(spacing: 10) {
            BFDockPrimaryButton(
                title: isWorkoutPaused ? "Resume" : "Pause",
                systemImage: isWorkoutPaused ? "play.fill" : "pause.fill",
                standalone: false
            ) {
                if isWorkoutPaused {
                    togglePause()
                } else {
                    betterFit.pauseWorkout()
                    isWorkoutPaused = true
                    showActiveSession = true
                }
            }
            .accessibilityLabel(isWorkoutPaused ? "Resume workout" : "Pause workout")

            Button {
                showStopConfirmation = true
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(BFColors.background(for: .dark))
                    .frame(width: BFControlSize.buttonLarge, height: BFControlSize.buttonLarge)
                    .background(Circle().fill(Color.white))
                    .shadow(color: Color.black.opacity(0.28), radius: 14, y: 6)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop workout")
        }
        .confirmationDialog(
            "End workout",
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Complete & save") { completeWorkout() }
            Button("Discard workout", role: .destructive) { cancelWorkout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Would you like to save this workout or discard it?")
        }
    }

    // MARK: - Workout actions

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
        selectedTab = .workout

        if hasActiveWorkout {
            // Resume — jump straight into the live session.
            isWorkoutPaused = false
            betterFit.resumeWorkout()
            showActiveSession = true
            return
        }

        // Prefer today's plan (what Plan tab is showing).
        var workoutToStart: Workout
        if let todayPlan = planManager.getTodayPlan(), !todayPlan.exercises.isEmpty {
            workoutToStart = todayPlan.toWorkout()
        } else if let recommended = betterFit.getRecommendedWorkout() {
            workoutToStart = recommended
        } else {
            workoutToStart = Workout(name: "Quick workout", exercises: [], date: Date())
        }

        planManager.setSelectedWorkoutForToday(workoutToStart)
        betterFit.startWorkout(workoutToStart)
        activeWorkoutId = workoutToStart.id
        isWorkoutPaused = false
        NotificationCenter.default.post(name: .workoutStarted, object: workoutToStart.id)
        showActiveSession = true
    }

    // MARK: - Tabs

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .workout:
            NavigationStack {
                if hasActiveWorkout {
                    // Active workout takes over the Workout tab.
                    ActiveSessionView(
                        betterFit: betterFit,
                        theme: theme,
                        onEnd: {
                            completeWorkout()
                            showActiveSession = false
                        },
                        onClose: {
                            // Minimize back to Plan without ending the session.
                            showActiveSession = false
                            isWorkoutPaused = true
                            betterFit.pauseWorkout()
                        },
                        onFinishedSummary: { data in
                            summaryData = data
                            showActiveSession = false
                            showSummary = true
                        },
                        embeddedInTab: true
                    )
                    .navigationBarHidden(true)
                } else {
                    WorkoutHomeView(
                        betterFit: betterFit,
                        theme: theme,
                        healthKitManager: healthKitManager,
                        planManager: planManager,
                        isGuest: isGuest,
                        user: user,
                        onSearch: { showSearch = true },
                        onProfile: { showProfile = true }
                    )
                }
            }
        case .body:
            NavigationStack {
                RecoveryView(betterFit: betterFit, theme: theme)
            }
        case .targets:
            NavigationStack {
                TargetsView(betterFit: betterFit, theme: theme, planManager: planManager)
            }
        case .log:
            NavigationStack {
                LogView(betterFit: betterFit, theme: theme)
            }
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    let theme: AppTheme = .defaultTheme
    return RootTabView(
        betterFit: BetterFit(),
        theme: theme,
        isGuest: false,
        user: nil,
        onShowSignIn: {},
        onLogout: {}
    )
    .preferredColorScheme(.dark)
}
