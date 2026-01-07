# AGENTS.md (BetterFit)

## Philosophy
- **Keep it simple** – prefer deleting code over adding more
- **Use native iOS APIs** – reach for `.searchable()`, `.sheet()`, `.navigationTitle()` before building custom UI
- **Refactor before extending** – simplify existing code rather than layering complexity
- **Avoid reinventing the wheel** – SwiftUI and UIKit already solve most problems
- **Do NOT create progress/summary markdown files** (e.g., `SUMMARY.md`, `CHANGES.md`) to document your work—it's redundant and noisy.
- **Use wide events for logging** – emit one comprehensive log event per request/operation with full context (user, business, infrastructure, performance) rather than scattering multiple log statements. This enables effective debugging at scale.

## SwiftUI vs UIKit (when to use UIViewRepresentable)

### Default: Prefer SwiftUI
- Use SwiftUI for all standard UI (lists, navigation, forms, buttons, sheets)
- SwiftUI provides better maintainability, less boilerplate, and automatic dark mode support
- Most features (95%) can be built with pure SwiftUI

### When to drop to UIKit (via UIViewRepresentable)
Use UIKit when you encounter these specific limitations:

1. **Complex forms with keyboard management**
   - Multi-field forms where @FocusState causes keyboard bounce
   - Custom return key behavior (next/done transitions)
   - Solution: UITextField with UITextFieldDelegate

2. **Performance-critical scrolling**
   - Lists with 10,000+ items that need 120 FPS on ProMotion
   - Memory-constrained scenarios (NavigationStack retains all views)
   - Solution: UICollectionView with UIDiffableDataSource

3. **Advanced gestures**
   - Multi-finger taps (2-finger, 3-finger gestures)
   - Complex gesture coordination with failure requirements
   - Solution: UITapGestureRecognizer with numberOfTouchesRequired

4. **Custom camera/scanning**
   - Document scanning, custom camera interfaces
   - Solution: VNDocumentCameraViewController or AVCaptureSession

5. **Complex compositional layouts**
   - Netflix-style heterogeneous sections (carousels + grids + banners)
   - Orthogonal scrolling (horizontal within vertical)
   - Solution: UICollectionViewCompositionalLayout

6. **Pinch-to-zoom photo viewers**
   - Photo galleries with proper content centering and insets
   - Solution: UIScrollView with viewForZooming delegate

7. **Real-time graphics/animations**
   - Particle systems, physics animations requiring 60+ FPS
   - Solution: CALayer with Core Animation

### Pattern: UIKit interop
When using UIViewRepresentable:
- Keep the wrapper thin - logic should live in SwiftUI view models
- Use @Binding to sync state between SwiftUI and UIKit
- Prefer UIHostingConfiguration (iOS 16+) for SwiftUI cells in UICollectionView
- Extract into reusable components (e.g., `CustomTextField`, `DocumentScanner`)
- Consider helper libraries: IQKeyboardManager (keyboard handling), Introspect (accessing underlying UIKit views)

### iOS 26+ improvements
- **Native WebView**: iOS 26 adds native SwiftUI WebView component (no longer needs WKWebView wrapper)
- **UIViewRepresentable improvements**: Better bindings synchronization, reduced update loops with @Observable
- **Rich text editing**: TextEditor now supports AttributedString (bold, italic, colors)
- **Gesture improvements**: UIGestureRecognizerRepresentable makes bridging easier
- **Layout protocol**: Prefer custom Layout over GeometryReader for performance

### Industry adoption (2025)
- **70-75%** of professional teams use a hybrid SwiftUI + UIKit approach
- **60%** prefer SwiftUI for new features
- **25%** are SwiftUI-only (startups, greenfield projects)

## Fast workflows (use `mise`)
- Install tools: `mise install`
- After making changes, run lint first: `mise run lint` (quicker feedback before building)
- Build SwiftPM package: `mise run build` (runs `swift build`)
- Run unit tests: `mise run test` (runs `swift test`)
- iOS host app (XcodeGen): `mise run ios:open` (generates then opens `Apps/iOS/BetterFit.xcodeproj`)
- CLI iOS build: `mise run ios:build:prod` / `mise run ios:build:dev`
- watchOS app (XcodeGen): `mise run watch:open` (generates then opens project with watch target)
- CLI watchOS build: `mise run watch:build`

## Local Supabase setup (check before running)
Before running Supabase setup commands, check if local Supabase is already configured:

### Check if already set up
```bash
# 1. Check if Supabase is running
mise run supabase:status

# 2. Check if .env exists with credentials
cat .env | grep -E "SUPABASE_URL|SUPABASE_ANON_KEY"
```

### When Supabase setup is needed
- **First time** on a new machine/clone
- `.env` file is missing
- `mise run supabase:status` shows "not running"
- After running `git clean -fdx` (deletes `.env`)

