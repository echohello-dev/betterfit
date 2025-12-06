import XCTest
@testable import BetterFit

final class IntegrationTests: XCTestCase {
    
    func testBetterFitInitialization() {
        let betterFit = BetterFit()
        
        XCTAssertNotNil(betterFit.planManager)
        XCTAssertNotNil(betterFit.templateManager)
        XCTAssertNotNil(betterFit.equipmentSwapManager)
        XCTAssertNotNil(betterFit.bodyMapManager)
        XCTAssertNotNil(betterFit.socialManager)
        XCTAssertNotNil(betterFit.notificationManager)
        XCTAssertNotNil(betterFit.autoTrackingService)
        XCTAssertNotNil(betterFit.aiAdaptationService)
        XCTAssertNotNil(betterFit.imageService)
    }
    
    func testCompleteWorkoutFlow() {
        let betterFit = BetterFit()
        
        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        
        let set = ExerciseSet(reps: 5, weight: 225.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        var workout = Workout(name: "Leg Day", exercises: [workoutExercise])
        workout.isCompleted = true
        
        betterFit.startWorkout(workout)
        betterFit.completeWorkout(workout)
        
        let history = betterFit.getWorkoutHistory()
        XCTAssertEqual(history.count, 1)
        
        let streak = betterFit.socialManager.getCurrentStreak()
        XCTAssertEqual(streak, 1)
    }
    
    func testTemplateToWorkoutIntegration() {
        let betterFit = BetterFit()
        
        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )
        
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: [TargetSet(reps: 8, weight: 185.0)]
        )
        
        let template = WorkoutTemplate(
            name: "Push Day",
            exercises: [templateExercise]
        )
        
        betterFit.templateManager.addTemplate(template)
        
        let workout = betterFit.templateManager.createWorkout(from: template.id)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.name, "Push Day")
    }
}
