import XCTest

/// UI tests for the Targets tab: weekly goals, week plan, streak, records
final class TargetsViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Enable demo mode for consistent test data
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Weekly Targets

    func testTargetsShowsWeekAndWeeklyTargets() throws {
        navigateToTargets()

        let weekHeader = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'This week'")
        ).firstMatch
        XCTAssertTrue(weekHeader.waitForExistence(timeout: 3), "This week slab should be visible")

        let targetsHeader = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Weekly targets'")
        ).firstMatch
        XCTAssertTrue(targetsHeader.exists, "Weekly targets section should be visible")

        XCTAssertTrue(app.staticTexts["Workouts"].exists, "Workouts target row should be visible")

        // Volume and Time rows appear only when real history exists for the metric
        for (label, unit) in [("Volume", "k"), ("Time", "h")] where app.staticTexts[label].exists {
            XCTAssertTrue(
                app.staticTexts.matching(
                    NSPredicate(format: "label MATCHES %@", "^[0-9]+(\\.[0-9])?\(unit)$")
                ).count > 0,
                "\(label) row should show a real value in \(unit)")
        }

        // Rows with a derived goal show a progress caption; its percentage is data-dependent
        let captions = app.staticTexts.matching(
            NSPredicate(format: "label ENDSWITH '% of the week'")
        )
        for index in 0..<captions.count {
            XCTAssertTrue(
                NSPredicate(format: "SELF MATCHES '[0-9]+% of the week'").evaluate(
                    with: captions.element(boundBy: index).label
                ),
                "Progress captions should show a real percentage")
        }

        // Find day rows by looking for workout types
        let workoutTypes = ["Push", "Pull", "Legs", "Upper", "Rest"]
        let foundDays = workoutTypes.filter { app.staticTexts[$0].exists }.count

        XCTAssertGreaterThan(foundDays, 0, "Expected at least one planned day this week")
    }

    // MARK: - Streak and Records

    func testTargetsScrollRevealsStreakAndRecords() throws {
        navigateToTargets()

        let currentStreak = app.staticTexts["Current streak"]
        let keepTraining = app.staticTexts["Keep training"]

        scrollUntilHittable(keepTraining)
        XCTAssertTrue(currentStreak.isHittable, "Streak row should be reachable after scrolling")
        XCTAssertTrue(keepTraining.isHittable, "Records row should be reachable after scrolling")

        let recordsHeader = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Records this month'")
        ).firstMatch
        XCTAssertTrue(recordsHeader.exists, "Records section should be visible")
        XCTAssertTrue(
            app.staticTexts["Personal records appear here"].exists,
            "Records row should show its empty-state meta")
    }

    // MARK: - Helper Methods

    private func navigateToTargets() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tabs = tabBar.buttons.allElementsBoundByIndex
        XCTAssertGreaterThan(tabs.count, 2, "Expected at least 3 tabs")
        tabs[2].tap() // Targets tab

        XCTAssertTrue(app.staticTexts["Targets"].waitForExistence(timeout: 3))
    }

    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 8) {
        for _ in 0..<maxSwipes {
            if element.isHittable { return }
            app.swipeUp()
            sleep(1)
        }
    }
}