### When Supabase setup is NOT needed
- `.env` file exists with `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- `mise run supabase:status` shows running services
- After making code changes (credentials persist)
- After running `mise build` / `mise test` (doesn't affect credentials)
- After `mise run ios:open` / `mise run ios:build:dev` (auto-injects from existing `.env`)

### One-time setup (if not already configured)
```bash
# 1. Start Supabase (if not running)
mise run supabase:start

# 2. Apply database migrations
mise run supabase:reset

# 3. Configure for iOS (creates .env + injects credentials)
mise run supabase:configure
```

### After initial setup
Once `.env` exists, just use normal build commands:
```bash
mise run ios:open       # Auto-injects credentials from .env
mise run ios:build:dev  # Auto-injects credentials from .env
```

**Never run `xcodegen generate` directly** – always use `mise run ios:gen` or `mise run ios:open` to ensure credentials are injected from `.env`.

## Code organization (`// MARK:`)
- Prefer grouping Swift files into navigable sections using `// MARK: - ...`.
- Use `// MARK:` above declarations (computed properties, functions, nested types) rather than inside view builder closures.
- Suggested ordering for SwiftUI views:
  - `// MARK: - View` (e.g. `var body`)
  - `// MARK: - Suggested Workouts Section` (recommended/suggested workouts UI + helpers)
  - `// MARK: - Sections` (other list/cards/sections)
  - `// MARK: - Data` (static data, computed collections)
  - `// MARK: - Supporting Types` (nested structs/enums)
- Keep marks short and consistent; add them when a file has multiple logical blocks.

## SwiftUI State & Reactivity (preventing unwanted re-renders)
- **Problem**: Reading frequently-changing `@State` in a computed property causes SwiftUI to re-evaluate that property on every state change. This cascades to all sibling views in the same parent, causing flickering and performance issues.
  - Example: `elapsedTimeUpdateTrigger` toggled 100x/second in timer callback, read in parent's `compactWelcomeSection` → target muscles section re-renders 100x/second.
  - Example: `cardSwipeOffset` updated every frame during drag gesture, read in parent's `workoutCardStack` → target muscles section flickers during swipe.
- **Solution**: Extract the view that reads the frequently-changing state into its own child component with `@Binding`. This creates a "reactivity boundary" — only the child re-renders, not the parent or siblings.
  - Move the state to the child as `@State private`.
  - Pass the binding from parent: `$elapsedTimeUpdateTrigger`.
  - Child reads the binding in its `body`, isolating re-renders.
- **Pattern**:
  ```swift
  // Parent (WorkoutHomeView)
  @State var elapsedTimeUpdateTrigger = false
  
  var compactWelcomeSection: some View {
    // Isolated child—only this component re-renders on timer ticks
    ElapsedTimeDisplay(elapsedTimeUpdateTrigger: $elapsedTimeUpdateTrigger, ...)
  }
  
  // Child (private struct)
  private struct ElapsedTimeDisplay: View {
    @Binding var elapsedTimeUpdateTrigger: Bool
    
    var body: some View {
      let _ = elapsedTimeUpdateTrigger  // Force read on every state change
      // Only this view re-renders, not parent siblings
      Text(formatElapsed(...))
    }
  }
  ```
- **When to extract**:
  - Timer/animation loops that toggle state frequently (>10x/sec).
  - Drag gestures that update state on every movement.
  - Any computed property reading a high-frequency state that has unrelated siblings.
- **Don't over-extract**: If a section reads stable state (only changes on user tap), keep it in the parent as a computed property.

## Large Swift files (when/how to split)

### When to split
- Split SwiftUI screens when the file is no longer scan-friendly (roughly 300–500+ lines), or when it contains multiple “reasons to change” (layout, data shaping, small components, formatting helpers).
- Split earlier if SwiftUI type-checking or preview/build times start to degrade.

### What to split into
- **Main screen**: the `struct ...: View`, `@State`, init, `body`, navigation, sheets/toolbars.
- **Sections**: cohesive view chunks like `welcomeSection`, `overviewSection`, `recapCard`, etc.
- **Components**: small reusable view structs (e.g. pills, stat rows, gauges).
- **Helpers**: pure functions for formatting, date range logic, aggregation, derived data.
- **UI-only types** (optional): simple structs/enums used only by the screen.

### Process (safe refactor loop)
1. Keep the entry point stable: don’t rename the screen type or initializer unless necessary.
2. Extract one cohesive slice at a time (e.g., a single section) and rebuild frequently.
3. Prefer splitting via `extension ScreenName` across files to avoid threading bindings everywhere.
4. If a section becomes broadly reusable, promote it to its own `View` type and pass only what it needs.
5. After each extraction: run `mise run ios:build:dev` (UI) and `mise run test` (core behaviors).

### Access control guidance
- Within one file, `private` is ideal.
- Once split across multiple files, `private` will stop compiling; prefer:
  - `fileprivate` for helpers/components meant to stay screen-scoped, or
  - `internal` (default) for app-module reuse.
