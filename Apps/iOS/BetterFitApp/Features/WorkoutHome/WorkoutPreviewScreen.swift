import BetterFit
import SwiftUI

// MARK: - Workout Preview
//
// Detail screen for a single suggested/frequent workout — lists its exercises
// and lets the user adopt or start it.

struct WorkoutPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let theme: AppTheme
    let workout: WorkoutPreview

    var onAdopt: () -> Void
    var onStart: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    BFSectionRule(label: "The work", trailing: "\(workout.exercises.count) exercises")

                    ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                        BFLedgerRow(
                            gutter: String(format: "%02d", index + 1),
                            systemImage: "dumbbell.fill",
                            title: exercise.name,
                            meta: meta(for: exercise),
                            accentEdge: index == 0
                        ) {
                            Text("\(exercise.sets)×\(exercise.repsValue)")
                                .font(BFTypography.subheadlineEmphasis)
                                .monospacedDigit()
                        }
                    }

                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, BFSpacing.pageHorizontal)
            }
            .background(BFColors.background(for: colorScheme))
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Adopt") {
                        onAdopt()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    onStart()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("Start workout")
                            .font(BFTypography.headline)
                    }
                    .foregroundStyle(BFColors.accentInk)
                    .frame(maxWidth: .infinity)
                    .frame(height: BFControlSize.buttonLarge)
                    .background(Capsule(style: .continuous).fill(BFColors.accent))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BFColors.background(for: colorScheme))
            }
        }
    }

    private var header: some View {
        let total = max(workout.exercises.count, 1)
        let muscles = Set(workout.exercises.flatMap(\.muscleGroups)).count
        return BFHeaderBlock(
            eyebrow: "Suggested workout",
            title: workout.name,
            specs: [
                BFSpecItem(value: "\(total)", label: "Exercises"),
                BFSpecItem(value: "\(workout.duration)'", label: "Planned"),
                BFSpecItem(value: "\(max(muscles, 1))", label: "Muscles"),
            ],
            yellow: theme.prefersYellowHeaders
        )
    }

    private func meta(for exercise: PlannedExercise) -> String {
        var parts: [String] = []
        parts.append("\(exercise.sets) sets × \(exercise.repsValue)")
        if let first = exercise.muscleGroups.first {
            parts.append(first.capitalized)
        }
        if let targetWeight = exercise.targetWeight, !targetWeight.isEmpty {
            parts.append(targetWeight)
        }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Lightweight preview model
//
// Mirrors the data needed to render a workout card before the user adopts it.
// Built from the demo workouts + history.

struct WorkoutPreview: Identifiable {
    var id: String { name }
    let name: String
    let duration: Int
    let exercises: [PlannedExercise]
}

// MARK: - Builders

enum WorkoutPreviewLibrary {

    /// Suggested preview derived from the active Plan + Suggested/Frequent lists.
    static func previews(planExercises: [PlannedExercise]) -> [WorkoutPreview] {
        var out: [WorkoutPreview] = []
        if !planExercises.isEmpty {
            out.append(
                WorkoutPreview(
                    name: "Pull Day",
                    duration: 42,
                    exercises: planExercises
                )
            )
        }
        for preview in sampleWorkouts where !out.contains(where: { $0.name == preview.name }) {
            out.append(preview)
        }
        return out
    }

    /// Default sample workouts used by Suggested / Frequent lists.
    static let sampleWorkouts: [WorkoutPreview] = [
        WorkoutPreview(
            name: "Push A",
            duration: 48,
            exercises: [
                PlannedExercise(name: "Bench press", category: .push, sets: 4, reps: "6", targetWeight: "70 kg", muscleGroups: ["Chest"]),
                PlannedExercise(name: "Overhead press", category: .push, sets: 3, reps: "8", targetWeight: "40 kg", muscleGroups: ["Shoulders"]),
                PlannedExercise(name: "Incline dumbbell press", category: .push, sets: 3, reps: "10", targetWeight: "28 kg", muscleGroups: ["Chest"]),
                PlannedExercise(name: "Lateral raise", category: .push, sets: 3, reps: "12", targetWeight: "12 kg", muscleGroups: ["Shoulders"]),
                PlannedExercise(name: "Tricep pushdown", category: .push, sets: 3, reps: "12", targetWeight: "25 kg", muscleGroups: ["Triceps"]),
            ]
        ),
        WorkoutPreview(
            name: "Legs A",
            duration: 52,
            exercises: [
                PlannedExercise(name: "Back squat", category: .legs, sets: 4, reps: "5", targetWeight: "100 kg", muscleGroups: ["Quads"]),
                PlannedExercise(name: "Romanian deadlift", category: .legs, sets: 3, reps: "8", targetWeight: "80 kg", muscleGroups: ["Hamstrings"]),
                PlannedExercise(name: "Leg press", category: .legs, sets: 3, reps: "10", targetWeight: "160 kg", muscleGroups: ["Quads"]),
                PlannedExercise(name: "Walking lunge", category: .legs, sets: 3, reps: "12", targetWeight: "20 kg", muscleGroups: ["Glutes"]),
                PlannedExercise(name: "Calf raise", category: .legs, sets: 4, reps: "15", targetWeight: "60 kg", muscleGroups: ["Calves"]),
            ]
        ),
        WorkoutPreview(
            name: "Conditioning",
            duration: 28,
            exercises: [
                PlannedExercise(name: "Treadmill intervals", category: .cardio, sets: 8, reps: "1", targetWeight: nil, muscleGroups: ["Cardio"]),
                PlannedExercise(name: "Row erg", category: .cardio, sets: 4, reps: "500m", targetWeight: nil, muscleGroups: ["Cardio"]),
                PlannedExercise(name: "Core circuit", category: .compound, sets: 3, reps: "12", targetWeight: nil, muscleGroups: ["Core"]),
            ]
        ),
    ]
}