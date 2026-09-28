import XCTest

/// UI tests for the workout preview screen opened from Workout Home
final class WorkoutPreviewUITests: XCTestCase {
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

    // MARK: - Preview Journey

    func testLegsAPreviewRendersWorkAndCloses() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Workout home should be loaded")

        let legsRow = app.staticTexts["Legs A"]
        scrollUntilHittable(legsRow)
        XCTAssertTrue(legsRow.isHittable, "Legs A should be listed under Start something else")
        legsRow.firstMatch.tap()

        let eyebrow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Suggested workout'")
        ).firstMatch
        XCTAssertTrue(eyebrow.waitForExistence(timeout: 3), "Preview should show its suggested workout header")

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.exists,
            "Preview should list the work section")
        XCTAssertTrue(app.staticTexts["5 exercises"].exists, "Preview should show the exercise count")
        XCTAssertTrue(app.staticTexts["Back squat"].exists, "Preview should list Legs A exercises")

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3), "Preview should offer a Close action")
        closeButton.tap()

        XCTAssertFalse(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'Suggested workout'")
            ).firstMatch.exists,
            "Preview should dismiss")
        XCTAssertTrue(
            app.staticTexts["Legs A"].waitForExistence(timeout: 3),
            "Workout home should show the suggested row again")
    }

    // MARK: - Helper Methods

    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 8) {
        for _ in 0..<maxSwipes {
            if element.isHittable { return }
            app.swipeUp()
            sleep(1)
        }
    }
}
