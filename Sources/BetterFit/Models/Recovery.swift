import Foundation

/// Body map for tracking recovery
public struct BodyMapRecovery: Codable, Equatable {
    public var regions: [BodyRegion: RecoveryStatus]
    public var lastUpdated: Date

    public init(
        regions: [BodyRegion: RecoveryStatus] = [:],
        lastUpdated: Date = Date()
    ) {
        self.regions = regions
        self.lastUpdated = lastUpdated
    }

    /// Update recovery status after a workout
    public mutating func recordWorkout(_ workout: Workout) {
        let muscleGroups = workout.exercises.flatMap { $0.exercise.muscleGroups }

        for group in muscleGroups {
            let region = BodyRegion(rawValue: group.bodyMapRegion) ?? .other
            let currentStatus = regions[region] ?? .recovered

            // Mark as worked
            regions[region] = currentStatus.afterWorkout()
        }

        lastUpdated = Date()
    }

    /// Update recovery status based on time elapsed
    public mutating func updateRecovery() {
        let now = Date()

        for (region, status) in regions {
            let hoursSince = now.timeIntervalSince(lastUpdated) / 3600
            regions[region] = status.afterRecovery(hours: hoursSince)
        }

        lastUpdated = now
    }
}

/// Body regions for recovery tracking
public enum BodyRegion: String, Codable, CaseIterable {
    case chest
    case back
    case shoulders
    case arms
    case core
    case legs
    case other
}

/// Recovery status for muscle groups
public enum RecoveryStatus: String, Codable, Equatable {
    case recovered
    case slightlyFatigued
    case fatigued
    case sore

    /// Get status after a workout
    public func afterWorkout() -> RecoveryStatus {
        switch self {
        case .recovered:
            return .fatigued
        case .slightlyFatigued:
            return .sore
        case .fatigued, .sore:
            return .sore
        }
    }

    /// Get status after recovery time
    public func afterRecovery(hours: Double) -> RecoveryStatus {
        switch self {
        case .recovered:
            return .recovered
        case .slightlyFatigued:
            return hours >= 24 ? .recovered : .slightlyFatigued
        case .fatigued:
            return hours >= 48 ? .recovered : (hours >= 24 ? .slightlyFatigued : .fatigued)
        case .sore:
            return hours >= 72 ? .recovered : (hours >= 48 ? .fatigued : .sore)
        }
    }

    /// Recommended rest before training again
    public var recommendedRestHours: Double {
        switch self {
        case .recovered: return 0
        case .slightlyFatigued: return 24
        case .fatigued: return 48
        case .sore: return 72
        }
    }
}
