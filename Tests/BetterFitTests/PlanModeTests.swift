import XCTest
@testable import BetterFit

final class PlanModeTests: XCTestCase {
    
    func testTrainingPlanCreation() {
        let plan = TrainingPlan(
            name: "Beginner Strength",
            goal: .strength
        )
        
        XCTAssertEqual(plan.name, "Beginner Strength")
        XCTAssertEqual(plan.goal, .strength)
        XCTAssertEqual(plan.currentWeek, 0)
    }
    
    func testTrainingGoalRepRanges() {
        XCTAssertEqual(TrainingGoal.strength.repRange, 1...5)
        XCTAssertEqual(TrainingGoal.hypertrophy.repRange, 6...12)
        XCTAssertEqual(TrainingGoal.endurance.repRange, 12...20)
    }
    
    func testPlanManagerActivePlan() {
        let manager = PlanManager()
        
        let plan = TrainingPlan(
            name: "Test Plan",
            goal: .generalFitness
        )
        
        manager.addPlan(plan)
        manager.setActivePlan(plan.id)
        
        let activePlan = manager.getActivePlan()
        XCTAssertNotNil(activePlan)
        XCTAssertEqual(activePlan?.id, plan.id)
    }
    
    func testAdvanceWeek() {
        var plan = TrainingPlan(
            name: "Progressive Plan",
            weeks: [
                TrainingWeek(weekNumber: 1),
                TrainingWeek(weekNumber: 2)
            ],
            currentWeek: 0,
            goal: .strength
        )
        
        XCTAssertEqual(plan.currentWeek, 0)
        
        plan.advanceWeek()
        XCTAssertEqual(plan.currentWeek, 1)
        
        plan.advanceWeek()
        XCTAssertEqual(plan.currentWeek, 1) // Should not go beyond last week
    }
}
