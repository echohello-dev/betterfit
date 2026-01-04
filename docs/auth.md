# Authentication Setup

Guide for implementing Apple Sign In, Google OAuth, and email/password authentication with Supabase in iOS apps.

## Apple Sign In

### Prerequisites

- Active Apple Developer Account
- App ID with Sign in with Apple capability
- Supabase project

### Setup Steps

**1. Enable in Apple Developer Portal**

- Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account)
- Select your App ID (e.g., `com.yourcompany.yourapp`)
- Enable **Sign in with Apple**
- Save changes

**2. Configure Xcode**

- Open your project
- Target → **Signing & Capabilities** → **+ Capability**
- Add **Sign in with Apple**
- Verify `.entitlements` includes `com.apple.developer.applesignin`

**3. Supabase Configuration**

For iOS-only apps, no Supabase setup needed—native authentication uses `signInWithIdToken` directly.

For web or cross-platform, configure Apple OAuth:

**Create Service ID** (Apple Developer Portal):

- Identifiers → **+** → **Services IDs**
- Description: `Your App Web Auth`
- Identifier: `com.yourcompany.yourapp.web`
- Enable **Sign in with Apple** → Configure
- Primary App ID: Select your app ID
- Website URL: `your-project-ref.supabase.co`
- Return URLs: `https://your-project-ref.supabase.co/auth/v1/callback`
- Save and register

**Configure Supabase**:

- [Supabase Dashboard](https://supabase.com/dashboard) → Authentication → Apple
- Enable provider
- Client IDs: `com.yourcompany.yourapp.web`

**Generate Secret Key** (JWT):

Create key in Apple Developer Portal:

- Keys → **+** → Name: `Your App Apple Sign In Key`
- Enable **Sign in with Apple** → Configure → Select your app ID
- Download `.p8` file (once only!)
- Note **Key ID** and **Team ID**

Generate JWT:

```bash
brew install mike-engel/jwt-cli/jwt-cli
jwt encode --alg ES256 --kid "YOUR_KEY_ID" --iss "YOUR_TEAM_ID" --exp "+180d" \
  --aud "https://appleid.apple.com" --sub "com.yourcompany.yourapp.web" \
  --secret @path/to/AuthKey_KEYID.p8
```

Paste JWT in Supabase **Secret Key** field. ⚠️ Expires every 6 months.

## Google OAuth

### Setup Steps

**1. Create OAuth Client** ([Google Cloud Console](https://console.cloud.google.com))

- APIs & Services → Credentials → **+ CREATE CREDENTIALS** → OAuth client ID
- Type: **Web application** (required for Supabase)
- Name: `Your App Web OAuth`
- Authorized redirect URIs: `https://your-project-ref.supabase.co/auth/v1/callback`
- Save and note **Client ID** and **Client Secret**

**2. Configure OAuth Consent Screen**

- APIs & Services → OAuth consent screen
- Type: **External** (or Internal for G Suite)
- App name, support email, developer contact
- Scopes: `email`, `profile`, `openid`

**3. Configure Supabase**

- Authentication → Providers → Google
- Enable provider
- Enter **Client ID** and **Client Secret**
- Save

**4. Add App Redirect URL**

- Authentication → URL Configuration → Redirect URLs
- Add: `yourapp://auth/callback` (replace `yourapp` with your URL scheme)

**5. Configure iOS App**

Add URL scheme to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

Handle redirects in `AppDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    NotificationCenter.default.post(name: .authCallbackReceived, object: url)
    return true
}
```

## Email & Password

Enabled by default in Supabase. Optionally configure email verification:

- Dashboard → Authentication → Email Templates
- Customize confirmation email
- Require verification before access

## Local Development

```bash
supabase start
supabase status  # Get API URL and anon key
```

Configure app with local credentials:

```swift
let supabaseURL = URL(string: "http://127.0.0.1:54321")!
let supabaseKey = "your-anon-key"
```

**Services:**

- Studio: http://127.0.0.1:54323
- API: http://127.0.0.1:54321
- Email: http://127.0.0.1:54324

**Testing:**

- ✅ Email/password works immediately
- ✅ Apple Sign In (requires Apple Developer setup)
- ⚠️ Google OAuth (requires Cloud Console setup)

Test URL scheme:

```bash
xcrun simctl openurl booted "yourapp://auth/callback?test=1"
```

## Code Implementation

### AuthService

```swift
import Supabase
import AuthenticationServices

class AuthService: ObservableObject {
    @Published var currentUser: User?
    private let supabaseClient: SupabaseClient
    
    init(supabaseURL: URL, supabaseKey: String) {
        self.supabaseClient = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthCallback), name: .authCallbackReceived, object: nil)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await supabaseClient.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        currentUser = session.user
    }
    
    func signInWithGoogle() async throws {
        let url = try await supabaseClient.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "yourapp://auth/callback")
        )
        await MainActor.run { UIApplication.shared.open(url) }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        let session = try await supabaseClient.auth.signIn(email: email, password: password)
        currentUser = session.user
    }
    
    @objc private func handleAuthCallback(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
        Task { try await handleOAuthCallback(url: url) }
    }
    
    func handleOAuthCallback(url: URL) async throws {
        currentUser = try await supabaseClient.auth.session(from: url).user
    }
    
    func signOut() async throws {
        try await supabaseClient.auth.signOut()
        currentUser = nil
    }
}

extension Notification.Name {
    static let authCallbackReceived = Notification.Name("authCallbackReceived")
}
```

### Sign In UI

```swift
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { handleAppleSignIn($0) }
            .frame(height: 50)
            
            Button("Sign in with Google") {
                Task { try await authService.signInWithGoogle() }
            }
            
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            Button("Sign In") {
                Task { try await authService.signInWithEmail(email: email, password: password) }
            }
        }
        .padding()
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        guard case .success(let auth) = result,
              let cred = auth.credential as? ASAuthorizationAppleIDCredential,
              let token = cred.identityToken.flatMap({ String(data: $0, encoding: .utf8) })
        else { return }
        Task { try await authService.signInWithApple(idToken: token, nonce: "NONCE") }
    }
}
```

## Troubleshooting

**Redirect URI mismatch:**

- Verify `yourapp://auth/callback` in Supabase URL Configuration
- Verify Supabase callback in Google Cloud authorized URIs

**OAuth doesn't redirect back:**

- Check `CFBundleURLSchemes` includes your URL scheme
- Verify `AppDelegate` connected via `@UIApplicationDelegateAdaptor`
- Test: `xcrun simctl openurl booted yourapp://test`

**Invalid client error:**

- Confirm Client ID/Secret match in Supabase and Cloud Console
- Google OAuth requires **Web application** client type, not iOS
- Check OAuth consent screen is published

**Apple Sign In fails:**

- Verify Sign in with Apple capability enabled in Xcode
- Bundle ID must match Apple Developer Portal
- For native iOS, no Supabase Apple provider setup needed
