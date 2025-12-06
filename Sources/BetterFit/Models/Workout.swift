import Foundation

/// Represents a workout session
public struct Workout: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var exercises: [WorkoutExercise]
    public var date: Date
    public var duration: TimeInterval?
    public var isCompleted: Bool
    public var templateId: UUID?
    
    public init(
        id: UUID = UUID(),
        name: String,
        exercises: [WorkoutExercise] = [],
        date: Date = Date(),
        duration: TimeInterval? = nil,
        isCompleted: Bool = false,
        templateId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
        self.isCompleted = isCompleted
        self.templateId = templateId
    }
}

/// Represents an exercise within a workout with its sets
public struct WorkoutExercise: Identifiable, Codable, Equatable {
    public let id: UUID
    public var exercise: Exercise
    public var sets: [ExerciseSet]
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [ExerciseSet] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.notes = notes
    }
}
