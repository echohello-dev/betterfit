import BetterFit
import SwiftUI

struct AppSearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    let theme: AppTheme
    let betterFit: BetterFit?
    let previousTabIcon: String
    let onDismiss: () -> Void

    @Binding var query: String

    @State private var showingThemePicker = false

    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

    @AppStorage(AppearancePreference.storageKey) private var storedAppearance: String =
        AppearancePreference.defaultPreference.rawValue

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
            .bfPageBackground()
            .searchable(text: $query, prompt: "Search")
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView(
                selectedTheme: Binding(
                    get: { AppTheme.fromStorage(storedTheme) },
                    set: { storedTheme = $0.rawValue }
                ),
                appearance: Binding(
                    get: { AppearancePreference.fromStorage(storedAppearance) },
                    set: { storedAppearance = $0.rawValue }
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
                    BFListRow(
                        systemImage: category.systemImage,
                        title: category.title,
                        iconTint: category.tint
                    )
                }
                .listRowBackground(BFColors.surface(for: colorScheme))
            }
        } header: {
            Text("Categories")
        }
    }

    private var resultsSection: some View {
        Section {
            let results = searchResults
            if results.isEmpty {
                BFEmptyState(
                    systemImage: "magnifyingglass",
                    title: "No Results",
                    message: "Nothing matched \"\(query)\". Try a different search."
                )
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
                BFListRow(
                    systemImage: "paintpalette.fill",
                    title: "Theme",
                    subtitle: AppTheme.fromStorage(storedTheme).displayName,
                    iconTint: theme.accent
                )
            }
            .tint(.primary)
            .listRowBackground(BFColors.surface(for: colorScheme))

        #if DEBUG
            case .demoMode:
                Toggle(isOn: $workoutHomeDemoModeEnabled) {
                    BFListRow(
                        systemImage: "testtube.2",
                        title: "Demo Mode",
                        subtitle: "Seed demo data and demo-only UI",
                        iconTint: .purple
                    )
                }
                .tint(theme.accent)
                .listRowBackground(BFColors.surface(for: colorScheme))
        #else
            case .demoMode:
                EmptyView()
        #endif

        case .setting:
            NavigationLink {
                SettingDetailView(settingId: result.id, title: result.title, theme: theme)
            } label: {
                BFListRow(
                    systemImage: iconForSetting(result.id),
                    title: result.title,
                    subtitle: result.subtitle,
                    iconTint: colorForSetting(result.id)
                )
            }
            .listRowBackground(BFColors.surface(for: colorScheme))

        case .exercise:
            NavigationLink {
                ExerciseDetailView(exercise: result.title, subtitle: result.subtitle, theme: theme)
            } label: {
                BFListRow(
                    systemImage: "dumbbell",
                    title: result.title,
                    subtitle: result.subtitle,
                    iconTint: theme.accent
                )
            }
            .listRowBackground(BFColors.surface(for: colorScheme))

        case .category:
            NavigationLink {
                CategoryDetailView(category: result.category, theme: theme)
            } label: {
                BFListRow(
                    systemImage: result.category.systemImage,
                    title: result.category.title,
                    subtitle: "Category",
                    iconTint: result.category.tint
                )
            }
            .listRowBackground(BFColors.surface(for: colorScheme))
        }
    }

    private func iconForSetting(_ id: String) -> String {
        switch id {
        case "result.notifications": return "bell.fill"
        case "result.health": return "heart.fill"
        case "result.units": return "ruler.fill"
        case "result.editProfile": return "person.fill"
        case "result.privacy": return "hand.raised.fill"
        case "result.terms": return "doc.text.fill"
        default: return "gearshape.fill"
        }
    }

    private func colorForSetting(_ id: String) -> Color {
        switch id {
        case "result.notifications": return theme.accent
        case "result.health": return .red
        case "result.units": return theme.accent
        case "result.editProfile": return theme.accent
        case "result.privacy": return .blue
        case "result.terms": return .gray
        default: return .gray
        }
    }

    // MARK: - Data

    private var categories: [SearchCategory] {
        var result: [SearchCategory] = []

        // Settings category (consolidated from Profile settings)
        result.append(
            SearchCategory(
                id: "settings",
                title: "Settings",
                systemImage: "gearshape",
                tint: .gray,
                items: [
                    SearchCategoryItem(
                        id: "theme",
                        title: "Theme",
                        subtitle: AppTheme.fromStorage(storedTheme).displayName,
                        systemImage: "paintpalette.fill"
                    ),
                    SearchCategoryItem(
                        id: "notifications",
                        title: "Notifications",
                        subtitle: "Reminders and alerts",
                        systemImage: "bell.fill"
                    ),
                    SearchCategoryItem(
                        id: "health",
                        title: "Apple Health",
                        subtitle: "Sync workouts and data",
                        systemImage: "heart.fill"
                    ),
                    SearchCategoryItem(
                        id: "units",
                        title: "Units",
                        subtitle: "Imperial or metric",
                        systemImage: "ruler.fill"
                    ),
                ]
            )
        )

        // Account category
        result.append(
            SearchCategory(
                id: "account",
                title: "Account",
                systemImage: "person.crop.circle",
                tint: .blue,
                items: [
                    SearchCategoryItem(
                        id: "editProfile",
                        title: "Edit Profile",
                        subtitle: "Update your information",
                        systemImage: "person.fill"
                    ),
                    SearchCategoryItem(
                        id: "privacy",
                        title: "Privacy Policy",
                        subtitle: "How we protect your data",
                        systemImage: "hand.raised.fill"
                    ),
                    SearchCategoryItem(
                        id: "terms",
                        title: "Terms of Service",
                        subtitle: "Usage terms and conditions",
                        systemImage: "doc.text.fill"
                    ),
                ]
            )
        )

        #if DEBUG
            result.append(
                SearchCategory(
                    id: "developer",
                    title: "Developer",
                    systemImage: "testtube.2",
                    tint: .purple,
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

        let exerciseItems = ExerciseTemplate.allTemplates.map {
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

        let categoryOrder = ["exercises", "recommended", "settings", "account", "developer"]
        return result.sorted {
            (categoryOrder.firstIndex(of: $0.id) ?? categoryOrder.count)
                < (categoryOrder.firstIndex(of: $1.id) ?? categoryOrder.count)
        }
    }

    private var searchResults: [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let needle = trimmed.lowercased()

        var results: [SearchResult] = []

        // Settings items
        let settingsCategory = categories.first { $0.id == "settings" } ?? categories[0]
        let accountCategory = categories.first { $0.id == "account" } ?? categories[0]

        if "theme".contains(needle) || "appearance".contains(needle)
            || AppTheme.fromStorage(storedTheme).displayName.lowercased().contains(needle)
        {
            results.append(
                SearchResult(
                    id: "result.theme",
                    kind: .theme,
                    title: "Theme",
                    subtitle: AppTheme.fromStorage(storedTheme).displayName,
                    category: settingsCategory
                )
            )
        }

        if "notifications".contains(needle) || "reminders".contains(needle)
            || "alerts".contains(needle)
        {
            results.append(
                SearchResult(
                    id: "result.notifications",
                    kind: .setting,
                    title: "Notifications",
                    subtitle: "Reminders and alerts",
                    category: settingsCategory
                )
            )
        }

        if "health".contains(needle) || "apple health".contains(needle)
            || "sync".contains(needle)
        {
            results.append(
                SearchResult(
                    id: "result.health",
                    kind: .setting,
                    title: "Apple Health",
                    subtitle: "Sync workouts and data",
                    category: settingsCategory
                )
            )
        }

        if "units".contains(needle) || "imperial".contains(needle) || "metric".contains(needle) {
            results.append(
                SearchResult(
                    id: "result.units",
                    kind: .setting,
                    title: "Units",
                    subtitle: "Imperial or metric",
                    category: settingsCategory
                )
            )
        }

        if "profile".contains(needle) || "edit profile".contains(needle) {
            results.append(
                SearchResult(
                    id: "result.editProfile",
                    kind: .setting,
                    title: "Edit Profile",
                    subtitle: "Update your information",
                    category: accountCategory
                )
            )
        }

        if "privacy".contains(needle) {
            results.append(
                SearchResult(
                    id: "result.privacy",
                    kind: .setting,
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    category: accountCategory
                )
            )
        }

        if "terms".contains(needle) || "service".contains(needle) {
            results.append(
                SearchResult(
                    id: "result.terms",
                    kind: .setting,
                    title: "Terms of Service",
                    subtitle: "Usage terms and conditions",
                    category: accountCategory
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
        for exercise in ExerciseTemplate.allTemplates
        where exercise.name.lowercased().contains(needle) {
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
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")

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
