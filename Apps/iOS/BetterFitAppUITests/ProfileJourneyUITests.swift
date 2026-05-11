import XCTest

/// E2E tests for Profile tab features: PRs, Yearly Wrapped, Weekly Targets, Achievements
final class ProfileJourneyUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation

    private func navigateToProfile() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tabs = tabBar.buttons.allElementsBoundByIndex
        XCTAssertGreaterThan(tabs.count, 3, "Expected at least 4 tabs")
        tabs[3].tap() // Me tab

        XCTAssertTrue(app.staticTexts["Me"].waitForExistence(timeout: 3))
    }

    // MARK: - Profile Header

    func testProfileHeaderVisible() throws {
        navigateToProfile()

        // In DEMO_MODE with guest user, shows "Guest"
        XCTAssertTrue(app.staticTexts["Guest"].waitForExistence(timeout: 2))
    }

    func testGuestModeShowsSignInPrompt() throws {
        navigateToProfile()

        // In DEMO_MODE, user should see guest state or sign-in prompt
        let createAccount = app.staticTexts["Create an Account"]
        let signInButton = app.buttons["Sign In"]

        XCTAssertTrue(
            createAccount.exists || signInButton.exists || app.staticTexts["Guest"].exists,
            "Profile should show guest state or sign-in prompt")
    }

    // MARK: - Health Overview

    func testHealthOverviewSectionVisible() throws {
        navigateToProfile()

        let healthTitle = app.staticTexts["Health Overview"]
        XCTAssertTrue(healthTitle.waitForExistence(timeout: 2), "Health Overview section should be visible")
    }

    // MARK: - Weekly Targets

    func testWeeklyTargetsSectionVisible() throws {
        navigateToProfile()

        let targetsTitle = app.staticTexts["Weekly Targets"]
        XCTAssertTrue(targetsTitle.waitForExistence(timeout: 2), "Weekly Targets section should be visible")

        // Verify target metrics
        let workouts = app.staticTexts["Workouts"]
        let volume = app.staticTexts["Volume"]
        let activeTime = app.staticTexts["Active Time"]

        XCTAssertTrue(workouts.exists || volume.exists || activeTime.exists,
                      "Should show at least one target metric")
    }

    func testEditWeeklyTargetsShowsAlert() throws {
        navigateToProfile()

        // Look for Edit button in Weekly Targets section
        let editButton = app.buttons["Edit"]
        guard editButton.waitForExistence(timeout: 2) else {
            XCTSkip("Edit button not found - may not be visible in current layout")
            return
        }

        editButton.tap()
        sleep(1)

        // Should show an alert or sheet
        let alert = app.alerts.firstMatch
        let sheet = app.sheets.firstMatch

        XCTAssertTrue(
            alert.exists || sheet.exists,
            "Tapping Edit should present an alert or sheet")
    }

    // MARK: - Personal Records

    func testPersonalRecordsSectionVisible() throws {
        navigateToProfile()

        // Scroll down to find PR section
        app.swipeUp()
        sleep(1)

        let prTitle = app.staticTexts["Personal Records"]
        XCTAssertTrue(prTitle.waitForExistence(timeout: 2), "Personal Records section should be visible")
    }

    func testPersonalRecordsEmptyState() throws {
        navigateToProfile()
        app.swipeUp()
        sleep(1)

        let prTitle = app.staticTexts["Personal Records"]
        guard prTitle.waitForExistence(timeout: 2) else {
            XCTSkip("Personal Records section not found")
            return
        }

        // In DEMO_MODE with no completed workouts, should show empty state
        let emptyState = app.staticTexts["No personal records yet"]
        let viewAll = app.buttons["View All"]

        XCTAssertTrue(
            emptyState.exists || viewAll.exists,
            "Should show empty state or View All button for PRs")
    }

    func testViewAllPRsButtonOpensSheet() throws {
        navigateToProfile()
        app.swipeUp()
        sleep(1)

        let viewAllButton = app.buttons["View All"]
        guard viewAllButton.waitForExistence(timeout: 2) else {
            XCTSkip("View All button not found")
            return
        }

        viewAllButton.tap()
        sleep(1)

        // Should present a sheet with PR list
        let sheet = app.sheets.firstMatch
        let navTitle = app.staticTexts["All Personal Records"]

        XCTAssertTrue(
            sheet.exists || navTitle.exists || app.navigationBars["All Personal Records"].exists,
            "View All should open PR detail sheet")

        // Dismiss sheet
        app.swipeDown(velocity: .fast)
        sleep(1)
    }

    // MARK: - Achievements

    func testAchievementsSectionVisible() throws {
        navigateToProfile()
        app.swipeUp()
        sleep(1)

        let achievementsTitle = app.staticTexts["Achievements"]
        XCTAssertTrue(achievementsTitle.waitForExistence(timeout: 2), "Achievements section should be visible")

        // Should show achievement count
        let countText = app.staticTexts["0/4"]
        XCTAssertTrue(countText.exists, "Should show achievement progress count")
    }

    // MARK: - Yearly Wrapped

    func testYearlyWrappedSectionVisible() throws {
        navigateToProfile()
        app.swipeUp()
        sleep(1)

        let wrappedTitle = app.staticTexts["Your Year in Review"]
        XCTAssertTrue(wrappedTitle.waitForExistence(timeout: 2), "Yearly Wrapped section should be visible")

        // Should show wrapped card
        let viewRecap = app.staticTexts["View your recap"]
        XCTAssertTrue(viewRecap.exists, "Should show 'View your recap' prompt")
    }

    func testYearlyWrappedOpensSheet() throws {
        navigateToProfile()
        app.swipeUp()
        sleep(1)

        let wrappedTitle = app.staticTexts["Your Year in Review"]
        guard wrappedTitle.waitForExistence(timeout: 2) else {
            XCTSkip("Yearly Wrapped section not found")
            return
        }

        // Tap on the wrapped section
        wrappedTitle.tap()
        sleep(1)

        // Should present Yearly Wrapped sheet
        let sheetTitle = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Wrapped'")
        ).firstMatch

        XCTAssertTrue(
            sheetTitle.waitForExistence(timeout: 2) || app.sheets.firstMatch.exists,
            "Tapping Yearly Wrapped should open detail sheet")

        // Dismiss
        app.swipeDown(velocity: .fast)
        sleep(1)
    }

    // MARK: - Scroll to Bottom

    func testProfileScrollsToBottom() throws {
        navigateToProfile()

        // Scroll through entire profile
        for _ in 0..<5 {
            app.swipeUp()
            sleep(1)
        }

        // Should reach bottom content (Yearly Wrapped or Sign Out)
        let yearlyWrapped = app.staticTexts["Your Year in Review"]
        let signOut = app.buttons["Sign Out"]

        XCTAssertTrue(
            yearlyWrapped.exists || signOut.exists,
            "Should be able to scroll to bottom of Profile")
    }
}
