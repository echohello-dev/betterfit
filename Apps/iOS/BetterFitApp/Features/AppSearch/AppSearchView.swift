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

    // MARK: - Data

    private var categories: [SearchCategory] {
        var result: [SearchCategory] = []

        result.append(
            SearchCategory(
                id: "appearance",
                title: "Appearance",
                systemImage: "paintpalette",
                tint: theme.accent,
                items: [
                    SearchCategoryItem(
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
                SearchCategory(
                    id: "developer",
                    title: "Developer",
                    systemImage: "testtube.2",
                    tint: theme.accent,
                    items: [
                        SearchCategoryItem(
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
            SearchCategoryItem(
                id: "exercise.\($0.name)",
                title: $0.name,
                subtitle: $0.subtitle,
                systemImage: "dumbbell"
            )
        }
        result.append(
            SearchCategory(
                id: "exercises",
                title: "Exercises",
                systemImage: "dumbbell",
                tint: theme.accent,
                items: exerciseItems
            )
        )

        if let betterFit, let workout = betterFit.getRecommendedWorkout() {
            result.append(
                SearchCategory(
                    id: "recommended",
                    title: "Recommended",
                    systemImage: "sparkles",
                    tint: theme.accent,
                    items: [
                        SearchCategoryItem(
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

        // "Settings" style shortcuts
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

        // Exercises
        for exercise in allExercises where exercise.name.lowercased().contains(needle) {
            let exerciseCategory = categories.first { $0.id == "exercises" } ?? categories[0]
            results.append(
                SearchResult(
                    id: "result.exercise.\(exercise.name)",
                    kind: .exercise,
                    title: exercise.name,
                    subtitle: exercise.subtitle,
                    category: exerciseCategory
                )
            )
        }

        return results
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
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

    return PreviewWrapper()
}
