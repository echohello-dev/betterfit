import XCTest

/// E2E tests for core tab navigation and Start Workout button behavior
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
        XCTAssertEqual(tabs.count, 4, "Expected 4 tabs: Workout, Plan, Search, Me")

        // Tab through each one
        for (index, tab) in tabs.enumerated() {
            tab.tap()
            sleep(1)

            // Verify each tab has distinct content
            switch index {
            case 0:
                XCTAssertTrue(app.staticTexts["Up Next"].waitForExistence(timeout: 2))
            case 1:
                XCTAssertTrue(app.staticTexts["Plan"].waitForExistence(timeout: 2))
            case 2:
                XCTAssertTrue(app.staticTexts["Categories"].waitForExistence(timeout: 2))
            case 3:
                XCTAssertTrue(app.staticTexts["Me"].waitForExistence(timeout: 2))
            default:
                break
            }
        }
    }

    func testStartWorkoutButtonVisibleOnAllTabs() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tabs = tabBar.buttons.allElementsBoundByIndex

        for tab in tabs {
            tab.tap()
            sleep(1)

            // Start Workout button should be visible on every tab when no active workout
            let startButton = app.buttons["Start Workout"]
            XCTAssertTrue(
                startButton.waitForExistence(timeout: 2),
                "Start Workout button should be visible on \(tab.label) tab")
        }
    }

    func testStartWorkoutButtonDoesNotOverlapContent() throws {
        // Navigate to Me tab where scrollable content exists
        let tabs = app.tabBars.buttons.allElementsBoundByIndex
        tabs[3].tap() // Me tab

        XCTAssertTrue(app.staticTexts["Me"].waitForExistence(timeout: 3))

        // Verify key sections exist and are tappable (not obscured by button)
        let weeklyTargets = app.staticTexts["Weekly Targets"]
        if weeklyTargets.waitForExistence(timeout: 2) {
            // If visible, it should be hittable (not covered by button)
            XCTAssertTrue(weeklyTargets.isHittable, "Weekly Targets should not be obscured by Start Workout button")
        }

        // Scroll down and verify bottom content is accessible
        app.swipeUp()
        sleep(1)

        let achievements = app.staticTexts["Achievements"]
        if achievements.exists {
            XCTAssertTrue(achievements.isHittable, "Achievements should be accessible after scrolling")
        }
    }

    // MARK: - Active Workout State

    func testStartWorkoutTransitionsToActiveState() throws {
        let startButton = app.buttons["Start Workout"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        startButton.tap()
        sleep(2)

        // After starting, should see either active workout controls or the workout sheet
        let pauseButton = app.buttons["Pause Workout"]
        let resumeButton = app.buttons["Resume Workout"]
        let stopButton = app.buttons["Stop Workout"]

        XCTAssertTrue(
            pauseButton.exists || resumeButton.exists || stopButton.exists || app.sheets.firstMatch.exists,
            "Should transition to active workout state after tapping Start Workout")
    }
}
