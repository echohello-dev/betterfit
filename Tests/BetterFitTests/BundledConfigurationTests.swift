import Testing
import BetterFit

struct BundledConfigurationTests {
    @Test
    func guestBuildIgnoresEnvironmentAndBundledCredentials() {
        let config = AppConfiguration(
            environment: ["SUPABASE_URL": "http://localhost:54321", "SUPABASE_ANON_KEY": "local-key"],
            bundleInfo: [
                "BetterFitBackend": "guest", "SUPABASE_URL": "https://example.supabase.co",
                "SUPABASE_ANON_KEY": "bundled-key"
            ]
        )

        #expect(!config.isSupabaseConfigured)
        #expect(config.supabaseURL == nil)
        #expect(config.supabaseAnonKey == nil)
        #expect(config.isValid)
    }

    @Test
    func cloudBuildUsesBundledPublicValuesWithoutLaunchEnvironment() {
        let config = AppConfiguration(environment: [:], bundleInfo: cloudInfo)

        #expect(config.isSupabaseConfigured)
        #expect(config.supabaseURL?.host == "example.supabase.co")
        #expect(config.supabaseAnonKey == "bundled-public-key")
    }

    @Test
    func cloudBuildCannotBeOverriddenByDevelopmentEnvironment() {
        let config = AppConfiguration(
            environment: ["SUPABASE_URL": "http://localhost:54321", "SUPABASE_ANON_KEY": "local-key"],
            bundleInfo: cloudInfo
        )

        #expect(config.isSupabaseConfigured)
        #expect(config.supabaseURL?.host == "example.supabase.co")
        #expect(config.supabaseAnonKey == "bundled-public-key")
    }

    @Test
    func incompleteCloudBuildDoesNotFallBackToEnvironment() {
        let config = AppConfiguration(
            environment: ["SUPABASE_URL": "https://example.supabase.co", "SUPABASE_ANON_KEY": "key"],
            bundleInfo: ["BetterFitBackend": "supabase"]
        )

        #expect(!config.isSupabaseConfigured)
        #expect(!config.isValid)
    }

    @Test
    func unknownBackendDisablesCloudFeatures() {
        var info = cloudInfo
        info["BetterFitBackend"] = "unknown"
        let config = AppConfiguration(environment: [:], bundleInfo: info)

        #expect(!config.isSupabaseConfigured)
        #expect(!config.isValid)
    }

    private var cloudInfo: [String: String] {
        [
            "BetterFitBackend": "supabase", "SUPABASE_URL": "https://example.supabase.co",
            "SUPABASE_ANON_KEY": "bundled-public-key"
        ]
    }
}
