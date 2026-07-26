import BetterFit
import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    let category: SearchCategory
    let theme: AppTheme

    @State private var showingThemePicker = false
    @State private var searchText = ""
    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue
    @AppStorage(AppearancePreference.storageKey) private var storedAppearance: String =
        AppearancePreference.defaultPreference.rawValue

    #if DEBUG
        @AppStorage("betterfit.workoutHome.demoMode") private var workoutHomeDemoModeEnabled = false
    #endif

    private var filteredItems: [SearchCategoryItem] {
        guard !searchText.isEmpty else { return category.items }
        return category.items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            headerSection
            itemsSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .bfPageBackground()
        .searchable(text: $searchText, prompt: "Filter \(category.title.lowercased())")
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle(category.title)
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

    private var headerSection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(category.tint)

                Text(categoryDescription)
                    .font(.subheadline)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("\(category.items.count) items")
                    .font(.caption)
                    .foregroundStyle(BFColors.textTertiary(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    private var itemsSection: some View {
        Section {
            if filteredItems.isEmpty {
                BFEmptyState(
                    systemImage: "magnifyingglass",
                    title: "No Results",
                    message: "Nothing matched \"\(searchText)\". Try a different search."
                )
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

    // MARK: - Helpers

    private var categoryDescription: String {
        switch category.id {
        case "settings":
            return "App preferences and configuration"
        case "account":
            return "Manage your profile and account settings"
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
    private func row(for item: SearchCategoryItem) -> some View {
        switch item.id {
        case "theme":
            Button {
                showingThemePicker = true
            } label: {
                BFListRow(
                    systemImage: item.systemImage,
                    title: item.title,
                    subtitle: AppTheme.fromStorage(storedTheme).displayName,
                    iconTint: theme.accent
                )
            }
            .tint(.primary)
            .listRowBackground(BFColors.surface(for: colorScheme))

        case "demoMode":
            #if DEBUG
                Toggle(isOn: $workoutHomeDemoModeEnabled) {
                    BFListRow(
                        systemImage: item.systemImage,
                        title: item.title,
                        subtitle: item.subtitle,
                        iconTint: .purple
                    )
                }
                .tint(theme.accent)
                .listRowBackground(BFColors.surface(for: colorScheme))
            #else
                EmptyView()
            #endif

        case "notifications", "health", "units", "editProfile", "privacy", "terms":
            NavigationLink {
                SettingDetailView(settingId: item.id, title: item.title, theme: theme)
            } label: {
                BFListRow(
                    systemImage: item.systemImage,
                    title: item.title,
                    subtitle: item.subtitle,
                    iconTint: colorForSettingItem(item.id)
                )
            }
            .listRowBackground(BFColors.surface(for: colorScheme))

        default:
            NavigationLink {
                ExerciseDetailView(exercise: item.title, subtitle: item.subtitle, theme: theme)
            } label: {
                BFListRow(
                    systemImage: item.systemImage,
                    title: item.title,
                    subtitle: item.subtitle,
                    iconTint: theme.accent
                )
            }
            .listRowBackground(BFColors.surface(for: colorScheme))
        }
    }

    private func colorForSettingItem(_ id: String) -> Color {
        switch id {
        case "notifications": return theme.accent
        case "health": return .red
        case "units": return theme.accent
        case "editProfile": return theme.accent
        case "privacy": return .blue
        case "terms": return .gray
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(
            category: SearchCategory(
                id: "exercises",
                title: "Exercises",
                systemImage: "dumbbell",
                tint: .yellow,
                items: [
                    SearchCategoryItem(
                        id: "exercise.bench",
                        title: "Bench Press",
                        subtitle: "Chest • Triceps",
                        systemImage: "dumbbell"
                    ),
                    SearchCategoryItem(
                        id: "exercise.squat",
                        title: "Squat",
                        subtitle: "Legs • Core",
                        systemImage: "dumbbell"
                    ),
                ]
            ),
            theme: .bold
        )
    }
}
