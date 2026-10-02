import XCTest

/// UI tests for the Log tab: streak readout, consistency heatmap, month ledger
final class LogViewUITests: XCTestCase {
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

    // MARK: - Streak and Ledger

    func testLogShowsStreakConsistencyAndStats() throws {
        navigateToLog()

        let streakLabel = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Current streak'")
        ).firstMatch
        XCTAssertTrue(streakLabel.waitForExistence(timeout: 3), "Streak readout should be visible")
        XCTAssertTrue(app.staticTexts["days"].exists, "Streak readout should show the days unit")

        let streakNote = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Consistency compounds'")
        ).firstMatch
        let emptyNote = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Start a session today'")
        ).firstMatch
        XCTAssertTrue(streakNote.exists || emptyNote.exists, "Streak note should be visible")

        XCTAssertTrue(app.staticTexts["26 weeks"].exists, "Consistency section should cover 26 weeks")

        let heatmap = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS[c] 'Training consistency heatmap'")
        ).firstMatch
        XCTAssertTrue(heatmap.exists, "Training consistency heatmap should be visible")

        XCTAssertTrue(app.staticTexts["Sessions"].exists, "All-time sessions row should be visible")
        XCTAssertTrue(app.staticTexts["Volume lifted"].exists, "All-time volume row should be visible")
        XCTAssertTrue(app.staticTexts["Time training"].exists, "All-time time row should be visible")
    }

    // MARK: - Log a Past Workout

    func testLogPastWorkoutRowOpensSheet() throws {
        navigateToLog()

        let addRow = app.buttons["Log a past workout"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 3), "Log a past workout row should be visible")
        scrollUntilHittable(addRow)
        XCTAssertTrue(addRow.isHittable, "Log a past workout row should be tappable")
        addRow.tap()

        // The sheet's content is a bare Text and iOS 26 does not expose it as a
        // Sheet element (app.sheets stays empty), so assert the label appears a
        // second time: once for the add-row button, once for the sheet content.
        let sheetContent = app.staticTexts.matching(
            NSPredicate(format: "label == %@", "Log a past workout")
        )
        let sheetPresented = expectation(
            for: NSPredicate(format: "count == 2"),
            evaluatedWith: sheetContent
        )
        wait(for: [sheetPresented], timeout: 3)

        app.swipeDown(velocity: .fast)
        sleep(1)
    }

    // MARK: - Helper Methods

    private func navigateToLog() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tabs = tabBar.buttons.allElementsBoundByIndex
        XCTAssertGreaterThan(tabs.count, 3, "Expected at least 4 tabs")
        tabs[3].tap() // Log tab

        XCTAssertTrue(app.staticTexts["Log"].waitForExistence(timeout: 3))
    }

    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 8) {
        for _ in 0..<maxSwipes {
            if element.isHittable { return }
            app.swipeUp()
            sleep(1)
        }
    }
}
