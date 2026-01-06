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
        Group {
            if #available(iOS 26.0, *) {
                TabView(selection: $selectedTab) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        Tab(value: tab, role: tab == .search ? .search : nil) {
                            tabContent(for: tab)
                        } label: {
                            Label(tab.title, systemImage: tab.icon)
                        }
                    }
                }
                .tint(theme.accent)
                .tabBarMinimizeBehavior(.onScrollDown)
                .onChange(of: selectedTab) { oldTab, newTab in
                    if newTab == .search && oldTab != .search {
                        previousTab = oldTab
                    }
                }
                .tabViewBottomAccessory {
                    BottomAccessoryStack(
                        hasActiveWorkout: hasActiveWorkout,
                        isWorkoutPaused: $isWorkoutPaused,
                        showStopConfirmation: $showStopConfirmation,
                        isGuest: isGuest,
                        showGuestBanner: $showGuestBanner,
                        isSupabaseConfigured: isSupabaseConfigured,
                        theme: theme,
                        onStartOrResume: startOrResumeWorkout,
                        onTogglePause: togglePause,
                        onComplete: completeWorkout,
                        onCancel: cancelWorkout,
                        onShowSignIn: onShowSignIn
                    )
                }
            } else {
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
            }
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
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)
        let isActive = hasActiveWorkout

        if isActive {
            // Active workout: show control buttons
            activeWorkoutControls(shape: shape)
        } else {
            // No active workout: show start button
            Button {
                startOrResumeWorkout()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.black)

                    Text("Start Workout")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black.opacity(0.6))
                }
                .padding(.horizontal, 24)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background {
                    if #available(iOS 26.0, *) {
                        shape
                            .fill(Color.yellow)
                            .glassEffect(.regular.interactive(), in: shape)
                    } else {
                        shape
                            .fill(Color.yellow)
                            .overlay { shape.stroke(Color.yellow.opacity(0.3), lineWidth: 1) }
                            .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start Workout")
        }
    }

    @ViewBuilder
    private func activeWorkoutControls(shape: RoundedRectangle) -> some View {
        HStack(spacing: 12) {
            // Pause/Resume button
            Button {
                togglePause()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                        .font(.body.weight(.semibold))
                    Text(isWorkoutPaused ? "Resume" : "Pause")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.black)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background {
                    if #available(iOS 26.0, *) {
                        shape
                            .fill(theme.accent)
                            .glassEffect(.regular.interactive(), in: shape)
                    } else {
                        shape
                            .fill(theme.accent)
                            .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isWorkoutPaused ? "Resume Workout" : "Pause Workout")

            // Stop button
            Button {
                showStopConfirmation = true
            } label: {
                Image(systemName: "stop.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background {
                        if #available(iOS 26.0, *) {
                            Circle()
                                .fill(Color.red.opacity(0.85))
                                .glassEffect(.regular.interactive(), in: Circle())
                        } else {
                            Circle()
                                .fill(Color.red.opacity(0.85))
                                .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 6)
                        }
                    }
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
            // Start a new workout
            var workoutToStart: Workout
            if let recommended = betterFit.getRecommendedWorkout() {
                workoutToStart = recommended
            } else {
                // Create a quick workout if no recommendation available
                workoutToStart = Workout(
                    name: "Quick Workout",
                    exercises: [],
                    date: Date()
                )
            }
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

// MARK: - Bottom Accessory Stack (iOS 26+)

/// Stacked bottom accessory containing guest banner + start workout button
/// Adapts to placement (expanded vs inline) for proper minimize behavior
@available(iOS 26.0, *)
private struct BottomAccessoryStack: View {
    @Environment(\.tabViewBottomAccessoryPlacement) var placement

    let hasActiveWorkout: Bool
    @Binding var isWorkoutPaused: Bool
    @Binding var showStopConfirmation: Bool
    let isGuest: Bool
    @Binding var showGuestBanner: Bool
    let isSupabaseConfigured: Bool
    let theme: AppTheme
    let onStartOrResume: () -> Void
    let onTogglePause: () -> Void
    let onComplete: () -> Void
    let onCancel: () -> Void
    let onShowSignIn: () -> Void

    private var isCompact: Bool {
        // When placement is nil (undefined) or .inline, treat as compact
        // This handles the initial state before the tab view fully lays out
        guard let placement else { return false }
        return placement == .inline
    }

    var body: some View {
        VStack(spacing: isCompact ? 6 : 10) {
            // Guest mode banner (only show when expanded and guest)
            if isGuest && showGuestBanner && !isCompact {
                guestModeBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Start workout button / active workout controls
            if hasActiveWorkout {
                activeWorkoutAccessory
            } else {
                startWorkoutAccessory
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompact)
        .confirmationDialog(
            "End Workout",
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Complete & Save") {
                onComplete()
            }
            Button("Discard Workout", role: .destructive) {
                onCancel()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Would you like to save this workout or discard it?")
        }
    }

    // MARK: - Guest Mode Banner

    @ViewBuilder
    private var guestModeBanner: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
        let bannerColor: Color = isSupabaseConfigured ? .blue : .orange
        let icon = isSupabaseConfigured ? "info.circle.fill" : "exclamationmark.triangle.fill"
        let message =
            isSupabaseConfigured
            ? "You're in guest mode. Sign in to sync across devices."
            : "Running in guest mode. Cloud features are disabled."

        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(bannerColor)
                .font(.subheadline)

            Text(message)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer(minLength: 0)

            if isSupabaseConfigured {
                Button {
                    onShowSignIn()
                } label: {
                    Text("Sign In")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(bannerColor))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }

            Button {
                withAnimation {
                    showGuestBanner = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            shape
                .fill(bannerColor.opacity(0.2))
                .glassEffect(.regular, in: shape)
        }
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutAccessory: some View {
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)

        Button {
            onStartOrResume()
        } label: {
            HStack(spacing: isCompact ? 6 : 10) {
                Image(systemName: "play.fill")
                    .foregroundStyle(.black)

                if !isCompact {
                    Text("Start Workout")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)

                    Spacer(minLength: 0)
                }

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(.horizontal, isCompact ? 16 : 24)
            .frame(height: isCompact ? 44 : 54)
            .frame(maxWidth: isCompact ? nil : .infinity)
            .background {
                shape
                    .fill(Color.yellow)
                    .glassEffect(.regular.interactive(), in: shape)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start Workout")
    }

    // MARK: - Active Workout Controls

    @ViewBuilder
    private var activeWorkoutAccessory: some View {
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)

        HStack(spacing: isCompact ? 8 : 12) {
            // Pause/Resume button
            Button {
                onTogglePause()
            } label: {
                HStack(spacing: isCompact ? 4 : 8) {
                    Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                        .font(.body.weight(.semibold))
                    if !isCompact {
                        Text(isWorkoutPaused ? "Resume" : "Pause")
                            .font(.body.weight(.semibold))
                    }
                }
                .foregroundStyle(.black)
                .frame(height: isCompact ? 44 : 54)
                .frame(maxWidth: isCompact ? nil : .infinity)
                .padding(.horizontal, isCompact ? 12 : 0)
                .background {
                    shape
                        .fill(theme.accent)
                        .glassEffect(.regular.interactive(), in: shape)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isWorkoutPaused ? "Resume Workout" : "Pause Workout")

            // Stop button
            Button {
                showStopConfirmation = true
            } label: {
                Image(systemName: "stop.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: isCompact ? 44 : 54, height: isCompact ? 44 : 54)
                    .background {
                        Circle()
                            .fill(Color.red.opacity(0.85))
                            .glassEffect(.regular.interactive(), in: Circle())
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop Workout")
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
    .preferredColorScheme(theme.preferredColorScheme)
}
