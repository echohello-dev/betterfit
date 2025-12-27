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
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
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
        Section("Categories") {
            ForEach(categories) { category in
                NavigationLink {
                    CategoryDetailView(category: category, theme: theme)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.systemImage)
                            .foregroundStyle(category.tint)
                            .frame(width: 22)

                        Text(category.title)
                            .bfHeading(theme: theme, size: 17, relativeTo: .headline)

                        Spacer(minLength: 0)
                    }
                }
                .listRowBackground(nativeRowBackground(cornerRadius: 14))
            }
        }
        .listSectionSeparator(.hidden)
    }

    private var resultsSection: some View {
        Section("Results") {
            let results = searchResults
            if results.isEmpty {
                Text("No matches")
                    .foregroundStyle(.secondary)
                    .listRowBackground(nativeRowBackground(cornerRadius: 14))
            } else {
                ForEach(results) { result in
                    resultRow(result)
                        .listRowBackground(nativeRowBackground(cornerRadius: 14))
                }
            }
        }
        .listSectionSeparator(.hidden)
    }

    @ViewBuilder
    private func resultRow(_ result: SearchResult) -> some View {
        switch result.kind {
        case .theme:
            Button {
                showingThemePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "paintpalette")
                        .foregroundStyle(theme.accent)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                            .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                        Text(AppTheme.fromStorage(storedTheme).displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

        #if DEBUG
            case .demoMode:
                Toggle(isOn: $workoutHomeDemoModeEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "testtube.2")
                            .foregroundStyle(theme.accent)
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Demo Mode")
                                .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                            Text("Seed demo data and demo-only UI")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
        #else
            case .demoMode:
                EmptyView()
        #endif

        case .exercise:
            NavigationLink {
                ExerciseDetailView(exercise: result.title, subtitle: result.subtitle, theme: theme)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(theme.accent)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }

        case .category:
            NavigationLink {
                CategoryDetailView(category: result.category, theme: theme)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: result.category.systemImage)
                        .foregroundStyle(result.category.tint)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.category.title)
                            .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                        Text("Category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func nativeRowBackground(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return
            shape
            .fill(.regularMaterial)
            .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
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
        @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
            .rawValue

        #if DEBUG
            @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled =
                false
        #endif

        var body: some View {
            List {
                ForEach(category.items) { item in
                    row(for: item)
                        .listRowBackground(nativeRowBackground(cornerRadius: 14))
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .listStyle(.insetGrouped)
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

        @ViewBuilder
        private func row(for item: CategoryItem) -> some View {
            switch item.id {
            case "theme":
                Button {
                    showingThemePicker = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.systemImage)
                            .foregroundStyle(theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                            Text(AppTheme.fromStorage(storedTheme).displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)

            case "demoMode":
                #if DEBUG
                    Toggle(isOn: $workoutHomeDemoModeEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: item.systemImage)
                                .foregroundStyle(theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                #else
                    EmptyView()
                #endif

            default:
                NavigationLink {
                    ExerciseDetailView(exercise: item.title, subtitle: item.subtitle, theme: theme)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.systemImage)
                            .foregroundStyle(theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }

        private func nativeRowBackground(cornerRadius: CGFloat) -> some View {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

            return
                shape
                .fill(.regularMaterial)
                .overlay { shape.stroke(theme.cardStroke, lineWidth: 1) }
        }
    }

    private struct ExerciseDetailView: View {
        let exercise: String
        let subtitle: String
        let theme: AppTheme

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                Text(exercise)
                    .bfHeading(theme: theme, size: 26, relativeTo: .title)

                Text(subtitle)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .toolbar(.visible, for: .navigationBar)
            .navigationTitle("Exercise")
            .navigationBarTitleDisplayMode(.inline)
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
