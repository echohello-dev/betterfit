import Foundation

/// AI service for adaptive training plan adjustments
public class AIAdaptationService {
    
    public init() {}
    
    /// Analyze workout performance and suggest adaptations
    public func analyzePerformance(
        workouts: [Workout],
        currentPlan: TrainingPlan
    ) -> [Adaptation] {
        var adaptations: [Adaptation] = []
        
        // Analyze completion rate
        let completionRate = calculateCompletionRate(workouts: workouts)
        if completionRate < 0.7 {
            adaptations.append(.reduceVolume(percentage: 15))
        } else if completionRate > 0.95 {
            adaptations.append(.increaseVolume(percentage: 10))
        }
        
        // Analyze progressive overload
        let isProgressing = checkProgressiveOverload(workouts: workouts)
        if !isProgressing {
            adaptations.append(.adjustIntensity(change: 5))
        }
        
        // Check for plateau
        if detectPlateauPhase(workouts: workouts) {
            adaptations.append(.deloadWeek)
        }
        
        return adaptations
    }
    
    /// Calculate workout completion rate
    private func calculateCompletionRate(workouts: [Workout]) -> Double {
        guard !workouts.isEmpty else { return 0 }
        let completedSets = workouts.flatMap { $0.exercises }.flatMap { $0.sets }.filter { $0.isCompleted }.count
        let totalSets = workouts.flatMap { $0.exercises }.flatMap { $0.sets }.count
        return totalSets > 0 ? Double(completedSets) / Double(totalSets) : 0
    }
    
    /// Check if user is achieving progressive overload
    private func checkProgressiveOverload(workouts: [Workout]) -> Bool {
        guard workouts.count >= 2 else { return true }
        
        // Compare recent workouts
        let recentWorkouts = Array(workouts.suffix(4))
        let volumes = recentWorkouts.map { calculateVolume($0) }
        
        // Check if generally trending upward
        return volumes.last ?? 0 > volumes.first ?? 0
    }
    
    /// Calculate total volume of a workout
    private func calculateVolume(_ workout: Workout) -> Double {
        return workout.exercises.reduce(0.0) { total, exercise in
            let exerciseVolume = exercise.sets.reduce(0.0) { setTotal, set in
                setTotal + (Double(set.reps) * (set.weight ?? 0))
            }
            return total + exerciseVolume
        }
    }
    
    /// Detect if user is in a plateau phase
    private func detectPlateauPhase(workouts: [Workout]) -> Bool {
        guard workouts.count >= 4 else { return false }
        
        let recentWorkouts = Array(workouts.suffix(4))
        let volumes = recentWorkouts.map { calculateVolume($0) }
        
        // Check if volumes are stagnant
        let maxVolume = volumes.max() ?? 0
        let minVolume = volumes.min() ?? 0
        let variance = maxVolume - minVolume
        
        return variance < (maxVolume * 0.05) // Less than 5% variance
    }
    
    /// Apply adaptations to a training plan
    public func applyAdaptations(
        _ adaptations: [Adaptation],
        to plan: inout TrainingPlan
    ) {
        for adaptation in adaptations {
            switch adaptation {
            case .reduceVolume(let percentage):
                // Reduce sets in plan
                reducePlanVolume(plan: &plan, by: percentage)
            case .increaseVolume(let percentage):
                // Add sets in plan
                increasePlanVolume(plan: &plan, by: percentage)
            case .adjustIntensity(let change):
                // Adjust weights
                adjustPlanIntensity(plan: &plan, by: change)
            case .deloadWeek:
                // Insert deload week
                insertDeloadWeek(plan: &plan)
            }
        }
        
        plan.aiAdapted = true
    }
    
    private func reducePlanVolume(plan: inout TrainingPlan, by percentage: Int) {
        // Implementation would reduce number of sets
    }
    
    private func increasePlanVolume(plan: inout TrainingPlan, by percentage: Int) {
        // Implementation would add sets
    }
    
    private func adjustPlanIntensity(plan: inout TrainingPlan, by change: Int) {
        // Implementation would adjust weights
    }
    
    private func insertDeloadWeek(plan: inout TrainingPlan) {
        // Implementation would add a lighter week
    }
}

/// Training plan adaptation suggestions
public enum Adaptation: Equatable {
    case reduceVolume(percentage: Int)
    case increaseVolume(percentage: Int)
    case adjustIntensity(change: Int)
    case deloadWeek
    
    public var description: String {
        switch self {
        case .reduceVolume(let percentage):
            return "Reduce training volume by \(percentage)%"
        case .increaseVolume(let percentage):
            return "Increase training volume by \(percentage)%"
        case .adjustIntensity(let change):
            return "Adjust intensity by \(change)%"
        case .deloadWeek:
            return "Schedule a deload week"
        }
    }
}
