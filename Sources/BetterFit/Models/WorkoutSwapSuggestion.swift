import Foundation

/// Catalogue alternatives for one entry in a workout.
/// Use `workoutExerciseId` with `applySwap(workout:workoutExerciseId:newExercise:)`.
public struct WorkoutSwapSuggestion: Equatable {
    public let workoutExerciseId: UUID
    public let original: Exercise
    public let alternatives: [Exercise]

    public init(workoutExerciseId: UUID, original: Exercise, alternatives: [Exercise]) {
        self.workoutExerciseId = workoutExerciseId
        self.original = original
        self.alternatives = alternatives
    }
}
