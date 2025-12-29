import Foundation

/// App configuration loaded from environment variables
public struct AppConfiguration {
    // MARK: - Supabase Configuration

    public let supabaseURL: URL?
    public let supabaseAnonKey: String?
    public let isSupabaseConfigured: Bool

    // MARK: - Configuration Status

    public let warnings: [String]
    public var isValid: Bool { warnings.isEmpty }

    // MARK: - Initialization

    public init() {
        // Load environment variables
        let rawSupabaseURL = EnvironmentLoader.get("SUPABASE_URL")
        let supabaseAnonKey = EnvironmentLoader.get("SUPABASE_ANON_KEY")

        self.supabaseAnonKey = supabaseAnonKey

        // Validate Supabase configuration
        var warnings: [String] = []

        let hasSupabaseURL =
            rawSupabaseURL != nil && !rawSupabaseURL!.isEmpty
            && !rawSupabaseURL!.contains("your-project")
        let hasAnonKey =
            supabaseAnonKey != nil && !supabaseAnonKey!.isEmpty
            && supabaseAnonKey != "your-anon-key"

        if !hasSupabaseURL || !hasAnonKey {
            warnings.append(
                "Supabase credentials not configured. App is in guest mode only. Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables to enable cloud features."
            )
        }

        // Try to parse URL if present
        if let rawURL = rawSupabaseURL, hasSupabaseURL {
            self.supabaseURL = URL(string: rawURL)
            if self.supabaseURL == nil {
                warnings.append("Invalid Supabase URL: \(rawURL)")
            }
        } else {
            self.supabaseURL = nil
        }

        self.isSupabaseConfigured = hasSupabaseURL && hasAnonKey && self.supabaseURL != nil
        self.warnings = warnings
    }

    // MARK: - Public Accessors

    /// Get a validated Supabase URL, or a fallback placeholder
    public func getSupabaseURL() -> URL {
        supabaseURL ?? URL(string: "https://placeholder.supabase.co")!
    }

    /// Get the Supabase anonymous key, or a placeholder
    public func getSupabaseAnonKey() -> String {
        supabaseAnonKey ?? "placeholder-anon-key"
    }

    /// Get the primary configuration warning message (if any)
    public var primaryWarning: String? {
        warnings.first
    }

    /// All configuration warnings suitable for display
    public var displayWarnings: String {
        warnings.joined(separator: "\n")
    }
}
