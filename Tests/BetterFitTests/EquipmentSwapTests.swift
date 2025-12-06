import XCTest
@testable import BetterFit

final class EquipmentSwapTests: XCTestCase {
    
    func testEquipmentAvailability() {
        let swapManager = EquipmentSwapManager(
            availableEquipment: [.dumbbell, .bodyweight]
        )
        
        XCTAssertTrue(swapManager.isAvailable(.dumbbell))
        XCTAssertFalse(swapManager.isAvailable(.barbell))
    }
    
    func testFindAlternatives() {
        let swapManager = EquipmentSwapManager(
            availableEquipment: [.dumbbell, .bodyweight]
        )
        
        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest]
        )
        
        let alternatives = swapManager.findAlternatives(for: exercise)
        XCTAssertFalse(alternatives.isEmpty)
        XCTAssertTrue(alternatives.contains { $0.equipmentRequired == .dumbbell })
    }
    
    func testApplySwap() {
        let swapManager = EquipmentSwapManager()
        
        let originalExercise = Exercise(
            name: "Barbell Row",
            equipmentRequired: .barbell,
            muscleGroups: [.back]
        )
        
        let newExercise = Exercise(
            name: "Dumbbell Row",
            equipmentRequired: .dumbbell,
            muscleGroups: [.back]
        )
        
        var workout = Workout(
            name: "Back Day",
            exercises: [WorkoutExercise(exercise: originalExercise)]
        )
        
        let success = swapManager.applySwap(
            workout: &workout,
            originalExerciseId: originalExercise.id,
            newExercise: newExercise
        )
        
        XCTAssertTrue(success)
        XCTAssertEqual(workout.exercises[0].exercise.equipmentRequired, .dumbbell)
    }
}
