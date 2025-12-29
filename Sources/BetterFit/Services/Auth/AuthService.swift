import Auth
import Foundation
import Supabase

/// Authentication service using Supabase
/// Manages user authentication state and Apple Sign In
@MainActor
public final class AuthService: ObservableObject {
    @Published public private(set) var user: User?
    @Published public private(set) var isAuthenticated = false
    @Published public private(set) var isGuest = true

    private let supabaseClient: SupabaseClient

    // MARK: - Initialization

    public init(supabaseURL: URL, supabaseAnonKey: String) {
        self.supabaseClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )

        // Restore session if available
        Task {
            await restoreSession()
        }
    }

    // MARK: - Session Management

    /// Restore existing session on app launch
    public func restoreSession() async {
        do {
            let session = try await supabaseClient.auth.session
            self.user = session.user
            self.isAuthenticated = true
            self.isGuest = false
        } catch {
            // No session available - user is guest
            self.user = nil
            self.isAuthenticated = false
            self.isGuest = true
        }
    }

    /// Listen for auth state changes
    public func setupAuthStateListener() {
        Task {
            for await state in supabaseClient.auth.authStateChanges {
                let (event, session) = state
                switch event {
                case .signedIn, .initialSession:
                    self.user = session?.user
                    self.isAuthenticated = session?.user != nil
                    self.isGuest = false

                case .signedOut:
                    self.user = nil
                    self.isAuthenticated = false
                    self.isGuest = true

                case .tokenRefreshed:
                    self.user = session?.user
                    self.isAuthenticated = session?.user != nil

                default:
                    break
                }
            }
        }
    }

    // MARK: - Guest Mode

    /// Continue as guest (no authentication)
    public func continueAsGuest() {
        self.user = nil
        self.isAuthenticated = false
        self.isGuest = true
    }

    // MARK: - Apple Sign In

    /// Sign in with Apple ID Token
    /// - Parameter idToken: Apple ID token from AuthenticationServices
    /// - Returns: User session
    @discardableResult
    public func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let session = try await supabaseClient.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        self.user = session.user
        self.isAuthenticated = true
        self.isGuest = false

        return session.user
    }

    // MARK: - Google OAuth

    /// Sign in with Google OAuth
    /// Note: Requires Google OAuth provider configured in Supabase
    /// See: https://supabase.com/docs/guides/auth/social-login/auth-google
    /// Opens the OAuth flow in the system browser
    public func signInWithGoogle() async throws {
        try await supabaseClient.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "betterfit://auth/callback")
        )
    }

    // MARK: - Email & Password

    /// Sign up with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (minimum 6 characters recommended)
    @discardableResult
    public func signUpWithEmail(email: String, password: String) async throws -> User {
        let session = try await supabaseClient.auth.signUp(
            email: email,
            password: password
        )

        self.user = session.user
        self.isAuthenticated = true
        self.isGuest = false

        return session.user
    }

    /// Sign in with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    @discardableResult
    public func signInWithEmail(email: String, password: String) async throws -> User {
        let session = try await supabaseClient.auth.signIn(
            email: email,
            password: password
        )

        self.user = session.user
        self.isAuthenticated = true
        self.isGuest = false

        return session.user
    }

    // MARK: - Sign Out

    /// Sign out current user and return to guest mode
    public func signOut() async throws {
        try await supabaseClient.auth.signOut()
        self.user = nil
        self.isAuthenticated = false
        self.isGuest = true
    }

    // MARK: - Supabase Client Access

    /// Get Supabase client for direct database access
    /// (Used by SupabasePersistenceService)
    public var client: SupabaseClient {
        return supabaseClient
    }
}
