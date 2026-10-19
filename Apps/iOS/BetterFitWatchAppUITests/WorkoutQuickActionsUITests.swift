import XCTest

final class WorkoutQuickActionsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    // MARK: - Crown Editing

    func testInlineCrownEditingAndOneTapLogging() {
        startWorkout()
        let reps = app.buttons["rep-count"]
        XCTAssertEqual(reps.value as? String, "8")
        reps.tap()
        XCTAssertTrue(reps.isSelected, "Tapping a value must retain Crown focus")
        XCUIDevice.shared.rotateDigitalCrown(delta: 0.25, velocity: .slow)
        waitFor(NSPredicate(format: "value != nil AND value != %@", "8"), on: reps)
        let editedReps = reps.value as? String
        let weight = app.buttons["weight-value"]
        weight.tap()
        XCTAssertTrue(weight.isSelected)
        XCTAssertFalse(reps.isSelected)
        XCUIDevice.shared.rotateDigitalCrown(delta: 0.25, velocity: .slow)
        waitFor(NSPredicate(format: "value != nil AND value != %@", "60"), on: weight)
        XCTAssertEqual(reps.value as? String, editedReps, "Editing weight must not change reps")
        XCTAssertFalse(app.buttons["finish-editing"].exists, "Crown editing should not open a sheet")
        XCTAssertTrue(app.buttons["complete-set"].isHittable)
        app.buttons["complete-set"].tap()
        waitForSet(2)
        XCTAssertEqual(reps.value as? String, "8", "The next set should retain its own target")
        XCTAssertFalse(reps.isSelected, "Advancing must release Crown focus")
        XCTAssertFalse(weight.isSelected)
        XCUIDevice.shared.rotateDigitalCrown(delta: 0.25, velocity: .slow)
        XCTAssertEqual(reps.value as? String, "8")
        XCTAssertEqual(weight.value as? String, "60", "Stray Crown input must not edit the next set")
    }

    // MARK: - Quick Actions

    func testUndoAndPauseDoNotRequireScrolling() {
        startWorkout()
        app.buttons["complete-set"].tap()
        waitForSet(2)
        app.buttons["workout-actions"].tap()
        let undo = app.buttons["undo-last-set"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        XCTAssertTrue(undo.isHittable)
        undo.tap()
        waitForSet(1)

        app.buttons["workout-actions"].tap()
        let pause = app.buttons["toggle-pause"]
        XCTAssertTrue(pause.waitForExistence(timeout: 5))
        XCTAssertTrue(pause.isHittable)
        pause.tap()
        waitFor(NSPredicate(format: "label == %@", "Resume"), on: app.buttons["toggle-pause"])
        XCTAssertFalse(app.buttons["rep-count"].isEnabled)
        app.buttons["toggle-pause"].tap()
        waitFor(NSPredicate(format: "enabled == true"), on: app.buttons["rep-count"])
    }

    func testTouchEditingAlternativeRemainsAvailable() {
        startWorkout()
        app.buttons["workout-actions"].tap()
        let editReps = app.buttons["edit-reps-with-buttons"]
        XCTAssertTrue(editReps.waitForExistence(timeout: 5))
        if !editReps.isHittable { app.swipeUp() }
        editReps.tap()
        let increase = app.buttons["increase-reps"]
        XCTAssertTrue(increase.waitForExistence(timeout: 5))
        increase.tap()
        app.buttons["finish-editing"].tap()
        waitFor(NSPredicate(format: "value == %@", "9"), on: app.buttons["rep-count"])
        XCTAssertTrue(app.buttons["complete-set"].isHittable)
    }

    // MARK: - Accessibility Layout

    func testValuesRemainFullyVisibleAboveActions() {
        startWorkout()
        assertFullyVisibleAboveActions(app.buttons["rep-count"])
        assertFullyVisibleAboveActions(app.buttons["weight-value"])
        app.buttons["rep-count"].tap()
        assertFullyVisibleAboveActions(app.buttons["rep-count"])
        app.buttons["complete-set"].tap()
        waitForSet(2)
        let title = app.staticTexts["current-exercise"]
        let context = app.descendants(matching: .any).matching(identifier: "current-set").firstMatch
        XCTAssertLessThanOrEqual(title.frame.height, 22, "Bench Press should fit on one line")
        XCTAssertGreaterThanOrEqual(context.frame.minY, title.frame.maxY)
        XCTAssertLessThanOrEqual(context.frame.height, 22, "Set and countdown must remain on one line")
        XCTAssertLessThanOrEqual(context.frame.maxY, app.buttons["rep-count"].frame.minY)
        assertFullyVisibleAboveActions(app.buttons["rep-count"])
        assertFullyVisibleAboveActions(app.buttons["weight-value"])
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testLongExerciseNameKeepsItsOwnRow() {
        startWorkout(workoutName: "Leg Day")
        for _ in 0..<3 { app.buttons["complete-set"].tap() }
        let title = app.staticTexts["current-exercise"]
        waitFor(NSPredicate(format: "label == %@", "Romanian Deadlift"), on: title)
        XCTAssertLessThanOrEqual(title.frame.height, 44, "Long names may use two complete lines")
        XCTAssertTrue(app.buttons["complete-set"].isHittable)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testLargeTextKeepsPrimaryActionReachable() {
        startWorkout(largeText: true)
        XCTAssertTrue(app.buttons["complete-set"].isHittable)
        XCTAssertTrue(app.buttons["workout-actions"].isHittable)
        app.scrollViews.firstMatch.swipeUp()
        assertFullyVisibleAboveActions(app.buttons["weight-value"])
        XCTAssertTrue(app.buttons["complete-set"].isHittable)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    // MARK: - Helpers

    private func assertFullyVisibleAboveActions(
        _ field: XCUIElement, file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertTrue(field.isHittable, file: file, line: line)
        XCTAssertGreaterThanOrEqual(field.frame.minY, app.frame.minY, file: file, line: line)
        XCTAssertLessThanOrEqual(
            field.frame.maxY + 2, app.buttons["complete-set"].frame.minY,
            "The entire value field and its focus border must clear the action bar", file: file, line: line
        )
    }

    private func startWorkout(largeText: Bool = false, workoutName: String = "Push Day") {
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        if largeText { app.launchArguments.append("UI_TESTING_LARGE_TEXT") }
        app.launch()
        let workout = app.buttons.matching(identifier: "start-workout-\(workoutName)").firstMatch
        if workoutName != "Push Day" {
            XCTAssertTrue(app.buttons.matching(identifier: "start-workout-Push Day").firstMatch
                .waitForExistence(timeout: 10))
            for _ in 0..<5 {
                if workout.exists && workout.isHittable { break }
                app.swipeUp()
            }
        }
        XCTAssertTrue(workout.waitForExistence(timeout: 10))
        workout.tap()
        XCTAssertTrue(app.buttons["complete-set"].waitForExistence(timeout: 5))
    }

    private func waitForSet(_ number: Int) {
        let context = app.descendants(matching: .any).matching(identifier: "current-set").firstMatch
        waitFor(NSPredicate(format: "label CONTAINS %@", "Set \(number) of 3"), on: context)
    }

    private func waitFor(_ predicate: NSPredicate, on element: XCUIElement) {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }
}
