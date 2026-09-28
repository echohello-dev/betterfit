import XCTest

/// UI tests for the workout summary shown after finishing a demo session
final class WorkoutSummaryUITests: XCTestCase {
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

    // MARK: - Finish Journey

    func testFinishSessionShowsSummary() throws {
        startDemoSession()
        finishSession()

        let complete = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Session complete'")
        ).firstMatch
        XCTAssertTrue(complete.waitForExistence(timeout: 5), "Summary should show the session-complete header")

        let whatYouLifted = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'What you lifted'")
        ).firstMatch
        XCTAssertTrue(whatYouLifted.exists, "Summary should list what you lifted")

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS 'Good work'")
            ).firstMatch.exists,
            "Summary should show the session note")

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS 'Keep the streak going'")
            ).firstMatch.exists,
            "Summary should show the next-session row")

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Summary should offer a Done action")
        doneButton.tap()

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Workout home should return after dismissing the summary")
    }

    // MARK: - Recovery Guard

    func testSummaryHidesRecoverySectionWithoutRecoveryData() throws {
        startDemoSession()
        finishSession()

        let whatYouLifted = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'What you lifted'")
        ).firstMatch
        XCTAssertTrue(whatYouLifted.waitForExistence(timeout: 5), "Summary should be rendered")

        // Scroll to the closing section so the whole summary body has been covered
        let nextRow = app.staticTexts["Keep the streak going"]
        scrollUntilHittable(nextRow)
        XCTAssertTrue(nextRow.isHittable, "Summary should scroll to the next-session row")

        let recovery = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Effect on recovery'")
        ).firstMatch
        XCTAssertFalse(
            recovery.exists,
            "Recovery section must stay hidden when the session captured no recovery data")
    }

    // MARK: - Helper Methods

    private func startDemoSession() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Workout home should be loaded before starting")

        let startButton = app.buttons["Start workout"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let firstExercise = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Exercise 01'")
        ).firstMatch
        XCTAssertTrue(
            firstExercise.waitForExistence(timeout: 5),
            "Active session should open on the first planned exercise")
    }

    private func finishSession() {
        let finishButton = app.buttons["Finish workout"]
        scrollUntilHittable(finishButton)
        XCTAssertTrue(finishButton.isHittable, "Finish workout button should be reachable")
        finishButton.tap()

        let saveButton = app.buttons["Finish & save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Finish confirmation should appear")
        saveButton.tap()
    }

    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 8) {
        for _ in 0..<maxSwipes {
            if element.isHittable { return }
            app.swipeUp()
            sleep(1)
        }
    }
}
