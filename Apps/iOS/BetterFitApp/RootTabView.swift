import BetterFit
import SwiftUI

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme
    @State private var selectedTab = 0
    @State private var isSearchPresented = false
    @State private var searchQuery: String = ""
    @State private var showingWorkoutAlreadyActiveAlert = false

    private let bottomStackHorizontalPadding: CGFloat = 12
    private let bottomStackBottomPadding: CGFloat = 8
    private let bottomStackSpacing: CGFloat = 10

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        WorkoutHomeView(betterFit: betterFit, theme: theme)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                case 1:
                    NavigationStack {
                        TrendsView(theme: theme)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                case 2:
                    NavigationStack {
                        RecoveryView(betterFit: betterFit, theme: theme)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                case 3:
                    NavigationStack {
                        ProfileView(theme: theme)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(!isSearchPresented)

            if isSearchPresented {
                AppSearchView(theme: theme, betterFit: betterFit, query: $searchQuery)
                    .transition(.opacity)
            }

            VStack(spacing: bottomStackSpacing) {
                if selectedTab == 0 && !isSearchPresented {
                    StartWorkoutBottomBar(theme: theme) {
                        if betterFit.getActiveWorkout() != nil {
                            showingWorkoutAlreadyActiveAlert = true
                        } else {
                            startRecommendedOrQuickWorkout()
                        }
                    }
                }

                FloatingNavBar(
                    selectedTab: $selectedTab,
                    theme: theme,
                    isSearchPresented: $isSearchPresented,
                    searchQuery: $searchQuery
                )
            }
            .padding(.horizontal, bottomStackHorizontalPadding)
            .padding(.bottom, bottomStackBottomPadding)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Workout already in progress", isPresented: $showingWorkoutAlreadyActiveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You already have an active workout running.")
        }
    }

    private func startRecommendedOrQuickWorkout() {
        guard betterFit.getActiveWorkout() == nil else {
            return
        }

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
    @Binding var isSearchPresented: Bool
    @Binding var searchQuery: String

    private let pillInnerVerticalPadding: CGFloat = 4
    private let clusterSpacing: CGFloat = 12
    private let navButtonHeight: CGFloat = 44

    @FocusState private var isSearchFieldFocused: Bool

    @Namespace private var glassNamespace
    @Namespace private var searchMorphNamespace

    var body: some View {
        Group {
            if isSearchPresented {
                searchPill
            } else {
                HStack(spacing: clusterSpacing) {
                    navPill
                    searchButton
                }
            }
        }
        .animation(.snappy(duration: 0.22), value: isSearchPresented)
    }

    private var searchMorphBackground: some View {
        let shape = RoundedRectangle(cornerRadius: navButtonHeight / 2, style: .continuous)

        return Group {
            if #available(iOS 26.0, *) {
                shape
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
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
        .matchedGeometryEffect(id: "search.morph.background", in: searchMorphNamespace)
    }

    @ViewBuilder
    private func circleBackground() -> some View {
        if #available(iOS 26.0, *) {
            Circle()
                .fill(.ultraThinMaterial)
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay { Circle().stroke(theme.cardStroke, lineWidth: 1) }
                .shadow(
                    color: Color.black.opacity(theme.preferredColorScheme == .dark ? 0.22 : 0.08),
                    radius: theme.preferredColorScheme == .dark ? 14 : 10,
                    x: 0,
                    y: 6
                )
        }
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
        HStack(spacing: clusterSpacing) {
            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    isSearchPresented = false
                }
                searchQuery = ""
                isSearchFieldFocused = false
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.body.weight(.semibold))
                    .frame(width: navButtonHeight, height: navButtonHeight)
                    .background { circleBackground() }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            .contentShape(Rectangle())

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search", text: $searchQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($isSearchFieldFocused)

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                        isSearchFieldFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: navButtonHeight)
            .background { searchMorphBackground }
            .onAppear {
                DispatchQueue.main.async {
                    isSearchFieldFocused = true
                }
            }
        }
    }

    private var searchButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.22)) {
                isSearchPresented = true
            }
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .frame(width: navButtonHeight, height: navButtonHeight)
                .background { searchMorphBackground }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
        .contentShape(Rectangle())
    }

    private func pill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, pillInnerVerticalPadding)
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

private struct StartWorkoutBottomBar: View {
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .foregroundStyle(theme.accent)

                Text("Start Workout")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .background {
            if #available(iOS 26.0, *) {
                shape
                    .fill(.ultraThinMaterial)
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                shape
                    .fill(.regularMaterial)
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
