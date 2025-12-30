# Local Development Setup

This guide explains how to set up and run BetterFit locally with Supabase and the iOS simulator.

## Prerequisites

- Xcode 17.0+
- macOS with Docker support (for Supabase containers)
- `mise` installed (see [mise.toml](../mise.toml))
- iOS 26.2 simulator runtime

## Quick Start (5 minutes)

### 1. Install dependencies
```bash
mise install
```
Installs Supabase CLI, SwiftLint, and other build tools.

### 2. Start local Supabase
```bash
mise run supabase:start
```
Starts PostgreSQL, Auth, Storage, and Studio in Docker containers.

**Output includes:**
```
Studio:  http://127.0.0.1:54323
API:     http://127.0.0.1:54321
Mailpit: http://127.0.0.1:54324
```

### 3. Populate .env with credentials
```bash
mise run supabase:env
```
Reads local Supabase credentials and writes to `.env`:
- Extracts from `supabase status` 
- Updates `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SECRET_KEY`
- Skips if `.env` already exists with valid credentials

**What gets set:**
```dotenv
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=sb_publishable_ACJWl...
SUPABASE_SECRET_KEY=sb_secret_N7UND0U...
```

### 4. Build and run the app
```bash
# Generate Xcode project and open it
mise run ios:open

# Or just build for simulator
mise run ios:build:dev
```

The build automatically:
1. Runs `scripts/load_env.sh` as a build phase
2. Sources `.env` file into build environment
3. Passes variables to Xcode build settings
4. App reads via `AppConfiguration` → `EnvironmentLoader` → `ProcessInfo.processInfo.environment`

### 5. Test authentication
In the simulator:
- Tap "Sign in with Email" → enter any email/password (6+ chars for new accounts)
- Tap "Continue as Guest" → offline mode
- Tap "Sign in with Apple" → simulated approval

## How It Works

### Environment Variable Loading

```
.env (git-ignored)
    ↓
scripts/load_env.sh (sourced during build)
    ↓
Xcode build settings (SUPABASE_URL, SUPABASE_ANON_KEY)
    ↓
ProcessInfo.processInfo.environment
    ↓
AppConfiguration.swift (reads via EnvironmentLoader)
    ↓
App initialization (AuthService, BetterFit)
```

### Build Phase

In `Apps/iOS/project.yml`:
```yaml
buildPhases:
  - script:
      script: |
        source "${PROJECT_DIR}/../../scripts/load_env.sh"
        if [ -n "$SUPABASE_URL" ]; then
          echo "✅ Loaded SUPABASE_URL from .env"
        fi
      name: Load Environment Variables
```

Runs **before** app compilation, ensuring env vars are available to the app.

### App Configuration Reading

In `Sources/BetterFit/Services/AppConfiguration.swift`:
```swift
public init() {
    let rawSupabaseURL = EnvironmentLoader.get("SUPABASE_URL")
    let supabaseAnonKey = EnvironmentLoader.get("SUPABASE_ANON_KEY")
    // ... validation
}
```

## Common Tasks

### Check Supabase Status
```bash
mise run supabase:status
```

### View Local Database (Studio)
Open http://127.0.0.1:54323 in browser
- Browse tables, rows, functions
- Manage auth users and tokens
- View storage buckets

### Test Email Authentication (Mailpit)
Open http://127.0.0.1:54324 in browser
- View all emails sent by Supabase auth
- Useful for testing confirmation emails

### Reset Database to Seed State
```bash
mise run supabase:reset
```
Runs all migrations and seeds from `supabase/seed.sql` (if present).

### Stop Supabase
```bash
mise run supabase:stop
```
Stops all containers but preserves data.

### Clean Restart
```bash
mise run supabase:stop
rm -rf supabase/.temp supabase/.branches  # Remove local state
mise run supabase:start
mise run supabase:env
```

## Troubleshooting

### "Supabase is not running"
```bash
mise run supabase:status
# If not running:
mise run supabase:start
```

### ".env file not found" error
```bash
# Create from template
cp .env.example .env

# Or auto-populate
mise run supabase:env
```

### Build fails with "SUPABASE_URL not found"
1. Verify `.env` exists and has credentials
2. Regenerate Xcode project: `mise run ios:gen`
3. Clean build folder: `Cmd+Shift+K` in Xcode
4. Rebuild: `mise run ios:build:dev`

### "Cannot connect to Supabase" at runtime
- Check `AppConfiguration.primaryWarning` for validation errors
- Verify `SUPABASE_URL=http://127.0.0.1:54321` (not https)
- Confirm Supabase is running: `mise run supabase:status`
- In simulator, network can reach localhost via special host alias

### Email authentication not working
- Check Mailpit http://127.0.0.1:54324 for error emails
- Verify email format (must be valid address)
- Check `supabase/config.toml` email settings

## Architecture

### Supabase Local Setup
- **Database:** PostgreSQL 15 on port 54322
- **Auth:** GoTrue (Supabase auth service) on port 54321
- **Storage:** S3-compatible storage on port 54321/storage/v1/s3
- **Studio:** Web UI on port 54323
- **Mailpit:** Email capture/testing on port 54324

### BetterFit Integration
- **AuthService:** Uses Supabase Swift client
- **Persistence:** SupabasePersistenceService for syncing
- **Configuration:** AppConfiguration validates env vars at startup
- **Fallback:** Guest mode available if Supabase not configured

See [docs/api.md](api.md) for API integration details.

## Next Steps

- Read [docs/auth.md](auth.md) for authentication setup details
- Check [docs/api.md](api.md) for data persistence examples
- Review [AGENTS.md](../AGENTS.md) for code organization practices
