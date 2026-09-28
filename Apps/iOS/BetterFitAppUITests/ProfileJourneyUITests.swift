import XCTest

/// E2E tests for ProfileView (reached via the Workout tab's "Profile" avatar)
/// and the content that moved to the Body/Targets tabs.
///
/// Navigation is the real user path: Workout tab → top-bar "Profile" button →
/// ProfileView sheet (RootTabView presents it on `showProfile`).
///
/// Permanently removed (feature deleted from the app — do not restore):
/// - testEditWeeklyTargetsShowsAlert — target editing does not exist; the
///   "Edit" button was a deliberate no-op stub (`{}`) and has been deleted.
/// - testViewAllPRsButtonOpensSheet — records are now static rows (Trap bar
///   deadlift / Bench press / Back squat); the "View All" button and the
///   "All Personal Records" sheet are gone.
/// - testYearlyWrappedOpensSheet — the "Your year" card is a static heatmap;
///   the wrapped recap sheet is gone.
///
/// DEMO_MODE note: `onShowSignIn` is an inert `{}` in BetterFitApp, so the
/// guest sign-in test asserts the prompt is DISPLAYED, not that tapping it
/// signs in.
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

    private func navigateToTab(_ title: String) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tab = tabBar.buttons[title]
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "Expected a \(title) tab")
        tab.tap()
    }

    private func navigateToProfileSheet() {
        navigateToTab("Workout")

        let profileButton = app.buttons["Profile"]
        XCTAssertTrue(
            profileButton.waitForExistence(timeout: 5),
            "Workout top bar should show the Profile avatar button")
        profileButton.tap()

        // The sheet animates in; wait for ProfileView's toolbar Close button.
        XCTAssertTrue(
            app.buttons["Close"].waitForExistence(timeout: 5),
            "Tapping the Profile avatar should present the Profile sheet")
    }

    // MARK: - Profile Header

    func testProfileHeaderVisible() throws {
        navigateToProfileSheet()

        // In DEMO_MODE the user is a guest: display name + guest subtitle.
        XCTAssertTrue(
            app.staticTexts["Guest"].waitForExistence(timeout: 3),
            "Profile header should show the 'Guest' display name")
        XCTAssertTrue(
            app.staticTexts["Training as guest"].waitForExistence(timeout: 3),
            "Profile header should show the 'Training as guest' subtitle")
    }

    func testGuestModeShowsSignInPrompt() throws {
        navigateToProfileSheet()

        // DEMO_MODE: `onShowSignIn` is inert, so only assert the prompt is
        // DISPLAYED — do not tap it and expect a sign-in flow.
        let signInPrompt = app.descendants(matching: .any).matching(
            NSPredicate(format: "label == 'Sign in to sync'")
        ).firstMatch
        scrollUntilExists(signInPrompt)
        XCTAssertTrue(
            signInPrompt.waitForExistence(timeout: 3),
            "Guest profile should display the 'Sign in to sync' prompt")
    }

    // MARK: - Achievements

    func testAchievementsSectionVisible() throws {
        navigateToProfileSheet()

        let achievementsTitle = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Achievements'")
        ).firstMatch
        scrollUntilExists(achievementsTitle)
        XCTAssertTrue(
            achievementsTitle.waitForExistence(timeout: 3),
            "Achievements section should be visible on the Profile sheet")

        // Progress count in the section header (2 of the 4 badges are earned).
        let countText = app.staticTexts["2/4"]
        XCTAssertTrue(
            countText.waitForExistence(timeout: 3),
            "Achievements header should show the '2/4' progress count")
    }

    // MARK: - Year in Review

    func testYearlyWrappedSectionVisible() throws {
        navigateToProfileSheet()

        // The old "Your Year in Review" recap is now the static "Your year"
        // heatmap card.
        let yearTitle = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Your year'")
        ).firstMatch
        scrollUntilExists(yearTitle)
        XCTAssertTrue(
            yearTitle.waitForExistence(timeout: 3),
            "'Your year' section should be visible on the Profile sheet")

        let caption = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'workouts logged'")
        ).firstMatch
        XCTAssertTrue(
            caption.waitForExistence(timeout: 3),
            "'Your year' card should show its workouts-logged caption")
    }

    // MARK: - Scroll to Bottom

    func testProfileScrollsToBottom() throws {
        navigateToProfileSheet()

        // Scroll through the entire profile sheet.
        for _ in 0..<5 {
            app.swipeUp()
            sleep(1)
        }

        // Bottom-most content in guest mode: the sign-in prompt, below the
        // "Your year" card.
        let signInPrompt = app.descendants(matching: .any).matching(
            NSPredicate(format: "label == 'Sign in to sync'")
        ).firstMatch
        XCTAssertTrue(
            signInPrompt.waitForExistence(timeout: 3),
            "Should be able to scroll to the bottom of the Profile sheet")
    }

    // MARK: - Settings

    func testSettingsRowOpensSheet() throws {
        navigateToProfileSheet()

        // Toolbar gear opens the SettingsView sheet.
        let gearButton = app.buttons["Settings"]
        XCTAssertTrue(
            gearButton.waitForExistence(timeout: 3),
            "Profile toolbar should show the Settings gear button")
        gearButton.tap()

        let unitsSection = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Units'")
        ).firstMatch
        XCTAssertTrue(
            unitsSection.waitForExistence(timeout: 5),
            "Settings sheet should show the Units section")

        XCTAssertTrue(
            app.staticTexts["Pounds (lb)"].waitForExistence(timeout: 3),
            "Settings sheet should show the 'Pounds (lb)' unit option")
    }

    // MARK: - Health Overview (Body tab)

    func testHealthOverviewSectionVisible() throws {
        // The profile's health overview is now the Body tab's recovery readout.
        navigateToTab("Body")

        let healthTitle = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Overall recovery'")
        ).firstMatch
        XCTAssertTrue(
            healthTitle.waitForExistence(timeout: 3),
            "Health overview should be visible on the Body tab")
    }

    // MARK: - Weekly Targets (Targets tab)

    func testWeeklyTargetsSectionVisible() throws {
        // Weekly targets moved from the profile to the Targets tab.
        navigateToTab("Targets")

        let targetsTitle = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Weekly targets'")
        ).firstMatch
        XCTAssertTrue(
            targetsTitle.waitForExistence(timeout: 3),
            "Weekly targets section should be visible on the Targets tab")

        // Verify target metrics
        let workouts = app.staticTexts["Workouts"]
        let volume = app.staticTexts["Volume"]
        let time = app.staticTexts["Time"]

        XCTAssertTrue(workouts.exists || volume.exists || time.exists,
                      "Should show at least one target metric")
    }

    // MARK: - Personal Records (Targets tab)

    func testPersonalRecordsSectionVisible() throws {
        // Records moved from the profile to the Targets tab.
        navigateToTab("Targets")

        let recordsHeader = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Records this month'")
        ).firstMatch
        scrollUntilExists(recordsHeader)
        XCTAssertTrue(
            recordsHeader.exists,
            "Records section should be visible on the Targets tab")
    }

    func testPersonalRecordsEmptyState() throws {
        navigateToTab("Targets")

        let emptyState = app.staticTexts["Personal records appear here"]
        scrollUntilExists(emptyState)
        XCTAssertTrue(emptyState.exists, "Records row should show its empty-state meta")
    }

    // MARK: - Helper Methods

    private func scrollUntilExists(_ element: XCUIElement, maxSwipes: Int = 8) {
        for _ in 0..<maxSwipes {
            if element.exists { return }
            app.swipeUp()
            sleep(1)
        }
    }
}
