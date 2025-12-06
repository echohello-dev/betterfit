import Foundation

/// User profile for social features
public struct UserProfile: Identifiable, Codable, Equatable {
    public let id: UUID
    public var username: String
    public var currentStreak: Int
    public var longestStreak: Int
    public var totalWorkouts: Int
    public var activeChallenges: [UUID]
    
    public init(
        id: UUID = UUID(),
        username: String,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalWorkouts: Int = 0,
        activeChallenges: [UUID] = []
    ) {
        self.id = id
        self.username = username
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalWorkouts = totalWorkouts
        self.activeChallenges = activeChallenges
    }
}

/// Workout challenge
public struct Challenge: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var goal: ChallengeGoal
    public var startDate: Date
    public var endDate: Date
    public var participants: [UUID]
    public var progress: [UUID: Double]
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        goal: ChallengeGoal,
        startDate: Date,
        endDate: Date,
        participants: [UUID] = [],
        progress: [UUID: Double] = [:]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
        self.progress = progress
    }
}

/// Challenge goal types
public enum ChallengeGoal: Codable, Equatable {
    case workoutCount(target: Int)
    case totalVolume(target: Double)
    case consecutiveDays(target: Int)
    case specificExercise(exerciseId: UUID, target: Int)
}

/// Workout streak tracking
public struct Streak: Codable, Equatable {
    public var currentStreak: Int
    public var longestStreak: Int
    public var lastWorkoutDate: Date?
    
    public init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastWorkoutDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastWorkoutDate = lastWorkoutDate
    }
    
    /// Update streak based on workout completion
    public mutating func updateWithWorkout(date: Date) {
        guard let lastDate = lastWorkoutDate else {
            currentStreak = 1
            longestStreak = max(longestStreak, 1)
            lastWorkoutDate = date
            return
        }
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: lastDate, to: date).day ?? 0
        
        if daysDifference == 1 {
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysDifference > 1 {
            // Streak broken
            currentStreak = 1
        }
        // Same day doesn't change streak
        
        lastWorkoutDate = date
    }
}
