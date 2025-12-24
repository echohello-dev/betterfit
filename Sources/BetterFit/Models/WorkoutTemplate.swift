import Foundation

/// Reusable workout template
public struct WorkoutTemplate: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var exercises: [TemplateExercise]
    public var tags: [String]
    public var createdDate: Date
    public var lastUsedDate: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        exercises: [TemplateExercise] = [],
        tags: [String] = [],
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.tags = tags
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
    }
    
    /// Convert template to a workout
    public func createWorkout() -> Workout {
        let workoutExercises = exercises.map { templateExercise in
            WorkoutExercise(
                exercise: templateExercise.exercise,
                sets: templateExercise.targetSets.map { target in
                    ExerciseSet(reps: target.reps, weight: target.weight)
                }
            )
        }
        
        return Workout(
            name: name,
            exercises: workoutExercises,
            templateId: id
        )
    }
}

/// Exercise definition in a template
public struct TemplateExercise: Identifiable, Codable, Equatable {
    public let id: UUID
    public var exercise: Exercise
    public var targetSets: [TargetSet]
    public var restTime: TimeInterval?
    
    public init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetSets: [TargetSet] = [],
        restTime: TimeInterval? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.restTime = restTime
    }
}

/// Target set configuration
public struct TargetSet: Codable, Equatable {
    public var reps: Int
    public var weight: Double?
    
    public init(reps: Int, weight: Double? = nil) {
        self.reps = reps
        self.weight = weight
    }
}
