# Authentication Setup

BetterFit supports three authentication methods:

## 1. Apple Sign In (Recommended for iOS)

**Setup required:**
- Enabled by default in Supabase
- Configure in Xcode: Signing & Capabilities > Sign in with Apple
- Add bundle ID to Apple Developer Portal

**In app:**
- Tap "Sign in with Apple"
- Approve with Face ID / Touch ID
- Account created automatically

## 2. Google OAuth

**Setup required:**
1. Create OAuth 2.0 credentials at [Google Cloud Console](https://console.cloud.google.com)
2. Enable Google provider in Supabase Dashboard > Authentication > Providers > Google
3. Add OAuth Client ID and Secret
4. Configure redirect URI: `betterfit://auth/callback`

**In app:**
- Tap "Sign in with Google"
- Opens browser for Google login
- Redirected back to app after authentication

**Note:** Currently shows email/password form as fallback while OAuth redirect handling is configured.

## 3. Email & Password

**Setup required:**
- Enabled by default in Supabase
- Optional: Configure email verification in Supabase Dashboard

**In app:**
- Tap "Sign in with Email"
- Enter email and password
- Toggle between "Sign In" and "Create Account"
- For new accounts: password must be at least 6 characters

**Optional email verification:**
- In Supabase Dashboard > Authentication > Email Templates
- Configure confirmation email template
- Users must verify email before accessing app

## Guest Mode (No Setup)

- Tap "Continue as Guest"
- Works completely offline
- Data stored locally (UserDefaults)
- No authentication required

## Supabase Configuration

### Enable Providers

Dashboard > Authentication > Providers

1. **Apple** - Usually enabled by default
2. **Google** - Requires OAuth credentials
3. **Email** - Enabled by default, optional verification

### Set Up Redirect URLs

For OAuth providers, configure in Supabase > Authentication > URL Configuration:

```
Allowed Redirect URLs:
- betterfit://auth/callback
- http://localhost:3000/auth/callback  (for testing)
```

### Optional: Email Verification

Dashboard > Authentication > Email Templates

- Enable "Confirm signup" template
- Users receive verification email
- Must click link before account is active

## Testing Locally

### Quick Start: Local Supabase + iOS Simulator

**1. Start local Supabase (one-time setup per session):**
```bash
mise run supabase:start
```
This starts PostgreSQL, Auth, Storage, and Studio locally. Services run in Docker.

**2. Populate .env with credentials:**
```bash
mise run supabase:env
```
Automatically extracts live credentials from `supabase status` and writes to `.env`:
- `SUPABASE_URL=http://127.0.0.1:54321`
- `SUPABASE_ANON_KEY=sb_publishable_...` (from local instance)

**3. Build and run the app:**
```bash
mise run ios:open      # Opens Xcode with fresh project generation + credential injection
mise run ios:build:dev # Builds for simulator
```

The setup process automatically:
- Runs `scripts/update_scheme_env.sh` after project generation
- Injects `.env` variables into Xcode scheme configuration
- Xcode provides `SUPABASE_URL` and `SUPABASE_ANON_KEY` at runtime
- `AppConfiguration` reads these via `ProcessInfo.processInfo.environment`

**In the simulator:**
- ✅ Email/password authentication works immediately
- ✅ Guest mode (offline) works immediately
- ✅ Apple Sign In works (configured by default)
- ⚠️ Google OAuth requires additional setup (see below)

**Access local Supabase services:**
- **Studio (web UI):** http://127.0.0.1:54323 - Browse database, manage auth, view storage
- **API:** http://127.0.0.1:54321 - Direct API calls
- **Mailpit (email testing):** http://127.0.0.1:54324 - View emails sent by auth system

**Stop when done:**
```bash
mise run supabase:stop
```

### With Local Supabase

For quick testing, you can also start Supabase without populating .env (app runs in guest-only mode):

```bash
mise run supabase:start
# Email/password auth works immediately after setting .env
# Google OAuth requires browser redirect (can test with email fallback)
```

### With Production Supabase

For cloud testing, use credentials from Dashboard > Settings > API:

```bash
# Update .env with production credentials:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

All auth methods work immediately.

## Code Integration

### AuthService (Sources/BetterFit/Services/Auth/AuthService.swift)

```swift
// Apple Sign In
try await authService.signInWithApple(idToken: token, nonce: nonce)

// Google OAuth
try await authService.signInWithGoogle()

// Email & Password Sign In
try await authService.signInWithEmail(email: email, password: password)

// Email & Password Sign Up
try await authService.signUpWithEmail(email: email, password: password)

// Guest Mode
authService.continueAsGuest()

// Sign Out
try await authService.signOut()
```

### SignInView (Apps/iOS/BetterFitApp/Features/Auth/SignInView.swift)

Provides UI for all three auth methods:
- Native Apple Sign In button
- Google OAuth button (with email fallback)
- Email/Password form with sign-up toggle
- Guest mode button

## Troubleshooting

### "Sign in failed" with email/password

1. **Invalid email format** - Check for `@` symbol
2. **Short password** - Minimum 6 characters for new accounts
3. **Email already exists** - Use different email or sign in instead
4. **Supabase down** - Check Dashboard > Status page

### Apple Sign In not working

1. Check Xcode: Signing & Capabilities > Sign in with Apple enabled
2. Verify bundle ID matches Apple Developer portal
3. Check local Supabase is running (`mise run supabase:status`)

### Google OAuth not working

1. Verify credentials in Supabase > Google provider settings
2. Check redirect URL configured in Google Cloud Console and Supabase
3. Test browser redirect: `betterfit://auth/callback` registered in Info.plist

### User can't verify email

1. Check local Supabase email testing: http://127.0.0.1:54324 (Inbucket)
2. For production: Check email spam folder or resend verification
3. Verify email templates configured in Supabase dashboard

## Security Notes

- **Passwords:** Transmitted over HTTPS, hashed in Supabase
- **Apple Sign In:** Uses nonce-based verification, secure by default
- **Google OAuth:** Handled by Supabase, never see user password
- **Local Supabase:** All auth works offline, suitable for development
- **Production:** Enable email verification and configure HTTPS only

## Next Steps

1. Choose auth method(s) to enable
2. Configure in Supabase dashboard
3. Test in simulator (`mise run ios:open`)
4. Users can sign in and data syncs to Supabase
