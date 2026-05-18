import Foundation

/// Stub auth service for testing. Real auth lives in the iOS host app.
@MainActor
public final class AuthService {
    public private(set) var user: Any?
    public private(set) var isAuthenticated = false
    public private(set) var isGuest = true

    public init(supabaseURL: URL, supabaseAnonKey: String) {}

    public func restoreSession() async {
        // Stub — no real session
    }

    public func continueAsGuest() {
        user = nil
        isAuthenticated = false
        isGuest = true
    }
}