- Keep the public surface area small; avoid making everything `public`/`open`.

### Suggested file structure (iOS host app)
For larger screens, prefer feature folders under `Apps/iOS/BetterFitApp`:

- `Apps/iOS/BetterFitApp/Features/<FeatureName>/`
  - `<FeatureName>View.swift` (entry point: state/init/body)
  - `<FeatureName>View+Sections.swift` (computed section views)
  - `<FeatureName>View+Helpers.swift` (pure helper funcs)
  - `<FeatureName>Components.swift` (small view structs)
  - `<FeatureName>Models.swift` (optional: UI-only types)

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

### Test pyramid
- **Unit tests** (`Tests/BetterFitTests/*.swift`) – test individual functions, models, and managers in isolation. Run with `mise run test`.
- **Integration tests** (`Tests/BetterFitTests/IntegrationTests.swift`) – test cross-feature flows through the `BetterFit` facade (e.g., `startWorkout` → `completeWorkout` updates history, recovery, and streak).
- **UI tests** (`Apps/iOS/BetterFitAppUITests/*.swift`) – test user-facing flows in the iOS simulator. Run with `mise run ios:test:ui`.
- **Mobile MCP tests** – use the mobile-mcp tools to interactively test UI on simulators for exploratory testing, debugging, and verifying visual behavior.

### When to write tests
- **Unit tests**: For any new model, helper function, or manager method. Keep them fast and isolated.
- **Integration tests**: For cross-feature flows that touch multiple managers/services (e.g., completing a workout updates streak + recovery + history).
- **UI tests**: For regression testing of critical user journeys (navigation, sheet presentation, swipe actions, form controls). Write new UI tests when adding features that change user-facing behavior.
- **Mobile MCP**: For exploratory testing, debugging visual issues, and verifying UI behavior that's hard to capture in XCUITest.

### Running tests
```bash
# Unit + integration tests (SwiftPM)
mise run test

# UI tests (requires iOS simulator)
mise run ios:test:ui

# Boot simulator for manual/Mobile MCP testing
mise run ios:sim:boot26
```

### Using Mobile MCP for UI testing
Mobile MCP provides tools to interact with iOS simulators programmatically:
1. **List available devices**: Use `mobile_list_available_devices` to find booted simulators.
2. **Take screenshots**: Use `mobile_take_screenshot` to capture current screen state.
3. **Tap elements**: Use `list_elements_on_screen` to find coordinates, then tap with screen interaction tools.
4. **Type text**: Use `mobile_type_keys` to enter text in focused fields.
5. **Swipe**: Use `mobile_swipe_on_screen` for scroll/swipe gestures.
6. **Press buttons**: Use `mobile_press_button` for HOME, VOLUME, etc.

**Workflow for testing with Mobile MCP**:
1. Boot the simulator: `mise run ios:sim:boot26`
2. Build and install the app: `mise run ios:build:dev`
3. Use Mobile MCP tools to navigate, tap, swipe, and verify UI states
4. Take screenshots to document expected behavior
5. If a bug is found, write a UI test to prevent regression

### UI test patterns
UI tests live in `Apps/iOS/BetterFitAppUITests/` and use XCUITest:
```swift
final class ExampleUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        app.launch()
    }

    func testFeatureFlow() throws {
        // Navigate to feature
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Verify content
        XCTAssertTrue(app.staticTexts["Expected Title"].waitForExistence(timeout: 3))
        
        // Interact with elements
        app.buttons["Action Button"].tap()
        
        // Verify result
        XCTAssertTrue(app.sheets.firstMatch.exists)
    }
}
```

### Accessibility identifiers
Add accessibility identifiers to views for reliable UI test targeting:
```swift
Text("Exercise Row")
    .accessibilityIdentifier("exercise-timeline-row")
```

### Test file organization
```
Tests/BetterFitTests/
├── ModelTests.swift           # Unit tests for models
├── EquipmentSwapTests.swift   # Unit tests for feature managers
├── IntegrationTests.swift     # Cross-feature flow tests
└── ...

Apps/iOS/BetterFitAppUITests/
├── AdjustSetsUITests.swift    # UI tests for adjust sets feature
└── ...                        # Add new UI test files per feature
```

### Best practices
- Use `DEMO_MODE` launch argument for consistent test data in UI tests.
- Keep unit tests fast (< 1s each) – avoid network/disk I/O.
- Use `waitForExistence(timeout:)` in UI tests for async content.
- Add accessibility identifiers to custom components for testability.
- Run `mise run test` before committing to catch regressions early.
- Run `mise run ios:test:ui` after UI changes to verify user flows.

## Docs entry points
- Repo overview: `README.md`
- Deeper docs: `docs/README.md`, `docs/api.md`, `docs/examples.md`
- TabView patterns (iOS 26+): `docs/tabview.md`
