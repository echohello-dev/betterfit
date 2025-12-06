import XCTest
@testable import BetterFit

final class RecoveryTests: XCTestCase {
    
    func testRecoveryStatusProgression() {
        let recovered = RecoveryStatus.recovered
        XCTAssertEqual(recovered.afterWorkout(), .fatigued)
        
        let fatigued = RecoveryStatus.fatigued
        XCTAssertEqual(fatigued.afterRecovery(hours: 48), .recovered)
        XCTAssertEqual(fatigued.afterRecovery(hours: 24), .slightlyFatigued)
    }
    
    func testBodyMapRecoveryUpdate() {
        var bodyMap = BodyMapRecovery()
        
        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )
        
        let workout = Workout(
            name: "Chest Day",
            exercises: [WorkoutExercise(exercise: exercise)]
        )
        
        bodyMap.recordWorkout(workout)
        
        XCTAssertNotNil(bodyMap.regions[.chest])
        XCTAssertEqual(bodyMap.regions[.chest], .fatigued)
    }
    
    func testBodyMapManager() {
        let manager = BodyMapManager()
        
        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        
        let workout = Workout(
            name: "Leg Day",
            exercises: [WorkoutExercise(exercise: exercise)]
        )
        
        manager.recordWorkout(workout)
        
        let status = manager.getRecoveryStatus(for: .legs)
        // Squat works both quads and glutes, which both map to legs region
        // So it gets hit twice: recovered -> fatigued -> sore
        XCTAssertEqual(status, .sore)
    }
}
