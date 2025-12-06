import Foundation

/// Represents a single set in an exercise
public struct ExerciseSet: Identifiable, Codable, Equatable {
    public let id: UUID
    public var reps: Int
    public var weight: Double?
    public var isCompleted: Bool
    public var timestamp: Date?
    public var autoTracked: Bool
    
    public init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double? = nil,
        isCompleted: Bool = false,
        timestamp: Date? = nil,
        autoTracked: Bool = false
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.timestamp = timestamp
        self.autoTracked = autoTracked
    }
}
