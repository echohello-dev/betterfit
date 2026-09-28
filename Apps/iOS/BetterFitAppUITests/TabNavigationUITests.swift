import XCTest

/// E2E tests for core tab navigation and Start workout button behavior
final class TabNavigationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]

        // Intercept system permission dialogs
        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }

        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation

    func testAllTabsAccessible() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should appear")

        let tabs = tabBar.buttons.allElementsBoundByIndex
        XCTAssertEqual(tabs.count, 4, "Expected 4 tabs: Workout, Body, Targets, Log")

        // Tab through each one and verify its distinct content
        for (title, marker) in tabMarkers {
            let tab = tabBar.buttons[title]
            XCTAssertTrue(tab.waitForExistence(timeout: 2), "\(title) tab should exist")
            tab.tap()

            XCTAssertTrue(
                app.staticTexts.matching(
                    NSPredicate(format: "label CONTAINS[c] %@", marker)
                ).firstMatch.waitForExistence(timeout: 3),
                "\(title) tab should show \(marker)")
        }
    }

    func testStartWorkoutButtonOnlyVisibleOnWorkoutTab() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for (title, marker) in tabMarkers {
            tabBar.buttons[title].tap()

            // Wait for the tab's content so the negative check is meaningful.
            XCTAssertTrue(
                app.staticTexts.matching(
                    NSPredicate(format: "label CONTAINS[c] %@", marker)
                ).firstMatch.waitForExistence(timeout: 3),
                "\(title) tab content should load")

            let startButton = app.buttons["Start workout"]
            if title == "Workout" {
                XCTAssertTrue(
                    startButton.waitForExistence(timeout: 2),
                    "Start workout should be visible on the Workout tab")
            } else {
                XCTAssertFalse(
                    startButton.exists,
                    "Start workout should not cover content on the \(title) tab")
            }
        }
    }

    func testStartWorkoutButtonDoesNotOverlapContent() throws {
        // Scrollable content lives on the Targets tab (the old Me tab is gone).
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Targets"].tap()

        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'Weekly targets'")
            ).firstMatch.waitForExistence(timeout: 3),
            "Targets tab should load")
        XCTAssertFalse(app.buttons["Start workout"].exists)

        // Verify key sections exist and are tappable.
        let weeklyTargets = app.staticTexts["Workouts"]
        if weeklyTargets.waitForExistence(timeout: 2) {
            // If visible, it should be hittable (not covered by button)
            XCTAssertTrue(weeklyTargets.isHittable, "Weekly target rows should be accessible")
        }

        // Scroll down and verify bottom content is accessible
        app.swipeUp()

        let records = app.staticTexts["Keep training"]
        if records.waitForExistence(timeout: 2) {
            XCTAssertTrue(records.isHittable, "Records row should be accessible after scrolling")
        }
    }

    // MARK: - Active Workout State

    func testStartWorkoutTransitionsToActiveState() throws {
        let startButton = app.buttons["Start workout"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        startButton.tap()

        // The active session embeds in the Workout tab (Plan → Workout mode).
        let firstExercise = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Exercise 01'")
        ).firstMatch
        let finishButton = app.buttons["Finish workout"]
        XCTAssertTrue(
            firstExercise.waitForExistence(timeout: 5) || finishButton.waitForExistence(timeout: 2),
            "Should transition to the active session after tapping Start workout")
    }

    // MARK: - Helper Methods

    /// Distinct content per tab, keyed by the tab title (`AppTab.title`).
    private var tabMarkers: [(title: String, marker: String)] {
        [
            ("Workout", "The work"),
            ("Body", "Overall recovery"),
            ("Targets", "Weekly targets"),
            ("Log", "26 weeks"),
        ]
    }
}
