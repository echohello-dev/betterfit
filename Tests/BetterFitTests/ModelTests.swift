import XCTest
@testable import BetterFit

final class ModelTests: XCTestCase {
    
    func testExerciseCreation() {
        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )
        
        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.equipmentRequired, .barbell)
        XCTAssertEqual(exercise.muscleGroups.count, 2)
    }
    
    func testEquipmentAlternatives() {
        let barbellAlternatives = Equipment.barbell.alternatives()
        XCTAssertTrue(barbellAlternatives.contains(.dumbbell))
        XCTAssertTrue(barbellAlternatives.contains(.machine))
    }
    
    func testMuscleGroupBodyMapRegion() {
        XCTAssertEqual(MuscleGroup.chest.bodyMapRegion, "chest")
        XCTAssertEqual(MuscleGroup.biceps.bodyMapRegion, "arms")
        XCTAssertEqual(MuscleGroup.quads.bodyMapRegion, "legs")
    }
    
    func testExerciseSetCreation() {
        let set = ExerciseSet(reps: 10, weight: 135.0)
        
        XCTAssertEqual(set.reps, 10)
        XCTAssertEqual(set.weight, 135.0)
        XCTAssertFalse(set.isCompleted)
        XCTAssertFalse(set.autoTracked)
    }
    
    func testWorkoutCreation() {
        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            sets: [
                ExerciseSet(reps: 5, weight: 225.0),
                ExerciseSet(reps: 5, weight: 225.0)
            ]
        )
        
        let workout = Workout(
            name: "Leg Day",
            exercises: [workoutExercise]
        )
        
        XCTAssertEqual(workout.name, "Leg Day")
        XCTAssertEqual(workout.exercises.count, 1)
        XCTAssertEqual(workout.exercises[0].sets.count, 2)
    }
    
    func testTemplateToWorkoutConversion() {
        let exercise = Exercise(
            name: "Deadlift",
            equipmentRequired: .barbell,
            muscleGroups: [.back, .hamstrings]
        )
        
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: [
                TargetSet(reps: 5, weight: 315.0)
            ]
        )
        
        let template = WorkoutTemplate(
            name: "Power Day",
            exercises: [templateExercise]
        )
        
        let workout = template.createWorkout()
        
        XCTAssertEqual(workout.name, "Power Day")
        XCTAssertEqual(workout.templateId, template.id)
        XCTAssertEqual(workout.exercises.count, 1)
        XCTAssertEqual(workout.exercises[0].sets.count, 1)
    }
}
