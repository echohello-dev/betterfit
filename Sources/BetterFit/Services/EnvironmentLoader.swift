import Foundation

/// Utility for loading environment variables from .env file or ProcessInfo
public struct EnvironmentLoader {
    /// Get an environment variable with a default value
    /// - Parameters:
    ///   - key: The environment variable key
    ///   - defaultValue: The default value to return if the variable is not set
    /// - Returns: The environment variable value or the default value
    public static func get(_ key: String, default defaultValue: String) -> String {
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        return defaultValue
    }

    /// Get an environment variable without a default
    /// - Parameters:
    ///   - key: The environment variable key
    /// - Returns: The environment variable value or nil if not set
    public static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}
