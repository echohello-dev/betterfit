import Foundation

/// Manages body map recovery view
public class BodyMapManager {
    private var recoveryMap: BodyMapRecovery
    
    public init(recoveryMap: BodyMapRecovery = BodyMapRecovery()) {
        self.recoveryMap = recoveryMap
    }
    
    /// Get current recovery map
    public func getRecoveryMap() -> BodyMapRecovery {
        // Update recovery before returning
        var updatedMap = recoveryMap
        updatedMap.updateRecovery()
        recoveryMap = updatedMap
        return recoveryMap
    }
    
    /// Record workout to update recovery map
    public func recordWorkout(_ workout: Workout) {
        recoveryMap.recordWorkout(workout)
    }
    
    /// Get recovery status for a specific region
    public func getRecoveryStatus(for region: BodyRegion) -> RecoveryStatus {
        var updatedMap = recoveryMap
        updatedMap.updateRecovery()
        recoveryMap = updatedMap
        
        return recoveryMap.regions[region] ?? .recovered
    }
    
    /// Check if region is ready for training
    public func isReadyForTraining(region: BodyRegion) -> Bool {
        let status = getRecoveryStatus(for: region)
        return status == .recovered || status == .slightlyFatigued
    }
    
    /// Get recommended exercises based on recovery status
    public func getRecommendedExercises(
        available: [Exercise],
        avoidSoreRegions: Bool = true
    ) -> [Exercise] {
        var updatedMap = recoveryMap
        updatedMap.updateRecovery()
        
        return available.filter { exercise in
            let muscleGroups = exercise.muscleGroups
            let regions = muscleGroups.map { BodyRegion(rawValue: $0.bodyMapRegion) ?? .other }
            
            // Check if any targeted region is too sore
            let hasSoreRegion = regions.contains { region in
                let status = updatedMap.regions[region] ?? .recovered
                return status == .sore
            }
            
            return !avoidSoreRegions || !hasSoreRegion
        }
    }
    
    /// Get overall recovery percentage
    public func getOverallRecoveryPercentage() -> Double {
        var updatedMap = recoveryMap
        updatedMap.updateRecovery()
        
        guard !updatedMap.regions.isEmpty else { return 100.0 }
        
        let totalScore = updatedMap.regions.values.reduce(0.0) { total, status in
            total + status.recoveryScore
        }
        
        return (totalScore / Double(updatedMap.regions.count)) * 100
    }
    
    /// Reset recovery map
    public func reset() {
        recoveryMap = BodyMapRecovery()
    }
}

extension RecoveryStatus {
    /// Get recovery score (0-1) for overall calculation
    var recoveryScore: Double {
        switch self {
        case .recovered: return 1.0
        case .slightlyFatigued: return 0.75
        case .fatigued: return 0.5
        case .sore: return 0.25
        }
    }
}
