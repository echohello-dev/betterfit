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

### 3. Apply database migrations
```bash
mise run supabase:reset
```
Creates all persistence tables (workouts, templates, plans, etc.) with Row Level Security.

### 4. Configure Xcode project with Supabase credentials
```bash
mise run supabase:configure
```
This single command:
1. Populates `.env` with credentials from `supabase status`
2. Regenerates Xcode project with XcodeGen
3. Injects environment variables from `.env` into Xcode scheme

**What gets set:**
```dotenv
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=sb_publishable_ACJWl...
SUPABASE_SECRET_KEY=sb_secret_N7UND0U...
```

**Why this approach?**
- Credentials stay in `.env` (git-ignored), never committed to version control
- No hardcoded values in `project.yml` or scheme files
- Each developer's credentials are local to their machine
- Script automatically updates scheme when credentials change

### 5. Build and run the app
```bash
# Generate Xcode project and open it
mise run ios:open

# Or just build for simulator
mise run ios:build:dev
```

**Note:** `ios:open` and `ios:gen` automatically inject credentials from `.env` into the scheme after generation.

The runtime flow:
1. Xcode scheme provides `SUPABASE_URL` and `SUPABASE_ANON_KEY` as environment variables
2. App reads via `ProcessInfo.processInfo.environment`
3. `AppConfiguration` → `EnvironmentLoader` loads credentials
4. App initializes `AuthService` and `BetterFit` with Supabase client

### 6. Test authentication
In the simulator:
- Tap "Sign in with Email" → enter any email/password (6+ chars for new accounts)
- Tap "Continue as Guest" → offline mode
- Tap "Sign in with Apple" → simulated approval

## How It Works

### Credential Management (Secure Approach)

```
Supabase running locally
    ↓
scripts/setup_local_env.sh (reads supabase status)
    ↓
.env file (git-ignored, never committed)
    ↓
scripts/update_scheme_env.sh (injects into Xcode scheme XML)
    ↓
BetterFit.xcscheme (local file, credentials injected post-generation)
    ↓
ProcessInfo.processInfo.environment (runtime)
    ↓
AppConfiguration.swift (via EnvironmentLoader)
    ↓
AuthService, BetterFit initialization
```

**Key principle:** Credentials never committed to version control
- `project.yml` has no hardcoded values (only declares scheme structure)
- `.env` is git-ignored
- Scheme files have credentials injected locally via script
- Each developer runs `mise run supabase:configure` to set up their environment

### Project Generation Flow

In `mise.toml`:
```toml
[tasks."supabase:configure"]
run = """
bash scripts/setup_local_env.sh           # Populate .env
cd Apps/iOS && xcodegen generate          # Generate Xcode project
bash ../../scripts/update_scheme_env.sh   # Inject .env into scheme
"""
```

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
Runs all migrations from `supabase/migrations/` and seeds from `supabase/seed.sql` (if present).

### Apply Pending Migrations
```bash
mise run supabase:migrate
```
Applies only new migrations without resetting data.

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
- **Persistence:** SupabasePersistenceService for cloud sync (authenticated users)
- **Local Storage:** LocalPersistenceService using UserDefaults (guest mode)
- **Configuration:** AppConfiguration validates env vars at startup
- **Fallback:** Guest mode available if Supabase not configured

### Database Schema
Tables created by migrations in `supabase/migrations/`:

| Table | Purpose |
|-------|---------|
| `workouts` | Completed/in-progress workout sessions |
| `workout_templates` | Reusable workout templates |
| `training_plans` | Multi-week training programs |
| `user_profiles` | User profile + social data |
| `body_map_recovery` | Muscle recovery tracking |
| `streak_data` | Workout streak tracking |

All tables use Row Level Security (RLS) - users can only access their own data.

See [docs/api.md](api.md) for API integration details.

## Next Steps

- Read [docs/auth.md](auth.md) for authentication setup details
- Check [docs/api.md](api.md) for data persistence examples
- Review [AGENTS.md](../AGENTS.md) for code organization practices
