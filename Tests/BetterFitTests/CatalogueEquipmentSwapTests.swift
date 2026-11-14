import Foundation
import Testing
@testable import BetterFit

struct CatalogueEquipmentSwapTests {
    private let original = Exercise(
        name: "Barbell Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest, .triceps])

    // MARK: - Matching

    @Test func preservesCatalogueExercisesAndOrder() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell, .machine])
        let machine = Exercise(
            name: "Machine Chest Press", equipmentRequired: .machine,
            muscleGroups: [.triceps, .chest, .chest], imageURL: "machine-press.png")
        let dumbbell = Exercise(
            name: "Dumbbell Bench Press", equipmentRequired: .dumbbell,
            muscleGroups: [.chest, .triceps], imageURL: "dumbbell-press.png")

        let result = manager.findAlternatives(for: original, from: [machine, dumbbell, machine])

        #expect(result == [machine, dumbbell])
        #expect(manager.findAlternatives(for: original, from: [machine, dumbbell]) == result)
    }

    @Test(arguments: [Equipment.cable, .bodyweight, .bands, .other, .barbell])
    func excludesEquipmentOutsideSubstitutionRules(equipment: Equipment) {
        let manager = EquipmentSwapManager(availableEquipment: Set(Equipment.allCases).subtracting([.barbell]))
        let candidate = Exercise(
            name: "Other Press", equipmentRequired: equipment, muscleGroups: original.muscleGroups)

        #expect(manager.findAlternatives(for: original, from: [candidate]).isEmpty)
    }

    @Test(arguments: [[MuscleGroup](), [.chest], [.chest, .triceps, .shoulders], [.back, .biceps]])
    func excludesDifferentMuscleGroups(muscles: [MuscleGroup]) {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let candidate = Exercise(
            name: "Different Exercise", equipmentRequired: .dumbbell, muscleGroups: muscles)

        #expect(manager.findAlternatives(for: original, from: [candidate]).isEmpty)
    }

    @Test func excludesOriginalIDAndKeepsFirstEligibleDuplicate() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        var sameID = original
        sameID.equipmentRequired = .dumbbell
        let candidate = Exercise(
            name: "Dumbbell Bench Press", equipmentRequired: .dumbbell, muscleGroups: original.muscleGroups)
        var unavailableDuplicate = candidate
        unavailableDuplicate.equipmentRequired = .machine
        var laterDuplicate = candidate
        laterDuplicate.name = "Later Duplicate"

        let result = manager.findAlternatives(
            for: original, from: [sameID, unavailableDuplicate, candidate, laterDuplicate])

        #expect(result == [candidate])
    }

    // MARK: - Availability

    @Test func usesUpdatedEquipmentAvailability() {
        let manager = EquipmentSwapManager(availableEquipment: [.barbell, .dumbbell])
        let candidate = Exercise(
            name: "Dumbbell Bench Press", equipmentRequired: .dumbbell, muscleGroups: original.muscleGroups)

        #expect(manager.findAlternatives(for: original, from: [candidate]).isEmpty)
        manager.setAvailableEquipment([.dumbbell])
        #expect(manager.findAlternatives(for: original, from: [candidate]) == [candidate])
        manager.setAvailableEquipment([])
        #expect(manager.findAlternatives(for: original, from: [candidate]).isEmpty)
    }

    @Test func returnsNoMatchesForMissingMusclesOrEmptyCatalogue() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let unknown = Exercise(name: "Unknown", equipmentRequired: .barbell, muscleGroups: [])
        let candidate = Exercise(name: "Unknown Alternative", equipmentRequired: .dumbbell, muscleGroups: [])

        #expect(manager.findAlternatives(for: unknown, from: [candidate]).isEmpty)
        #expect(manager.findAlternatives(for: original, from: []).isEmpty)
    }

    // MARK: - Workout Application

    @Test func appliesCatalogueSelectionWithoutChangingSets() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let candidate = Exercise(
            name: "Dumbbell Bench Press", equipmentRequired: .dumbbell, muscleGroups: original.muscleGroups)
        let sets = [ExerciseSet(reps: 8, weight: 20), ExerciseSet(reps: 6, weight: 22)]
        var workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: original, sets: sets)])
        let selection = try #require(manager.findAlternatives(for: original, from: [candidate]).first)

        #expect(manager.applySwap(workout: &workout, originalExerciseId: original.id, newExercise: selection))
        #expect(workout.exercises[0].exercise == candidate)
        #expect(workout.exercises[0].sets == sets)
    }
}
