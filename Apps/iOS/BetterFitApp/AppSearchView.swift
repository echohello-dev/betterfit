import BetterFit
import SwiftUI

struct AppSearchView: View {
    let theme: AppTheme
    let betterFit: BetterFit?

    @Environment(\.dismiss) private var dismiss

    @State private var query: String = ""

    // MARK: - View

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    suggestionsSection
                    recommendedWorkoutSection
                }

                exercisesSection
            }
            .scrollContentBackground(.hidden)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .listStyle(.insetGrouped)
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        // Best practice: use the system search UI. On newer OS versions this automatically adopts the latest visual style.
        .searchable(
            text: $query, placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search exercises"
        )
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.words)
    }

    // MARK: - Suggested Workouts Section

    private var recommendedWorkoutSection: some View {
        Group {
            if let betterFit, let workout = betterFit.getRecommendedWorkout() {
                Section("Recommended") {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(workout.name)
                                .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                            Text("Suggested workout")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .listRowBackground(
                        LiquidGlassBackground(theme: theme, cornerRadius: 14))
                }
                .listSectionSeparator(.hidden)
            }
        }
    }

    // MARK: - Sections

    private var suggestionsSection: some View {
        Section("Suggestions") {
            ForEach(suggestions, id: \.self) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.systemImage)
                        .foregroundStyle(theme.accent)
                    Text(item.title)
                        .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                    Spacer(minLength: 0)
                }
                .listRowBackground(
                    LiquidGlassBackground(theme: theme, cornerRadius: 14))
            }
        }
        .listSectionSeparator(.hidden)
    }

    private var exercisesSection: some View {
        Section("Exercises") {
            let results = exerciseResults
            if results.isEmpty {
                Text("No matches")
                    .foregroundStyle(.secondary)
                    .listRowBackground(
                        LiquidGlassBackground(theme: theme, cornerRadius: 14))
            } else {
                ForEach(results, id: \.name) { exercise in
                    HStack(spacing: 12) {
                        Image(systemName: "dumbbell")
                            .foregroundStyle(theme.accent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .bfHeading(theme: theme, size: 17, relativeTo: .headline)
                            Text(exercise.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }
                    .listRowBackground(
                        LiquidGlassBackground(theme: theme, cornerRadius: 14))
                }
            }
        }
        .listSectionSeparator(.hidden)
    }

    // MARK: - Supporting Types

    private struct Suggestion: Hashable {
        let title: String
        let systemImage: String
    }

    private var suggestions: [Suggestion] {
        [
            Suggestion(title: "Bench Press", systemImage: "dumbbell"),
            Suggestion(title: "Squat", systemImage: "dumbbell"),
            Suggestion(title: "Deadlift", systemImage: "dumbbell"),
            Suggestion(title: "Pull Up", systemImage: "figure.strengthtraining.traditional"),
        ]
    }

    private struct SearchExercise {
        let name: String
        let subtitle: String
    }

    // MARK: - Data

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

    private var exerciseResults: [SearchExercise] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return allExercises
        }

        return
            allExercises
            .filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
}

#Preview {
    AppSearchView(theme: .midnight, betterFit: BetterFit())
}
