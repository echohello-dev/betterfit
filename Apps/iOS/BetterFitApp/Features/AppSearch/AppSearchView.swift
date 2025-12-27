import BetterFit
import SwiftUI

struct AppSearchView: View {
    let theme: AppTheme
    let betterFit: BetterFit?
    let previousTabIcon: String
    let onDismiss: () -> Void

    @Binding var query: String

    @State private var showingThemePicker = false

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled = false
    #endif

    init(
        theme: AppTheme,
        betterFit: BetterFit?,
        query: Binding<String>,
        previousTabIcon: String = "figure.run",
        onDismiss: @escaping () -> Void = {}
    ) {
        self.theme = theme
        self.betterFit = betterFit
        self._query = query
        self.previousTabIcon = previousTabIcon
        self.onDismiss = onDismiss
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    categoriesSection
                } else {
                    resultsSection
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .searchable(text: $query, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: previousTabIcon)
                    }
                    .tint(theme.accent)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 120)
            }
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
    }

    // MARK: - Sections

    private var categoriesSection: some View {
        Section {
            ForEach(categories) { category in
                NavigationLink {
                    CategoryDetailView(category: category, theme: theme)
                } label: {
                    Label {
                        Text(category.title)
                    } icon: {
                        Image(systemName: category.systemImage)
                            .foregroundStyle(category.tint)
                    }
                }
            }
        } header: {
            Text("Categories")
        }
    }

    private var resultsSection: some View {
        Section {
            let results = searchResults
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(results) { result in
                    resultRow(result)
                }
            }
        } header: {
            Text("Results")
        }
    }

    @ViewBuilder
    private func resultRow(_ result: SearchResult) -> some View {
        switch result.kind {
        case .theme:
            Button {
                showingThemePicker = true
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                        Text(AppTheme.fromStorage(storedTheme).displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "paintpalette")
                        .foregroundStyle(theme.accent)
                }
            }
            .tint(.primary)

        #if DEBUG
            case .demoMode:
                Toggle(isOn: $workoutHomeDemoModeEnabled) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Demo Mode")
                            Text("Seed demo data and demo-only UI")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "testtube.2")
                            .foregroundStyle(theme.accent)
                    }
                }
                .tint(theme.accent)
        #else
            case .demoMode:
                EmptyView()
        #endif

        case .exercise:
            NavigationLink {
                ExerciseDetailView(exercise: result.title, subtitle: result.subtitle, theme: theme)
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(theme.accent)
                }
            }

        case .category:
            NavigationLink {
                CategoryDetailView(category: result.category, theme: theme)
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.category.title)
                        Text("Category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: result.category.systemImage)
                        .foregroundStyle(result.category.tint)
                }
            }
        }
    }

    // MARK: - Supporting Types

    private struct Category: Identifiable, Hashable {
        let id: String
        let title: String
        let systemImage: String
        let tint: Color
        let items: [CategoryItem]
    }

    private struct CategoryItem: Identifiable, Hashable {
        let id: String
        let title: String
        let subtitle: String
        let systemImage: String
    }

    private struct SearchResult: Identifiable, Hashable {
        enum Kind: Hashable {
            case theme
            case demoMode
            case category
            case exercise
        }

        let id: String
        let kind: Kind
        let title: String
        let subtitle: String
        let category: Category
    }

    private var categories: [Category] {
        var result: [Category] = []

        result.append(
            Category(
                id: "appearance",
                title: "Appearance",
                systemImage: "paintpalette",
                tint: theme.accent,
                items: [
                    CategoryItem(
                        id: "theme",
                        title: "Theme",
                        subtitle: AppTheme.fromStorage(storedTheme).displayName,
                        systemImage: "paintpalette"
                    )
                ]
            )
        )

        #if DEBUG
            result.append(
                Category(
                    id: "developer",
                    title: "Developer",
                    systemImage: "testtube.2",
                    tint: theme.accent,
                    items: [
                        CategoryItem(
                            id: "demoMode",
                            title: "Demo Mode",
                            subtitle: "Seed demo data and demo-only UI",
                            systemImage: "testtube.2"
                        )
                    ]
                )
            )
        #endif

        let exerciseItems = allExercises.map {
            CategoryItem(
                id: "exercise.\($0.name)",
                title: $0.name,
                subtitle: $0.subtitle,
                systemImage: "dumbbell"
            )
        }
        result.append(
            Category(
                id: "exercises",
                title: "Exercises",
                systemImage: "dumbbell",
                tint: theme.accent,
                items: exerciseItems
            )
        )

        if let betterFit, let workout = betterFit.getRecommendedWorkout() {
            result.append(
                Category(
                    id: "recommended",
                    title: "Recommended",
                    systemImage: "sparkles",
                    tint: theme.accent,
                    items: [
                        CategoryItem(
                            id: "recommendedWorkout",
                            title: workout.name,
                            subtitle: "Suggested workout",
                            systemImage: "sparkles"
                        )
                    ]
                )
            )
        }

        return result
    }

    private struct SearchExercise: Hashable {
        let name: String
        let subtitle: String
    }

    private var allExercises: [SearchExercise] {
        [
            SearchExercise(name: "Bench Press", subtitle: "Chest • Triceps"),
            SearchExercise(name: "Incline Dumbbell Press", subtitle: "Chest • Shoulders"),
            SearchExercise(name: "Squat", subtitle: "Legs • Core"),
            SearchExercise(name: "Romanian Deadlift", subtitle: "Hamstrings • Back"),
            SearchExercise(name: "Deadlift", subtitle: "Back • Legs"),
            SearchExercise(name: "Pull Up", subtitle: "Back • Arms"),
            SearchExercise(name: "Lat Pulldown", subtitle: "Back"),
            SearchExercise(name: "Overhead Press", subtitle: "Shoulders • Triceps"),
            SearchExercise(name: "Barbell Row", subtitle: "Back"),
            SearchExercise(name: "Bicep Curl", subtitle: "Arms"),
        ]
    }

    private var searchResults: [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let needle = trimmed.lowercased()

        var results: [SearchResult] = []

        // “Settings” style shortcuts
        if "theme".contains(needle)
            || AppTheme.fromStorage(storedTheme).displayName.lowercased().contains(needle)
        {
            let appearanceCategory = categories.first { $0.id == "appearance" } ?? categories[0]
            results.append(
                SearchResult(
                    id: "result.theme",
                    kind: .theme,
                    title: "Theme",
                    subtitle: AppTheme.fromStorage(storedTheme).displayName,
                    category: appearanceCategory
                )
            )
        }

        #if DEBUG
            if "demo mode".contains(needle) || "demo".contains(needle) {
                let devCategory = categories.first { $0.id == "developer" } ?? categories[0]
                results.append(
                    SearchResult(
                        id: "result.demoMode",
                        kind: .demoMode,
                        title: "Demo Mode",
                        subtitle: "Seed demo data and demo-only UI",
                        category: devCategory
                    )
                )
            }
        #endif

        // Categories
        for category in categories where category.title.lowercased().contains(needle) {
            results.append(
                SearchResult(
                    id: "result.category.\(category.id)",
                    kind: .category,
                    title: category.title,
                    subtitle: "Category",
                    category: category
                )
            )
        }

        // Exercises (kept for backwards compatibility with the old search)
        for ex in allExercises where ex.name.lowercased().contains(needle) {
            let exerciseCategory = categories.first { $0.id == "exercises" } ?? categories[0]
            results.append(
                SearchResult(
                    id: "result.exercise.\(ex.name)",
                    kind: .exercise,
                    title: ex.name,
                    subtitle: ex.subtitle,
                    category: exerciseCategory
                )
            )
        }

        return results
    }

    private struct CategoryDetailView: View {
        let category: Category
        let theme: AppTheme

        @State private var showingThemePicker = false
        @State private var searchText = ""
        @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
            .rawValue

        #if DEBUG
            @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled =
                false
        #endif

        private var filteredItems: [CategoryItem] {
            guard !searchText.isEmpty else { return category.items }
            return category.items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }

        var body: some View {
            List {
                // Category header
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: category.systemImage)
                            .font(.system(size: 44))
                            .foregroundStyle(category.tint)

                        Text(categoryDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Text("\(category.items.count) items")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                // Items
                Section {
                    if filteredItems.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredItems) { item in
                            row(for: item)
                        }
                    }
                } header: {
                    if category.items.count > 5 {
                        Text("All \(category.title)")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Filter \(category.title.lowercased())")
            .toolbar(.visible, for: .navigationBar)
            .navigationTitle(category.title)
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerView(
                    selectedTheme: Binding(
                        get: { AppTheme.fromStorage(storedTheme) },
                        set: { storedTheme = $0.rawValue }
                    )
                )
                .presentationDetents([.medium, .large])
            }
        }

        private var categoryDescription: String {
            switch category.id {
            case "appearance":
                return "Customize how BetterFit looks and feels"
            case "developer":
                return "Tools and options for testing and development"
            case "exercises":
                return "Browse all available exercises with instructions"
            case "recommended":
                return "Workouts suggested based on your goals and recovery"
            default:
                return "Explore \(category.title.lowercased())"
            }
        }

        @ViewBuilder
        private func row(for item: CategoryItem) -> some View {
            switch item.id {
            case "theme":
                Button {
                    showingThemePicker = true
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                            Text(AppTheme.fromStorage(storedTheme).displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.systemImage)
                            .foregroundStyle(theme.accent)
                    }
                }
                .tint(.primary)

            case "demoMode":
                #if DEBUG
                    Toggle(isOn: $workoutHomeDemoModeEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: item.systemImage)
                                .foregroundStyle(theme.accent)
                        }
                    }
                    .tint(theme.accent)
                #else
                    EmptyView()
                #endif

            default:
                NavigationLink {
                    ExerciseDetailView(exercise: item.title, subtitle: item.subtitle, theme: theme)
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.systemImage)
                            .foregroundStyle(theme.accent)
                    }
                }
            }
        }
    }

    private struct ExerciseDetailView: View {
        let exercise: String
        let subtitle: String
        let theme: AppTheme

        private var muscleGroups: [String] {
            subtitle.components(separatedBy: " • ")
        }

        private var exerciseInfo: ExerciseInfo {
            ExerciseInfo.data[exercise] ?? ExerciseInfo.placeholder
        }

        var body: some View {
            List {
                // Hero section
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 56))
                            .foregroundStyle(theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)

                        Text(exercise)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        // Muscle group pills
                        HStack(spacing: 8) {
                            ForEach(muscleGroups, id: \.self) { muscle in
                                Text(muscle)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(theme.accent.opacity(0.15), in: Capsule())
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                // Quick stats
                Section {
                    LabeledContent("Equipment", value: exerciseInfo.equipment)
                    LabeledContent("Difficulty", value: exerciseInfo.difficulty)
                    LabeledContent("Type", value: exerciseInfo.type)
                } header: {
                    Text("Overview")
                }

                // Instructions
                Section {
                    ForEach(Array(exerciseInfo.instructions.enumerated()), id: \.offset) {
                        index,
                        instruction in
                        Label {
                            Text(instruction)
                        } icon: {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(theme.accent, in: Circle())
                        }
                    }
                } header: {
                    Text("How to Perform")
                }

                // Tips
                Section {
                    ForEach(exerciseInfo.tips, id: \.self) { tip in
                        Label {
                            Text(tip)
                        } icon: {
                            Image(systemName: "lightbulb")
                                .foregroundStyle(.yellow)
                        }
                    }
                } header: {
                    Text("Tips")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .toolbar(.visible, for: .navigationBar)
            .navigationTitle(exercise)
            .navigationBarTitleDisplayMode(.inline)
        }

        private struct ExerciseInfo {
            let equipment: String
            let difficulty: String
            let type: String
            let instructions: [String]
            let tips: [String]

            static let placeholder = ExerciseInfo(
                equipment: "Varies",
                difficulty: "Intermediate",
                type: "Strength",
                instructions: [
                    "Set up with proper form",
                    "Perform the movement with control",
                    "Return to starting position",
                ],
                tips: [
                    "Focus on mind-muscle connection",
                    "Control the eccentric phase",
                ]
            )

            static let data: [String: ExerciseInfo] = [
                "Bench Press": ExerciseInfo(
                    equipment: "Barbell, Bench",
                    difficulty: "Intermediate",
                    type: "Compound",
                    instructions: [
                        "Lie flat on the bench with feet firmly on the ground",
                        "Grip the bar slightly wider than shoulder width",
                        "Unrack the bar and lower it to your mid-chest",
                        "Press the bar back up to the starting position",
                    ],
                    tips: [
                        "Keep your shoulder blades retracted",
                        "Maintain a slight arch in your lower back",
                        "Don't bounce the bar off your chest",
                    ]
                ),
                "Squat": ExerciseInfo(
                    equipment: "Barbell, Squat Rack",
                    difficulty: "Intermediate",
                    type: "Compound",
                    instructions: [
                        "Position the bar on your upper back",
                        "Stand with feet shoulder-width apart",
                        "Descend by breaking at hips and knees",
                        "Go down until thighs are parallel to floor",
                        "Drive through your heels to stand back up",
                    ],
                    tips: [
                        "Keep your chest up throughout the movement",
                        "Track your knees over your toes",
                        "Brace your core before each rep",
                    ]
                ),
                "Deadlift": ExerciseInfo(
                    equipment: "Barbell",
                    difficulty: "Advanced",
                    type: "Compound",
                    instructions: [
                        "Stand with feet hip-width apart, bar over mid-foot",
                        "Hinge at hips and grip the bar",
                        "Flatten your back and brace your core",
                        "Drive through your legs and pull the bar up",
                        "Lock out at the top with hips fully extended",
                    ],
                    tips: [
                        "Keep the bar close to your body",
                        "Don't round your lower back",
                        "Think of pushing the floor away",
                    ]
                ),
                "Pull Up": ExerciseInfo(
                    equipment: "Pull-up Bar",
                    difficulty: "Intermediate",
                    type: "Compound",
                    instructions: [
                        "Hang from the bar with arms fully extended",
                        "Pull yourself up until chin clears the bar",
                        "Lower yourself with control",
                    ],
                    tips: [
                        "Initiate the pull with your lats, not arms",
                        "Avoid swinging or kipping",
                        "Use a band for assistance if needed",
                    ]
                ),
                "Overhead Press": ExerciseInfo(
                    equipment: "Barbell or Dumbbells",
                    difficulty: "Intermediate",
                    type: "Compound",
                    instructions: [
                        "Start with the bar at shoulder height",
                        "Brace your core and squeeze your glutes",
                        "Press the bar straight overhead",
                        "Lower the bar back to shoulders with control",
                    ],
                    tips: [
                        "Keep your elbows slightly in front of the bar",
                        "Don't lean back excessively",
                        "Move your head back slightly as the bar passes",
                    ]
                ),
                "Bicep Curl": ExerciseInfo(
                    equipment: "Dumbbells or Barbell",
                    difficulty: "Beginner",
                    type: "Isolation",
                    instructions: [
                        "Stand with weights at your sides, palms forward",
                        "Curl the weights up toward your shoulders",
                        "Squeeze at the top of the movement",
                        "Lower with control to the starting position",
                    ],
                    tips: [
                        "Keep your elbows pinned to your sides",
                        "Don't swing the weights",
                        "Focus on the squeeze at the top",
                    ]
                ),
            ]
        }
    }

    private struct PreviewWrapper: View {
        @State private var query: String = ""

        var body: some View {
            AppSearchView(
                theme: .midnight,
                betterFit: BetterFit(),
                query: $query,
                previousTabIcon: "figure.run",
                onDismiss: {}
            )
        }
    }
}
