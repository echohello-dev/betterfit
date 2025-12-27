import BetterFit
import SwiftUI

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    @State private var selectedTab = 0
    @State private var showingSearch = false
    @State private var showingWorkoutAlreadyActiveAlert = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        WorkoutHomeView(betterFit: betterFit, theme: theme)
                    }
                case 1:
                    NavigationStack {
                        TrendsView(theme: theme)
                    }
                case 2:
                    NavigationStack {
                        RecoveryView(betterFit: betterFit, theme: theme)
                    }
                case 3:
                    NavigationStack {
                        ProfileView(theme: theme)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating nav bar
            FloatingNavBar(selectedTab: $selectedTab, theme: theme) {
                showingSearch = true
            }

        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .overlay(alignment: .topTrailing) {
            if selectedTab == 0 {
                StartWorkoutTopButton(theme: theme) {
                    if betterFit.getActiveWorkout() != nil {
                        showingWorkoutAlreadyActiveAlert = true
                    } else {
                        startRecommendedOrQuickWorkout()
                    }
                }
                .padding(.top, 10)
                .padding(.trailing, 16)
            }
        }
        .alert("Workout already in progress", isPresented: $showingWorkoutAlreadyActiveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You already have an active workout running.")
        }
        .sheet(isPresented: $showingSearch) {
            AppSearchView(theme: theme, betterFit: betterFit)
                .presentationDetents([.large])
        }
    }

    private func startRecommendedOrQuickWorkout() {
        if let workout = betterFit.getRecommendedWorkout() {
            betterFit.startWorkout(workout)
            return
        }

        let exercise = Exercise(
            name: "Quick Session",
            equipmentRequired: .bodyweight,
            muscleGroups: [.abs, .quads]
        )

        let workout = Workout(
            name: "Quick Session",
            exercises: [
                WorkoutExercise(exercise: exercise, sets: [ExerciseSet(reps: 1, weight: 0)])
            ]
        )

        betterFit.startWorkout(workout)
    }
}

struct FloatingNavBar: View {
    @Binding var selectedTab: Int
    let theme: AppTheme
    let onSearch: () -> Void

    @Namespace private var glassNamespace

    var body: some View {
        HStack(spacing: 12) {
            navPill
            searchPill
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var navPill: some View {
        pill {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 12) {
                    HStack(spacing: 12) {
                        NavButton(
                            icon: "figure.run",
                            isSelected: selectedTab == 0,
                            theme: theme
                        ) {
                            selectedTab = 0
                        }
                        .glassEffectID("tab.workout", in: glassNamespace)

                        NavButton(
                            icon: "waveform",
                            label: "Plan",
                            isSelected: selectedTab == 1,
                            theme: theme
                        ) {
                            selectedTab = 1
                        }
                        .glassEffectID("tab.plan", in: glassNamespace)

                        NavButton(
                            icon: "clock",
                            isSelected: selectedTab == 2,
                            theme: theme
                        ) {
                            selectedTab = 2
                        }
                        .glassEffectID("tab.recovery", in: glassNamespace)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    NavButton(
                        icon: "figure.run",
                        isSelected: selectedTab == 0,
                        theme: theme
                    ) {
                        selectedTab = 0
                    }

                    NavButton(
                        icon: "waveform",
                        label: "Plan",
                        isSelected: selectedTab == 1,
                        theme: theme
                    ) {
                        selectedTab = 1
                    }

                    NavButton(
                        icon: "clock",
                        isSelected: selectedTab == 2,
                        theme: theme
                    ) {
                        selectedTab = 2
                    }
                }
            }
        }
    }

    private var searchPill: some View {
        pill {
            BFChromeIconButton(
                systemImage: "magnifyingglass",
                accessibilityLabel: "Search",
                theme: theme
            ) {
                onSearch()
            }
            .frame(width: 44, height: 44)
        }
    }

    private func pill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background {
                if #available(iOS 26.0, *) {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular.interactive(), in: Capsule())
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay { Capsule().stroke(theme.cardStroke, lineWidth: 1) }
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
}

private struct StartWorkoutTopButton: View {
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Start Workout", systemImage: "play.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background {
                    Capsule().fill(theme.accent)
                }
        }
        .buttonStyle(.plain)
        .shadow(
            color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.24 : 0.14),
            radius: 10,
            x: 0,
            y: 6
        )
        .accessibilityLabel("Start Workout")
    }
}

struct NavButton: View {
    let icon: String
    var label: String?
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .symbolEffect(.bounce, value: isSelected)

                if let label = label {
                    Text(label)
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(isSelected ? theme.accent : .primary)
            .frame(height: 44)
            .padding(.horizontal, label != nil ? 20 : 16)
            .background {
                if isSelected {
                    Capsule()
                        .fill(theme.accent.opacity(0.15))
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .modifier(NavButtonGlassStyle(isSelected: isSelected, theme: theme))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.snappy(duration: 0.15)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

private struct NavButtonGlassStyle: ViewModifier {
    let isSelected: Bool
    let theme: AppTheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content
        }
    }
}

#Preview {
    let theme: AppTheme = .defaultTheme
    RootTabView(betterFit: BetterFit(), theme: theme)
        .tint(theme.accent)
        .preferredColorScheme(theme.preferredColorScheme)
}
