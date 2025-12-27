import SwiftUI

struct CategoryDetailView: View {
    let category: SearchCategory
    let theme: AppTheme

    @State private var showingThemePicker = false
    @State private var searchText = ""
    @AppStorage(AppTheme.storageKey) private var storedTheme: String = AppTheme.defaultTheme
        .rawValue

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

    // MARK: - Sections

    private var headerSection: some View {
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
    }

    private var itemsSection: some View {
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

    // MARK: - Helpers

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
    private func row(for item: SearchCategoryItem) -> some View {
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
