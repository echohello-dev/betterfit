---
name: swift-file-splitting
description: Split large SwiftUI screens into maintainable, scan-friendly files. Use when files exceed 300-500 lines or contain multiple "reasons to change".
---

# BetterFit Swift File Splitting Skill

Use this skill when SwiftUI screen files become too large or contain too many concerns.

## When to activate this skill

- File exceeds 300–500+ lines
- SwiftUI type-checking or preview/build times degrade
- File contains multiple "reasons to change" (layout + data + formatting)
- Difficult to scan/navigate the file
- Want to reuse a section/component across screens
- User asks about file organization or refactoring large views

## When to split

Split when ANY of these are true:

- **Size**: File is no longer scan-friendly (roughly 300–500+ lines)
- **Multiple concerns**: Layout, data shaping, components, formatting helpers all in one file
- **Build time**: SwiftUI type-checking or preview times start degrading
- **Reusability**: A section/component could be reused elsewhere

## What to split into

| File type | Contents | Access |
|-----------|----------|--------|
| **Main screen** | `struct ...: View`, `@State`, init, `body`, navigation, sheets | `public` or default |
| **Sections** | Cohesive view chunks: `welcomeSection`, `overviewSection`, `recapCard` | `fileprivate` or `internal` |
| **Components** | Small reusable view structs: pills, stat rows, gauges | `internal` |
| **Helpers** | Pure functions: formatting, date logic, aggregation | `fileprivate` or `internal` |
| **Models** | UI-only types: simple structs/enums used by screen | `internal` |

## Suggested file structure

For larger screens under `Apps/iOS/BetterFitApp`:

```
Apps/iOS/BetterFitApp/Features/<FeatureName>/
├── <FeatureName>View.swift          # Entry point: state/init/body
├── <FeatureName>View+Sections.swift # Computed section views
├── <FeatureName>View+Helpers.swift  # Pure helper functions
├── <FeatureName>Components.swift    # Small reusable view structs
└── <FeatureName>Models.swift        # Optional: UI-only types
```

## Safe refactor process

Follow this loop to avoid breaking things:

1. **Keep entry point stable**
   - Don't rename the screen type or initializer unless necessary
   - Ensure existing call sites continue working

2. **Extract one cohesive slice at a time**
   - Start with a single section (e.g., `welcomeSection`)
   - Move it to the appropriate file
   - **Rebuild and test after each extraction**

3. **Prefer `extension` splitting**
   ```swift
   // WorkoutHomeView.swift
   struct WorkoutHomeView: View { ... }
   
   // WorkoutHomeView+Sections.swift
   extension WorkoutHomeView {
       var welcomeSection: some View { ... }
       var suggestedWorkoutsSection: some View { ... }
   }
   
   // WorkoutHomeView+Helpers.swift
   extension WorkoutHomeView {
       func formatElapsed(_ date: Date) -> String { ... }
   }
   ```

4. **Promote to reusable components**
   - If a section becomes broadly reusable, extract to its own `View` type
   - Pass only what it needs (don't thread bindings everywhere)
   - Example: `WorkoutCard(workout:)` instead of `workoutCard(for: at:)`

5. **Verify after each extraction**
   ```bash
   mise run ios:build:dev   # Verify UI compiles
   mise run test            # Verify core behaviors
   ```

## Access control guidance

| Scope | Access | Use when |
|-------|--------|----------|
| Same file | `private` | Everything possible |
| Same feature folder | `fileprivate` | Helpers/components meant to stay screen-scoped |
| Module-wide | `internal` (default) | Reusable across app |
| Public API | `public` | Library/framework exports |

Keep the public surface area small. Avoid making everything `public`/`open`.

## Example: Before and after

### Before (500+ lines)
```swift
struct WorkoutHomeView: View {
    @State private var workouts: [Workout] = []
    @State private var searchText = ""
    @State private var selectedFilter: Filter = .all
    
    var body: some View {
        ScrollView {
            welcomeSection
            filterBar
            workoutList
            statsSection
        }
    }
    
    var welcomeSection: some View { ... }      // 60 lines
    var filterBar: some View { ... }           // 40 lines
    var workoutList: some View { ... }         // 120 lines
    var statsSection: some View { ... }        // 80 lines
    
    func formatDate(_ date: Date) -> String { ... }
    func filterWorkouts() -> [Workout] { ... }
    func calculateStats() -> Stats { ... }
}

struct WorkoutRow: View { ... }              // 50 lines
struct StatCard: View { ... }                // 40 lines
```

### After (split into 4 files)

**WorkoutHomeView.swift** (120 lines)
```swift
struct WorkoutHomeView: View {
    @State private var workouts: [Workout] = []
    @State private var searchText = ""
    @State private var selectedFilter: Filter = .all
    
    var body: some View {
        ScrollView {
            WelcomeSection(user: currentUser)
            FilterBar(selection: $selectedFilter)
            WorkoutList(workouts: filteredWorkouts)
            StatsSection(stats: calculateStats())
        }
    }
}
```

**WorkoutHomeView+Sections.swift**
```swift
extension WorkoutHomeView {
    var filteredWorkouts: [Workout] { ... }
    func calculateStats() -> Stats { ... }
}
```

**WorkoutHomeView+Helpers.swift**
```swift
extension WorkoutHomeView {
    func formatDate(_ date: Date) -> String { ... }
}
```

**WorkoutHomeComponents.swift**
```swift
struct WelcomeSection: View { ... }
struct FilterBar: View { ... }
struct WorkoutList: View { ... }
struct StatsSection: View { ... }
struct WorkoutRow: View { ... }
struct StatCard: View { ... }
```

## Quick decision checklist

- [ ] File is >300 lines or hard to scan?
- [ ] Contains layout + data + formatting mixed together?
- [ ] Build/preview times degraded?
- [ ] Extract one section at a time, rebuild after each
- [ ] Use `extension ScreenName` across files to avoid threading bindings
- [ ] Run `mise run ios:build:dev` + `mise run test` after each extraction
- [ ] Keep entry point stable; don't rename unless necessary
