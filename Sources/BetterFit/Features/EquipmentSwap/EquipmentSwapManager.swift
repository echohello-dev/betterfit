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

    // MARK: - Catalogue Alternatives

    /// Find real exercises using available alternative equipment and exactly the
    /// same non-empty set of muscle groups. Results preserve catalogue order,
    /// identity and metadata, returning the first eligible entry per exercise ID.
    /// Returns no suggestions when the original equipment is available.
    /// Muscle matching alone does not establish movement equivalence; callers
    /// should supply a catalogue appropriate for the workout.
    public func findAlternatives(for exercise: Exercise, from catalogue: [Exercise]) -> [Exercise] {
        let muscles = Set(exercise.muscleGroups)
        guard !isAvailable(exercise.equipmentRequired), !muscles.isEmpty else { return [] }

        let equipment = Set(exercise.equipmentRequired.alternatives()).intersection(availableEquipment)
        var seen: Set<UUID> = []
        return catalogue.filter { candidate in
            candidate.id != exercise.id
                && equipment.contains(candidate.equipmentRequired)
                && Set(candidate.muscleGroups) == muscles
                && seen.insert(candidate.id).inserted
        }
    }

    // MARK: - Workout Swaps

    /// Suggest real catalogue alternatives for each workout entry, in workout order.
    /// Entries with available equipment or no eligible alternatives are omitted.
    /// Repeated workout entries remain separate suggestions. The workout is unchanged.
    /// Uses the same matching rules as `findAlternatives(for:from:)`.
    public func suggestSwaps(
        for workout: Workout,
        from catalogue: [Exercise]
    ) -> [(original: Exercise, alternatives: [Exercise])] {
        workout.exercises.compactMap { entry in
            let alternatives = findAlternatives(for: entry.exercise, from: catalogue)
            return alternatives.isEmpty ? nil : (original: entry.exercise, alternatives: alternatives)
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
