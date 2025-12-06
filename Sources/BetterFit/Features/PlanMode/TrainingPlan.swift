import Foundation

/// Training plan for structured workout programming
public struct TrainingPlan: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var weeks: [TrainingWeek]
    public var currentWeek: Int
    public var goal: TrainingGoal
    public var createdDate: Date
    public var aiAdapted: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        weeks: [TrainingWeek] = [],
        currentWeek: Int = 0,
        goal: TrainingGoal,
        createdDate: Date = Date(),
        aiAdapted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.weeks = weeks
        self.currentWeek = currentWeek
        self.goal = goal
        self.createdDate = createdDate
        self.aiAdapted = aiAdapted
    }
    
    /// Get the current week's plan
    public func getCurrentWeek() -> TrainingWeek? {
        guard currentWeek < weeks.count else { return nil }
        return weeks[currentWeek]
    }
    
    /// Progress to next week
    public mutating func advanceWeek() {
        if currentWeek < weeks.count - 1 {
            currentWeek += 1
        }
    }
}

/// A week in a training plan
public struct TrainingWeek: Identifiable, Codable, Equatable {
    public let id: UUID
    public var weekNumber: Int
    public var workouts: [UUID]
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        weekNumber: Int,
        workouts: [UUID] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.workouts = workouts
        self.notes = notes
    }
}

/// Training goals
public enum TrainingGoal: String, Codable, CaseIterable {
    case strength
    case hypertrophy
    case endurance
    case powerlifting
    case generalFitness
    case weightLoss
    
    /// Recommended rep ranges for goal
    public var repRange: ClosedRange<Int> {
        switch self {
        case .strength: return 1...5
        case .hypertrophy: return 6...12
        case .endurance: return 12...20
        case .powerlifting: return 1...5
        case .generalFitness: return 8...15
        case .weightLoss: return 10...20
        }
    }
    
    /// Recommended rest time between sets
    public var restTime: TimeInterval {
        switch self {
        case .strength: return 180
        case .hypertrophy: return 90
        case .endurance: return 60
        case .powerlifting: return 240
        case .generalFitness: return 90
        case .weightLoss: return 45
        }
    }
}
