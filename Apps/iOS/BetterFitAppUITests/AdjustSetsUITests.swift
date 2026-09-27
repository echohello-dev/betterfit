import XCTest

/// UI tests for core workout planning journeys:
/// today's plan on the Workout tab, the exercise set editor (adjust sets),
/// and the plan insights that moved to the Body and Targets tabs.
final class AdjustSetsUITests: XCTestCase {
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

    // MARK: - Plan Navigation

    func testLaunchAndNavigateToPlan() throws {
        // Verify app launches with tab bar
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))

        // The plan lives on the Workout tab
        app.tabBars.buttons["Workout"].tap()

        // Verify today's plan loaded
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Workout tab should show today's plan")

        // Verify the work list is present
        XCTAssertTrue(
            app.buttons["Add exercise"].waitForExistence(timeout: 2),
            "Work list should offer adding exercises")
    }

    func testPlanShowsPlannedExercises() throws {
        navigateToPlan()

        // Each planned exercise renders its set count ("3 sets" …)
        let setRows = app.staticTexts.matching(
            NSPredicate(format: "label ENDSWITH 'sets'")
        )
        XCTAssertGreaterThan(setRows.count, 0, "Expected at least one planned exercise with sets")
    }

    // MARK: - Exercise Detail (adjust sets)

    func testSelectExerciseOpensDetails() throws {
        navigateToPlan()

        // The first planned exercise is marked as the focus row; tapping it
        // opens the exercise detail (set editor) sheet.
        let focusRow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Focus exercise'")
        ).firstMatch
        XCTAssertTrue(
            focusRow.waitForExistence(timeout: 3),
            "First planned exercise should be marked as the focus exercise")
        focusRow.tap()

        let sheetTitle = app.navigationBars["Exercise Details"].firstMatch
        let setEditor = app.staticTexts["Tap a value to edit"]
        XCTAssertTrue(
            sheetTitle.waitForExistence(timeout: 3) || setEditor.waitForExistence(timeout: 2),
            "Tapping an exercise row should open its detail sheet")
    }

    func testExerciseDetailShowsSetControls() throws {
        navigateToPlan()

        let focusRow = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Focus exercise'")
        ).firstMatch
        XCTAssertTrue(focusRow.waitForExistence(timeout: 3))
        focusRow.tap()

        // Set editor: sets section with editable kg/reps columns and save controls
        XCTAssertTrue(
            app.staticTexts["Sets"].waitForExistence(timeout: 3),
            "Detail sheet should list the sets section")
        XCTAssertTrue(app.staticTexts["Tap a value to edit"].exists, "Set editor should be editable")
        XCTAssertTrue(app.staticTexts["KG"].exists, "Set editor should show the weight column")
        XCTAssertTrue(app.staticTexts["REPS"].exists, "Set editor should show the reps column")
        XCTAssertTrue(app.buttons["Save"].exists, "Detail sheet should offer Save")
        XCTAssertTrue(app.buttons["Cancel"].exists, "Detail sheet should offer Cancel")
    }

    // MARK: - Recovery Insights

    func testRecoveryInsightsVisible() throws {
        // Recovery insights moved off the plan screen onto the Body tab.
        app.tabBars.buttons["Body"].tap()

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'By muscle group'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Per-muscle recovery insights should be visible on the Body tab")

        // Every tracked region gets a recovery row
        XCTAssertTrue(
            app.staticTexts["Chest"].exists,
            "Recovery rows should list muscle groups")
    }

    // MARK: - Weekly Stats

    func testWeeklyStatsVisible() throws {
        // Weekly progress moved off the plan screen onto the Targets tab.
        app.tabBars.buttons["Targets"].tap()

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'This week'")
            ).firstMatch.waitForExistence(timeout: 3),
            "This week's progress should be visible on the Targets tab")

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label ENDSWITH '% of the week'")
            ).firstMatch.exists,
            "Weekly target rows should show their weekly progress")
    }

    // MARK: - Helper Methods

    private func navigateToPlan() {
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))

        // The plan lives on the Workout tab
        app.tabBars.buttons["Workout"].tap()

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'The work'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Workout tab should load today's plan")
    }
}
