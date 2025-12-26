# AGENTS.md (BetterFit)

## Fast workflows (use `mise`)
- Install tools: `mise install`
- Build SwiftPM package: `mise run build` (runs `swift build`)
- Run unit tests: `mise run test` (runs `swift test`)
- iOS host app (XcodeGen): `mise run ios:open` (generates then opens `Apps/iOS/BetterFit.xcodeproj`)
- CLI iOS build: `mise run ios:build:prod` / `mise run ios:build:dev`
- watchOS app (XcodeGen): `mise run watch:open` (generates then opens project with watch target)
- CLI watchOS build: `mise run watch:build`

## Big picture architecture
- This repo is primarily a SwiftPM library in `Sources/BetterFit` (see `Package.swift` platforms iOS 17+/watchOS 10+).
- `BetterFit` is the public “facade/orchestrator” (see `Sources/BetterFit/BetterFit.swift`): it wires feature managers + services and coordinates cross-feature flows.
  - Example flow: `completeWorkout(_:)` appends to history, updates recovery (`BodyMapManager`), updates streak (`SocialManager`), then conditionally runs `AIAdaptationService` and updates the active plan.
- Feature modules live under `Sources/BetterFit/Features/*` and are mostly in-memory managers with simple CRUD-style APIs.
- Domain models live under `Sources/BetterFit/Models/*` (e.g., `Workout`, `Exercise`, `Recovery`, `WorkoutTemplate`).
- “Services” live under `Sources/BetterFit/Services/*` (e.g., `AIAdaptationService`, `AutoTrackingService`) and are called by `BetterFit`.

## iOS host app (demo UI)
- Runnable app lives in `Apps/iOS/BetterFitApp` and depends on the local Swift package via XcodeGen config in `Apps/iOS/project.yml`.
- Don’t hand-edit `Apps/iOS/BetterFit.xcodeproj`; change `Apps/iOS/project.yml` and re-generate via `mise run ios:gen` / `ios:open`.
- The host app targets iOS 26.0 in `Apps/iOS/project.yml` and uses availability-gated UI (e.g. `glassEffect` when `#available(iOS 26.0, *)`).
- App wiring pattern:
  - `Apps/iOS/BetterFitApp/BetterFitApp.swift` creates a single `BetterFit()` and passes it down (see `RootTabView(...)`).
  - Views generally take `theme: AppTheme` and apply consistent styling from `Apps/iOS/BetterFitApp/AppTheme.swift` + `UIComponents.swift`.
  - Prefer the project’s UI primitives: `BFCard`, `LiquidGlassBackground`, `BFChromeIconButton`, and `.bfHeading(theme:size:relativeTo:)`.
  - Some views accept `betterFit: BetterFit?` to support “UI-only” mode (e.g. `Apps/iOS/BetterFitApp/AppSearchView.swift` shows “Recommended” only when `betterFit` is present).
## watchOS app (workout tracking on wrist)
- Watch app lives in `Apps/iOS/BetterFitWatchApp` and depends on the same Swift package.
- Configured as a watchOS target in `Apps/iOS/project.yml` with deployment target watchOS 10.0.
- Key features:
  - **WorkoutListView**: Browse recommended and available workouts with large, easy-to-tap buttons
  - **ActiveWorkoutView**: Track sets, reps, and weight with increment/decrement controls optimized for watch
  - **NotificationsView**: Configure workout reminders with time and day selection
- UI design principles:
  - All buttons sized for easy tapping on watch (large circular +/- buttons, full-width action buttons)
  - Bold, high-contrast typography (48pt for reps, 32pt for weight)
  - Clear visual hierarchy with prominent button styles
  - Auto-advance to next set after completion for seamless flow
- App state managed via `WatchAppState` observable object that wraps `BetterFit()` instance
- See `Apps/iOS/BetterFitWatchApp/README.md` for detailed watch app documentation
## Tests (how behavior is verified here)
- Tests are XCTest-based in `Tests/BetterFitTests` and run with `swift test`.
- Integration-style expectations live in `Tests/BetterFitTests/IntegrationTests.swift` (e.g., the `startWorkout` → `completeWorkout` flow updates history and streak).

## Docs entry points
- Repo overview: `README.md`
- Deeper docs: `docs/README.md`, `docs/api.md`, `docs/examples.md`
