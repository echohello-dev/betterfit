import XCTest

final class GuestStartupUITests: XCTestCase {
    func testNormalLaunchWithoutBackendReachesGuestTabs() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = []
        app.launchEnvironment = ["SUPABASE_URL": "", "SUPABASE_ANON_KEY": ""]
        app.launch()
        defer { app.terminate() }

        let tabs = app.tabBars.firstMatch
        XCTAssertTrue(tabs.waitForExistence(timeout: 10))
        XCTAssertEqual(tabs.buttons.count, 4)
        XCTAssertTrue(tabs.buttons["Workout"].exists)
        XCTAssertTrue(tabs.buttons["Body"].exists)
        XCTAssertTrue(tabs.buttons["Targets"].exists)
        XCTAssertTrue(tabs.buttons["Log"].exists)
    }
}
