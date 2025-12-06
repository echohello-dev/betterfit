import XCTest
@testable import BetterFit

final class AIAdaptationTests: XCTestCase {
    
    func testAnalyzePerformanceLowCompletion() {
        let service = AIAdaptationService()
        
        let exercise = Exercise(
            name: "Test",
            equipmentRequired: .barbell,
            muscleGroups: [.chest]
        )
        
        let incompleteWorkouts = [
            Workout(
                name: "W1",
                exercises: [
                    WorkoutExercise(
                        exercise: exercise,
                        sets: [
                            ExerciseSet(reps: 10, isCompleted: false),
                            ExerciseSet(reps: 10, isCompleted: false)
                        ]
                    )
                ]
            )
        ]
        
        let plan = TrainingPlan(name: "Test", goal: .strength)
        let adaptations = service.analyzePerformance(
            workouts: incompleteWorkouts,
            currentPlan: plan
        )
        
        XCTAssertTrue(adaptations.contains { 
            if case .reduceVolume = $0 { return true }
            return false
        })
    }
    
    func testAnalyzePerformanceHighCompletion() {
        let service = AIAdaptationService()
        
        let exercise = Exercise(
            name: "Test",
            equipmentRequired: .barbell,
            muscleGroups: [.chest]
        )
        
        let completeWorkouts = [
            Workout(
                name: "W1",
                exercises: [
                    WorkoutExercise(
                        exercise: exercise,
                        sets: [
                            ExerciseSet(reps: 10, isCompleted: true),
                            ExerciseSet(reps: 10, isCompleted: true)
                        ]
                    )
                ]
            )
        ]
        
        let plan = TrainingPlan(name: "Test", goal: .strength)
        let adaptations = service.analyzePerformance(
            workouts: completeWorkouts,
            currentPlan: plan
        )
        
        XCTAssertTrue(adaptations.contains { 
            if case .increaseVolume = $0 { return true }
            return false
        })
    }
    
    func testAdaptationDescriptions() {
        let reduceAdaptation = Adaptation.reduceVolume(percentage: 15)
        XCTAssertEqual(reduceAdaptation.description, "Reduce training volume by 15%")
        
        let increaseAdaptation = Adaptation.increaseVolume(percentage: 10)
        XCTAssertEqual(increaseAdaptation.description, "Increase training volume by 10%")
    }
}
