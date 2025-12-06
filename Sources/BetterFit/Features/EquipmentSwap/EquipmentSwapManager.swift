import Foundation

/// Manages fast equipment swaps for available equipment
public class EquipmentSwapManager {
    private var availableEquipment: Set<Equipment>
    
    public init(availableEquipment: Set<Equipment> = Set(Equipment.allCases)) {
        self.availableEquipment = availableEquipment
    }
    
    /// Set available equipment
    public func setAvailableEquipment(_ equipment: Set<Equipment>) {
        self.availableEquipment = equipment
    }
    
    /// Check if equipment is available
    public func isAvailable(_ equipment: Equipment) -> Bool {
        return availableEquipment.contains(equipment)
    }
    
    /// Find alternative exercises for unavailable equipment
    public func findAlternatives(for exercise: Exercise) -> [Exercise] {
        // If equipment is available, return empty array
        if isAvailable(exercise.equipmentRequired) {
            return []
        }
        
        // Get alternative equipment options
        let alternatives = exercise.equipmentRequired.alternatives()
        
        // Filter to only available equipment
        let availableAlternatives = alternatives.filter { isAvailable($0) }
        
        // Create alternative exercises with same muscle groups
        return availableAlternatives.map { altEquipment in
            Exercise(
                name: "\(exercise.name) (\(altEquipment.rawValue))",
                equipmentRequired: altEquipment,
                muscleGroups: exercise.muscleGroups,
                imageURL: exercise.imageURL
            )
        }
    }
    
    /// Suggest equipment swap for a workout
    public func suggestSwaps(for workout: Workout) -> [(original: Exercise, alternatives: [Exercise])] {
        var suggestions: [(Exercise, [Exercise])] = []
        
        for workoutExercise in workout.exercises {
            let alternatives = findAlternatives(for: workoutExercise.exercise)
            if !alternatives.isEmpty {
                suggestions.append((workoutExercise.exercise, alternatives))
            }
        }
        
        return suggestions
    }
    
    /// Apply equipment swap to workout
    public func applySwap(
        workout: inout Workout,
        originalExerciseId: UUID,
        newExercise: Exercise
    ) -> Bool {
        guard let index = workout.exercises.firstIndex(where: { $0.exercise.id == originalExerciseId }) else {
            return false
        }
        
        // Keep the sets but update the exercise
        workout.exercises[index].exercise = newExercise
        return true
    }
}
