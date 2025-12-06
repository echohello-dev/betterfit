import Foundation

/// Represents a single exercise in a workout
public struct Exercise: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var equipmentRequired: Equipment
    public var muscleGroups: [MuscleGroup]
    public var imageURL: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        equipmentRequired: Equipment,
        muscleGroups: [MuscleGroup],
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.equipmentRequired = equipmentRequired
        self.muscleGroups = muscleGroups
        self.imageURL = imageURL
    }
}

/// Equipment types for exercises
public enum Equipment: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case kettlebell
    case machine
    case cable
    case bodyweight
    case bands
    case other
    
    /// Get alternative equipment for fast swaps
    public func alternatives() -> [Equipment] {
        switch self {
        case .barbell:
            return [.dumbbell, .machine]
        case .dumbbell:
            return [.barbell, .kettlebell]
        case .kettlebell:
            return [.dumbbell]
        case .machine:
            return [.barbell, .cable]
        case .cable:
            return [.machine, .bands]
        case .bodyweight:
            return [.bands]
        case .bands:
            return [.cable, .bodyweight]
        case .other:
            return []
        }
    }
}

/// Muscle groups targeted by exercises
public enum MuscleGroup: String, Codable, CaseIterable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case forearms
    case abs
    case obliques
    case quads
    case hamstrings
    case glutes
    case calves
    case traps
    case lats
    
    /// Returns the body map region for recovery tracking
    public var bodyMapRegion: String {
        switch self {
        case .chest: return "chest"
        case .back, .lats: return "back"
        case .shoulders, .traps: return "shoulders"
        case .biceps, .triceps, .forearms: return "arms"
        case .abs, .obliques: return "core"
        case .quads, .hamstrings, .glutes, .calves: return "legs"
        }
    }
}
