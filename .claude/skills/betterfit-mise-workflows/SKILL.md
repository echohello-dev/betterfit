---
name: betterfit-mise-workflows
description: Fast development workflows for the BetterFit iOS project using mise. Use when building, testing, opening Xcode, or running lint.
---

# BetterFit Mise Workflows Skill

Use this skill when performing any build, test, lint, or Xcode operations on the BetterFit project.

## When to activate this skill

- User wants to build the project
- User wants to run tests
- User wants to open Xcode
- User wants to lint code
- User wants to build for iOS or watchOS
- User wants to create or render app showcase videos
- User asks about project commands or workflows
- User encounters build errors and needs to rebuild

## Core Commands

### Essential workflow (run these in order)

```bash
# 1. Install tools (first time or after tool updates)
mise install

# 2. Lint (fast feedback before building)
mise run lint

# 3. Build SwiftPM package
mise run build              # Runs swift build

# 4. Run unit + integration tests
mise run test               # Runs swift test
```

### iOS host app commands

```bash
# Open Xcode project (generates + opens)
mise run ios:open

# Build iOS for development
mise run ios:build:dev

# Build iOS for production
mise run ios:build:prod

# Generate Xcode project only
mise run ios:gen

# Boot iOS 26 simulator
mise run ios:sim:boot26

# Run UI tests
mise run ios:test:ui
```

### watchOS app commands

```bash
# Open watchOS Xcode project
mise run watch:open

# Build watchOS
mise run watch:build
```

### Video showcase commands (Remotion + Bun)

```bash
# Install video dependencies (uses Bun)
mise run video:install

# Preview in Remotion Studio
mise run video:dev

# Render the main showcase video
mise run video:render:showcase

# Render any composition
mise run video:render -- <CompositionName>

# Render a single frame for QA
mise run video:still -- <CompositionName> <out.png> --frame=N
```

**Important:** Video tasks run in the `videos/` directory using Bun (not npm). See `remotion-app-showcase` skill for video creation guidance.

### Important rules

- **Never run `xcodegen generate` directly** — always use `mise run ios:gen` or `mise run ios:open` to ensure Supabase credentials are injected from `.env`
- After making changes, run `mise run lint` first (quicker feedback than building)
- Use `mise run ios:build:dev` for quick iteration; `mise run ios:build:prod` for release testing

## Workflow patterns

### Development loop
```
Make changes → mise run lint → mise run build → mise run test
```

### UI iteration loop
```
Make changes → mise run ios:build:dev → test in simulator
```

### Pre-commit checklist
```
mise run lint
mise run test
```

### When build fails
1. Run `mise run lint` to catch syntax/style issues first
2. Check if Supabase credentials are configured (see betterfit-supabase-setup skill)
3. Try clean build: `mise run ios:build:dev` (rebuilds from scratch)
4. For SwiftPM issues: `swift package resolve` then retry

## Project structure context

- **SwiftPM library**: `Sources/BetterFit/` — core business logic
- **iOS host app**: `Apps/iOS/BetterFitApp/` — demo UI, depends on SwiftPM package
- **watchOS app**: `Apps/iOS/BetterFitWatchApp/` — watch app
- **XcodeGen config**: `Apps/iOS/project.yml` — don't hand-edit `.xcodeproj`

## Common issues

### "No such module 'BetterFit'"
- Run `mise run ios:gen` to regenerate Xcode project with proper SPM linking

### Xcode project out of sync
- Don't edit `.xcodeproj` directly
- Run `mise run ios:open` to regenerate from `project.yml`

### Build fails after git clean
- `.env` may be deleted — check betterfit-supabase-setup skill for reconfiguration
