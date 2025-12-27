import XCTest

@testable import BetterFit

final class SocialTests: XCTestCase {

    func testStreakUpdateConsecutiveDays() {
        var streak = Streak()

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        streak.updateWithWorkout(date: yesterday)
        XCTAssertEqual(streak.currentStreak, 1)

        streak.updateWithWorkout(date: today)
        XCTAssertEqual(streak.currentStreak, 2)
        XCTAssertEqual(streak.longestStreak, 2)
    }

    func testStreakBreak() {
        var streak = Streak()

        let today = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!

        streak.updateWithWorkout(date: threeDaysAgo)
        XCTAssertEqual(streak.currentStreak, 1)

        streak.updateWithWorkout(date: today)
        XCTAssertEqual(streak.currentStreak, 1)  // Reset
        XCTAssertEqual(streak.longestStreak, 1)
    }

    func testChallengeGoals() {
        let workoutChallenge = Challenge(
            name: "30 Day Challenge",
            description: "Complete 30 workouts",
            goal: .workoutCount(target: 30),
            startDate: Date(),
            endDate: Date().addingTimeInterval(30 * 86400)
        )

        XCTAssertEqual(workoutChallenge.name, "30 Day Challenge")
    }

    func testSocialManager() {
        let manager = SocialManager()

        XCTAssertNil(manager.getLastWorkoutDate())

        manager.recordWorkout()
        XCTAssertEqual(manager.getCurrentStreak(), 1)
        XCTAssertNotNil(manager.getLastWorkoutDate())

        let profile = manager.getUserProfile()
        XCTAssertEqual(profile.totalWorkouts, 1)
    }
}
