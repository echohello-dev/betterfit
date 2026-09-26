---
name: supabase-setup
description: Local Supabase setup and configuration for BetterFit iOS app. Use when setting up the project for the first time, or when .env credentials are missing.
---

# BetterFit Supabase Setup Skill

Use this skill when configuring local Supabase for the BetterFit iOS project, or when the `.env` file is missing/corrupted.

## When to activate this skill

- First time project setup on a new machine
- `.env` file is missing
- `mise run supabase:status` shows services not running
- After `git clean -fdx` (deletes `.env`)
- Build errors mentioning Supabase URL or anon key
- User asks about database setup or backend configuration

## Prerequisites check

Before running setup commands, verify current state:

```bash
# Check if Supabase is running
mise run supabase:status

# Check if .env exists with credentials
cat .env | grep -E "SUPABASE_URL|SUPABASE_ANON_KEY"
```

## When setup is NOT needed

Skip setup if ALL of these are true:
- `.env` file exists with `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- `mise run supabase:status` shows running services
- Recent code changes only (no infrastructure changes)

Setup is NOT needed after:
- Making code changes (credentials persist)
- Running `mise build` / `mise test`
- Running `mise run ios:open` / `mise run ios:build:dev` (auto-injects from existing `.env`)

## One-time setup

If Supabase is not configured, run these in order:

```bash
# 1. Start Supabase services
mise run supabase:start

# 2. Apply database migrations (creates tables, functions, etc.)
mise run supabase:reset

# 3. Configure for iOS (creates .env + injects credentials into Xcode project)
mise run supabase:configure
```

After step 3, verify `.env` was created:
```bash
cat .env
```

## After initial setup

Once `.env` exists, use normal build commands (credentials auto-inject):

```bash
mise run ios:open       # Opens Xcode with credentials injected
mise run ios:build:dev  # Builds with credentials injected
mise run ios:build:prod
```

## Important rules

- **Never run `xcodegen generate` directly** — always use `mise run ios:gen` or `mise run ios:open` to ensure credentials are injected from `.env`
- Credentials are stored in `.env` (not committed to git)
- If `.env` is deleted, rerun `mise run supabase:configure`

## Troubleshooting

### "SUPABASE_URL not found"
- `.env` is missing → run `mise run supabase:configure`

### Supabase services won't start
```bash
# Check Docker is running
docker ps

# Restart Supabase
mise run supabase:stop
mise run supabase:start
```

### Credentials changed (rare)
```bash
# Reconfigure from scratch
mise run supabase:reset
mise run supabase:configure
```

### iOS build can't find Supabase credentials
- Ensure `.env` exists at project root
- Run `mise run ios:gen` to regenerate Xcode project with injected credentials
- Never edit `.xcodeproj` directly
