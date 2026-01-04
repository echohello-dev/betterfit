import BetterFit
import Foundation

// MARK: - Exercise Display Protocol

/// Protocol for exercises that can be displayed in timeline cards
protocol ExerciseDisplayable: Identifiable {
    var id: UUID { get }
    var displayName: String { get }
    var displayCategory: ExerciseCategory { get }
    var displaySetsInfo: String { get }
    var displayWeight: String? { get }
    var displayMuscleGroups: [String] { get }
    var isCompleted: Bool { get }
}

// MARK: - Workout Exercise State

/// State for tracking an exercise during an active workout
struct WorkoutExerciseState: Identifiable, Equatable, ExerciseDisplayable {
    let id: UUID
    let exercise: ExerciseDefinition
    var sets: [WorkoutSetState]
    var isSuperset: Bool = false
    var supersetGroupId: UUID?

    var isCompleted: Bool {
        sets.allSatisfy(\.isCompleted)
    }

    // MARK: - ExerciseDisplayable

    var displayName: String { exercise.name }
    var displayCategory: ExerciseCategory { exercise.category }
    var displaySetsInfo: String {
        let completedCount = sets.filter(\.isCompleted).count
        if completedCount > 0 {
            return "\(completedCount)/\(sets.count) sets"
        }
        return "\(sets.count) sets"
    }
    var displayWeight: String? {
        guard let firstSet = sets.first, firstSet.weight > 0 else { return nil }
        return "\(Int(firstSet.weight)) lbs"
    }
    var displayMuscleGroups: [String] { exercise.muscleGroups }
}

// MARK: - Workout Set State

/// State for tracking a single set during an active workout
struct WorkoutSetState: Identifiable, Equatable {
    let id: UUID
    var reps: Int
    var weight: Double
    var isCompleted: Bool = false
}

// MARK: - Exercise Definition

/// Definition of an exercise with metadata for display
struct ExerciseDefinition: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let muscleGroups: [String]
    let videoURL: URL?
    let description: String
    let aliases: [String]
    let relatedExercises: [String]
}

// MARK: - Planned Exercise

/// A planned exercise for a workout day
struct PlannedExercise: Identifiable, ExerciseDisplayable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let sets: Int
    let reps: String
    let targetWeight: String?
    let muscleGroups: [String]

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory = .push,
        sets: Int,
        reps: String,
        targetWeight: String? = nil,
        muscleGroups: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.sets = sets
        self.reps = reps
        self.targetWeight = targetWeight
        self.muscleGroups = muscleGroups
    }

    // MARK: - ExerciseDisplayable

    var displayName: String { name }
    var displayCategory: ExerciseCategory { category }
    var displaySetsInfo: String { "\(sets) sets × \(reps)" }
    var displayWeight: String? { targetWeight }
    var displayMuscleGroups: [String] { muscleGroups }
    var isCompleted: Bool { false }  // Planned exercises are never completed

    /// Convert to a WorkoutExerciseState for active workout tracking
    func toWorkoutExerciseState() -> WorkoutExerciseState {
        let repsValue =
            Int(reps.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "10")
            ?? 10
        let weightValue =
            Double(
                targetWeight?.components(separatedBy: CharacterSet.decimalDigits.inverted).first
                    ?? "0") ?? 0

        return WorkoutExerciseState(
            id: id,
            exercise: ExerciseDefinition(
                id: id,
                name: name,
                category: category,
                muscleGroups: muscleGroups,
                videoURL: nil,
                description: "Perform this exercise with controlled movement.",
                aliases: [],
                relatedExercises: []
            ),
            sets: (0..<sets).map { _ in
                WorkoutSetState(id: UUID(), reps: repsValue, weight: weightValue)
            }
        )
    }

    /// Convert to a WorkoutExercise for starting a workout
    func toWorkoutExercise() -> WorkoutExercise {
        let repsValue =
            Int(reps.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "10")
            ?? 10
        let weightValue =
            Double(
                targetWeight?.components(separatedBy: CharacterSet.decimalDigits.inverted).first
                    ?? "0") ?? 0

        // Map ExerciseCategory to MuscleGroup
        let muscleGroupsMapped: [MuscleGroup] = muscleGroups.compactMap { groupName in
            MuscleGroup(rawValue: groupName) ?? MuscleGroup.abs  // fallback
        }

        let exercise = Exercise(
            name: name,
            equipmentRequired: .barbell,  // Default, could be smarter
            muscleGroups: muscleGroupsMapped.isEmpty ? [.abs] : muscleGroupsMapped
        )

        let exerciseSets = (0..<sets).map { _ in
            ExerciseSet(reps: repsValue, weight: weightValue)
        }

        return WorkoutExercise(exercise: exercise, sets: exerciseSets)
    }
}

// MARK: - WorkoutExercise Extension (from BetterFit package)

extension WorkoutExercise: ExerciseDisplayable {
    var displayName: String { exercise.name }

    var displayCategory: ExerciseCategory {
        // Map MuscleGroup to ExerciseCategory based on primary muscles
        guard let primaryMuscle = exercise.muscleGroups.first else { return .compound }
        switch primaryMuscle {
        case .chest, .shoulders, .triceps: return .push
        case .lats, .back, .biceps, .traps: return .pull
        case .quads, .hamstrings, .glutes, .calves: return .legs
        case .abs, .obliques: return .core
        case .forearms: return .compound
        }
    }

    var displaySetsInfo: String {
        let setsCount = sets.count
        if let firstSet = sets.first {
            return "\(setsCount) sets × \(firstSet.reps)"
        }
        return "\(setsCount) sets"
    }

    var displayWeight: String? {
        guard let firstSet = sets.first, let weight = firstSet.weight, weight > 0 else {
            return nil
        }
        return "\(Int(weight)) lbs"
    }

    var displayMuscleGroups: [String] {
        exercise.muscleGroups.map(\.rawValue)
    }

    var isCompleted: Bool { false }
}
