import BetterFit
import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var appState: WatchAppState

    // MARK: - View

    var body: some View {
        List {
            recommendedWorkoutSection
            allWorkoutsSection
        }
        .scrollContentBackground(.hidden)
        .background(WatchTheme.background.ignoresSafeArea())
        .navigationTitle("Workouts")
    }

    // MARK: - Suggested Workouts Section

    private var recommendedWorkoutSection: some View {
        Section {
            if let recommended = appState.betterFit.getRecommendedWorkout() {
                WorkoutRowButton(workout: recommended, isRecommended: true) {
                    appState.startWorkout(recommended)
                }
            }
        } header: {
            Text("Recommended")
                .font(.caption)
                .foregroundStyle(WatchTheme.textSecondary)
        }
    }

    // MARK: - Sections

    private var allWorkoutsSection: some View {
        Section {
            ForEach(availableWorkouts) { workout in
                WorkoutRowButton(workout: workout, isRecommended: false) {
                    appState.startWorkout(workout)
                }
            }
        } header: {
            Text("All Workouts")
                .font(.caption)
                .foregroundStyle(WatchTheme.textSecondary)
        }
    }

    // MARK: - Data

    /// Get workouts from templates stored in BetterFit
    private var availableWorkouts: [Workout] {
        appState.betterFit.templateManager.getAllTemplates().map { $0.createWorkout() }
    }
}

// MARK: - Supporting Views

struct WorkoutRowButton: View {
    let workout: Workout
    let isRecommended: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.name)
                        .font(.headline)
                        .foregroundStyle(WatchTheme.textPrimary)

                    if isRecommended {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(WatchTheme.accent)
                    }
                }

                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(WatchTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WatchTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(WatchTheme.border, lineWidth: 1)
                )
        )
    }
}
