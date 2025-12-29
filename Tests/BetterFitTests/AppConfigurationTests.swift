import XCTest

@testable import BetterFit

final class AppConfigurationTests: XCTestCase {

    // MARK: - Helper Methods

    /// Temporarily set an environment variable for testing
    private func setEnvVar(_ key: String, _ value: String) {
        setenv(key.cString(using: .utf8), value.cString(using: .utf8), 1)
    }

    /// Temporarily unset an environment variable for testing
    private func unsetEnvVar(_ key: String) {
        unsetenv(key.cString(using: .utf8))
    }

    override func setUp() {
        super.setUp()
        // Clear any existing env vars before each test
        unsetEnvVar("SUPABASE_URL")
        unsetEnvVar("SUPABASE_ANON_KEY")
    }

    // MARK: - Tests: Missing Credentials

    func testConfigurationMissingBothEnvVars() {
        // When both env vars are missing
        let config = AppConfiguration()

        // Should not be configured
        XCTAssertFalse(config.isSupabaseConfigured)

        // Should have warnings
        XCTAssertFalse(config.warnings.isEmpty)
        XCTAssertGreaterThan(config.warnings.count, 0)

        // Primary warning should mention guest mode
        let primaryWarning = config.primaryWarning ?? ""
        XCTAssertTrue(primaryWarning.contains("guest mode"))
    }

    func testConfigurationMissingAnonKey() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        // SUPABASE_ANON_KEY is missing

        let config = AppConfiguration()

        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    func testConfigurationMissingUrl() {
        setEnvVar("SUPABASE_ANON_KEY", "valid-anon-key-123")
        // SUPABASE_URL is missing

        let config = AppConfiguration()

        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    // MARK: - Tests: Placeholder Values (Development Defaults)

    func testConfigurationWithPlaceholderUrl() {
        setEnvVar("SUPABASE_URL", "https://your-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "valid-anon-key-123")

        let config = AppConfiguration()

        // Should not be configured because URL contains "your-project"
        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    func testConfigurationWithPlaceholderAnonKey() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "your-anon-key")

        let config = AppConfiguration()

        // Should not be configured because key is placeholder
        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    // MARK: - Tests: Valid Configuration

    func testConfigurationWithValidEnvVars() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")

        let config = AppConfiguration()

        // Should be configured
        XCTAssertTrue(config.isSupabaseConfigured)

        // Should have no warnings
        XCTAssertTrue(config.warnings.isEmpty)
        XCTAssertNil(config.primaryWarning)

        // URLs should be valid
        XCTAssertNotNil(config.supabaseURL)
        XCTAssertEqual(config.supabaseURL?.host, "my-project.supabase.co")
    }

    // MARK: - Tests: Helper Methods

    func testGetSupabaseUrlWithValidConfig() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "valid-key-123")

        let config = AppConfiguration()
        let url = config.getSupabaseURL()

        // Should return the configured URL
        XCTAssertEqual(url.host, "my-project.supabase.co")
        XCTAssertNotEqual(url.host, "placeholder.supabase.co")
    }

    func testGetSupabaseUrlWithMissingConfig() {
        let config = AppConfiguration()
        let url = config.getSupabaseURL()

        // Should return placeholder URL
        XCTAssertEqual(url.host, "placeholder.supabase.co")
    }

    func testGetSupabaseAnonKeyWithValidConfig() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "my-real-anon-key-xyz")

        let config = AppConfiguration()
        let key = config.getSupabaseAnonKey()

        // Should return the configured key
        XCTAssertEqual(key, "my-real-anon-key-xyz")
        XCTAssertNotEqual(key, "placeholder-anon-key")
    }

    func testGetSupabaseAnonKeyWithMissingConfig() {
        let config = AppConfiguration()
        let key = config.getSupabaseAnonKey()

        // Should return placeholder key
        XCTAssertEqual(key, "placeholder-anon-key")
    }

    // MARK: - Tests: Invalid URL Handling

    func testConfigurationWithInvalidUrl() {
        setEnvVar("SUPABASE_URL", "ht!tp://not a valid url!!!!")
        setEnvVar("SUPABASE_ANON_KEY", "valid-key-123")

        let config = AppConfiguration()

        // Should not be configured because URL can't be parsed
        XCTAssertFalse(config.isSupabaseConfigured)

        // Should have warning about invalid URL
        XCTAssertFalse(config.warnings.isEmpty)
        let warnings = config.warnings.joined(separator: " ")
        XCTAssertTrue(warnings.contains("Invalid"))
    }

    // MARK: - Tests: Empty String Handling

    func testConfigurationWithEmptyUrlString() {
        setEnvVar("SUPABASE_URL", "")
        setEnvVar("SUPABASE_ANON_KEY", "valid-key-123")

        let config = AppConfiguration()

        // Should not be configured
        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    func testConfigurationWithEmptyAnonKeyString() {
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "")

        let config = AppConfiguration()

        // Should not be configured
        XCTAssertFalse(config.isSupabaseConfigured)
        XCTAssertFalse(config.warnings.isEmpty)
    }

    // MARK: - Tests: Display Warnings

    func testDisplayWarnings() {
        unsetEnvVar("SUPABASE_URL")
        unsetEnvVar("SUPABASE_ANON_KEY")

        let config = AppConfiguration()
        let displayWarnings = config.displayWarnings

        // Should return non-empty string with warnings
        XCTAssertFalse(displayWarnings.isEmpty)
        XCTAssertTrue(
            displayWarnings.contains("guest mode") || displayWarnings.contains("Supabase"))
    }

    func testIsValidFlag() {
        // When not configured, should not be valid
        let configMissing = AppConfiguration()
        XCTAssertFalse(configMissing.isValid)

        // When configured, should be valid
        setEnvVar("SUPABASE_URL", "https://my-project.supabase.co")
        setEnvVar("SUPABASE_ANON_KEY", "valid-key-123")
        let configValid = AppConfiguration()
        XCTAssertTrue(configValid.isValid)
    }
}
