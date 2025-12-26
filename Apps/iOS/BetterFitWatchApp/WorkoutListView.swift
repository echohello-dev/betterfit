import BetterFit
import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var appState: WatchAppState
    @State private var workouts: [Workout] = []

    var body: some View {
        List {
            Section {
                if let recommended = appState.betterFit.getRecommendedWorkout() {
                    WorkoutRowButton(workout: recommended, isRecommended: true) {
                        appState.startWorkout(recommended)
                    }
                }
            } header: {
                Text("Recommended")
                    .font(.caption)
            }

            Section {
                ForEach(sampleWorkouts()) { workout in
                    WorkoutRowButton(workout: workout, isRecommended: false) {
                        appState.startWorkout(workout)
                    }
                }
            } header: {
                Text("All Workouts")
                    .font(.caption)
            }
        }
        .navigationTitle("Workouts")
    }

    // Sample workouts for demonstration
    private func sampleWorkouts() -> [Workout] {
        [
            Workout(
                name: "Upper Body",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Bench Press",
                            equipmentRequired: .barbell,
                            muscleGroups: [.chest, .triceps]
                        ),
                        sets: [
                            ExerciseSet(reps: 10, weight: 135),
                            ExerciseSet(reps: 8, weight: 155),
                            ExerciseSet(reps: 6, weight: 175),
                        ]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Dumbbell Row",
                            equipmentRequired: .dumbbell,
                            muscleGroups: [.back, .biceps]
                        ),
                        sets: [
                            ExerciseSet(reps: 12, weight: 50),
                            ExerciseSet(reps: 10, weight: 55),
                            ExerciseSet(reps: 8, weight: 60),
                        ]
                    ),
                ]
            ),
            Workout(
                name: "Lower Body",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Squat",
                            equipmentRequired: .barbell,
                            muscleGroups: [.quads, .glutes]
                        ),
                        sets: [
                            ExerciseSet(reps: 10, weight: 185),
                            ExerciseSet(reps: 8, weight: 205),
                            ExerciseSet(reps: 6, weight: 225),
                        ]
                    ),
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Romanian Deadlift",
                            equipmentRequired: .barbell,
                            muscleGroups: [.hamstrings, .glutes]
                        ),
                        sets: [
                            ExerciseSet(reps: 12, weight: 135),
                            ExerciseSet(reps: 10, weight: 155),
                            ExerciseSet(reps: 8, weight: 175),
                        ]
                    ),
                ]
            ),
            Workout(
                name: "Full Body",
                exercises: [
                    WorkoutExercise(
                        exercise: Exercise(
                            name: "Deadlift",
                            equipmentRequired: .barbell,
                            muscleGroups: [.back, .hamstrings, .glutes]
                        ),
                        sets: [
                            ExerciseSet(reps: 8, weight: 225),
                            ExerciseSet(reps: 6, weight: 245),
                            ExerciseSet(reps: 4, weight: 265),
                        ]
                    )
                ]
            ),
        ]
    }
}

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
                        .foregroundStyle(.primary)

                    if isRecommended {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }

                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}
