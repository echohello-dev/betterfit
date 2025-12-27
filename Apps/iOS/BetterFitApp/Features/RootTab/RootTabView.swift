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

    private let navPillCoordinateSpace = "floatingNavBar.navPill"

    @FocusState private var isSearchFieldFocused: Bool

    @State private var tabButtonFrames: [Int: CGRect] = [:]
    @State private var navDragLocationX: CGFloat? = nil
    @State private var isHoldingNavPill = false

    @GestureState private var isSearchPressed = false

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
                navPill_iOS26
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
                .frame(width: 58, height: 58)
                .background { searchMorphBackground(isPressed: isSearchPressed) }
                .scaleEffect(isSearchPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
        .contentShape(Circle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isSearchPressed) { _, pressed, _ in
                    pressed = true
                }
        )
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

    private func searchMorphBackground(isPressed: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: navButtonHeight / 2, style: .continuous)

        return Group {
            if #available(iOS 26.0, *) {
                shape
                    .fill(.ultraThinMaterial)
                    .glassEffect(
                        isPressed ? .clear.interactive() : .regular.interactive(), in: shape)
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
        .animation(.snappy(duration: 0.18), value: isPressed)
    }

    private var searchMorphBackground: some View {
        searchMorphBackground(isPressed: false)
    }

    private func nearestTabIndex(for locationX: CGFloat) -> Int {
        let candidates =
            tabButtonFrames
            .filter { (index, _) in (0...2).contains(index) }
            .map { (index: $0.key, frame: $0.value) }
        guard !candidates.isEmpty else {
            return min(max(selectedTab, 0), 2)
        }

        let nearest = candidates.min { lhs, rhs in
            abs(lhs.frame.midX - locationX) < abs(rhs.frame.midX - locationX)
        }

        return nearest?.index ?? min(max(selectedTab, 0), 2)
    }

    private func highlightFrame(for index: Int, dragLocationX: CGFloat?) -> CGRect? {
        guard var base = tabButtonFrames[index] else { return nil }
        guard let dragLocationX else { return base }

        let minX = tabButtonFrames.values.map(\.minX).min() ?? base.minX
        let maxX = tabButtonFrames.values.map(\.maxX).max() ?? base.maxX

        let halfWidth = base.width / 2
        let clampedCenterX = min(max(dragLocationX, minX + halfWidth), maxX - halfWidth)
        base.origin.x = clampedCenterX - halfWidth
        return base
    }

    @available(iOS 26.0, *)
    private var navPill_iOS26: some View {
        GlassEffectContainer(spacing: 12) {
            ZStack(alignment: .topLeading) {
                if (0...2).contains(selectedTab),
                    let frame = highlightFrame(for: selectedTab, dragLocationX: navDragLocationX)
                {
                    let shape = Capsule()

                    shape
                        .fill(.ultraThinMaterial)
                        .glassEffect(
                            isHoldingNavPill ? .clear.interactive() : .regular.interactive(),
                            in: shape
                        )
                        .overlay {
                            if isHoldingNavPill {
                                shape.stroke(.white.opacity(0.18), lineWidth: 1)
                            }
                        }
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                        .scaleEffect(isHoldingNavPill ? 1.02 : 1.0)
                        .animation(.snappy(duration: 0.18), value: isHoldingNavPill)
                        .animation(.snappy(duration: 0.18), value: selectedTab)
                        .allowsHitTesting(false)
                }

                HStack(spacing: 12) {
                    NavButton(
                        icon: "figure.run",
                        isSelected: selectedTab == 0,
                        theme: theme
                    ) {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedTab = 0
                        }
                    }
                    .glassEffectID("tab.workout", in: glassNamespace)
                    .anchorFramePreference(index: 0, in: navPillCoordinateSpace)

                    NavButton(
                        icon: "waveform",
                        label: "Plan",
                        isSelected: selectedTab == 1,
                        theme: theme
                    ) {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedTab = 1
                        }
                    }
                    .glassEffectID("tab.plan", in: glassNamespace)
                    .anchorFramePreference(index: 1, in: navPillCoordinateSpace)

                    NavButton(
                        icon: "clock",
                        isSelected: selectedTab == 2,
                        theme: theme
                    ) {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedTab = 2
                        }
                    }
                    .glassEffectID("tab.recovery", in: glassNamespace)
                    .anchorFramePreference(index: 2, in: navPillCoordinateSpace)
                }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .coordinateSpace(name: navPillCoordinateSpace)
        .onPreferenceChange(TabButtonFramePreferenceKey.self) { tabButtonFrames = $0 }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(navPillCoordinateSpace))
                .onChanged { value in
                    navDragLocationX = value.location.x
                    let newIndex = nearestTabIndex(for: value.location.x)
                    if newIndex != selectedTab {
                        withAnimation(.snappy(duration: 0.14)) {
                            selectedTab = newIndex
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy(duration: 0.22)) {
                        navDragLocationX = nil
                        isHoldingNavPill = false
                    }
                }
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.12)
                .onChanged { _ in
                    withAnimation(.snappy(duration: 0.14)) {
                        isHoldingNavPill = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy(duration: 0.18)) {
                        isHoldingNavPill = false
                    }
                }
        )
    }
}

private struct TabButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    fileprivate func anchorFramePreference(index: Int, in coordinateSpace: String) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: TabButtonFramePreferenceKey.self,
                        value: [index: proxy.frame(in: .named(coordinateSpace))]
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
            HStack(spacing: 16) {
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
                    if #available(iOS 26.0, *) {
                        EmptyView()
                    } else {
                        Capsule()
                            .fill(theme.accent.opacity(0.15))
                    }
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
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
