---
name: betterfit-testing
description: Testing practices for BetterFit iOS project. Use when writing, running, or debugging unit tests, integration tests, UI tests, or Mobile MCP tests.
---

# BetterFit Testing Skill

Use this skill when writing, running, or debugging any tests in the BetterFit project.

## When to activate this skill

- User wants to write a new test
- User wants to run tests
- User needs to debug a failing test
- User wants to test a specific feature or flow
- User asks about testing strategy or coverage
- User encountered a bug and wants to prevent regression
- User wants to use Mobile MCP for UI testing

## Test pyramid

| Layer | Location | Purpose | Command |
|-------|----------|---------|---------|
| **Unit tests** | `Tests/BetterFitTests/*.swift` | Individual functions, models, managers | `mise run test` |
| **Integration tests** | `Tests/BetterFitTests/IntegrationTests.swift` | Cross-feature flows via `BetterFit` facade | `mise run test` |
| **UI tests** | `Apps/iOS/BetterFitAppUITests/*.swift` | User-facing flows in simulator | `mise run ios:test:ui` |
| **Mobile MCP** | Interactive | Exploratory testing, visual debugging | Manual/MCP tools |

## When to write each type

### Unit tests
- New model or data structure
- Helper function with complex logic
- Manager method with business rules
- Equipment swap algorithm
- Date formatting or calculation logic

**Keep fast (< 1s each)** — avoid network/disk I/O.

### Integration tests
- Cross-feature flows touching multiple managers/services
- Example: `completeWorkout(_:)` updates history + recovery + streak
- Plan adaptation flows
- Social features (streaks, sharing)

### UI tests (XCUITest)
- Critical user journeys that could regress
- Navigation flows (tab switching, drill-downs)
- Sheet presentation and dismissal
- Swipe actions and gestures
- Form controls and validation

### Mobile MCP tests
- Exploratory testing of new UI
- Visual debugging (flickering, layout issues)
- Verifying behavior hard to capture in XCUITest
- Interactive simulator testing

## Running tests

```bash
# Unit + integration tests (SwiftPM)
mise run test

# UI tests (requires iOS simulator)
mise run ios:test:ui

# Boot simulator for manual/MCP testing
mise run ios:sim:boot26
```

## Unit test example

```swift
import XCTest
@testable import BetterFit

final class WorkoutTests: XCTestCase {
    func testWorkoutDurationCalculation() {
        let workout = Workout(
            name: "Push Day",
            exercises: [
                Exercise(name: "Bench Press", sets: 3, reps: 10, restSeconds: 90),
                Exercise(name: "Overhead Press", sets: 3, reps: 10, restSeconds: 90)
            ]
        )
        
        XCTAssertEqual(workout.estimatedDuration, 720) // ~12 min
    }
    
    func testEquipmentSwap() {
        let exercise = Exercise(name: "Barbell Row", equipment: .barbell)
        let swapped = exercise.swapEquipment(to: .dumbbell)
        
        XCTAssertEqual(swapped.equipment, .dumbbell)
        XCTAssertEqual(swapped.name, "Dumbbell Row")
    }
}
```

## Integration test example

```swift
final class IntegrationTests: XCTestCase {
    var betterFit: BetterFit!
    
    override func setUp() {
        super.setUp()
        betterFit = BetterFit()
    }
    
    func testCompleteWorkoutUpdatesAllSystems() {
        // Given
        let workout = betterFit.recommendedWorkouts.first!
        
        // When
        betterFit.startWorkout(workout)
        betterFit.completeWorkout(workout)
        
        // Then
        XCTAssertTrue(betterFit.history.contains(workout))
        XCTAssertGreaterThan(betterFit.bodyMap.recovery[.chest] ?? 0, 0)
        XCTAssertEqual(betterFit.social.currentStreak, 1)
    }
}
```

## UI test example

```swift
final class WorkoutFlowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        app.launch()
    }
    
    func testStartWorkoutFlow() throws {
        // Tap Workout tab
        app.tabBars.buttons["Workout"].tap()
        
        // Tap first recommended workout
        app.cells.firstMatch.tap()
        
        // Verify workout detail appears
        XCTAssertTrue(app.staticTexts["Start Workout"].waitForExistence(timeout: 3))
        
        // Start workout
        app.buttons["Start Workout"].tap()
        
        // Verify active workout screen
        XCTAssertTrue(app.staticTexts["Current Exercise"].exists)
    }
}
```

## Mobile MCP testing workflow

1. **Boot simulator**
   ```bash
   mise run ios:sim:boot26
   ```

2. **Build and install**
   ```bash
   mise run ios:build:dev
   ```

3. **Use MCP tools to interact**
   - List elements: `mobile_list_elements_on_screen`
   - Take screenshots: `mobile_take_screenshot`
   - Tap: `mobile_tap_on_screen`
   - Swipe: `mobile_swipe_on_screen`
   - Type: `mobile_type_keys`

4. **Document findings**
   - Take screenshots of expected behavior
   - Write UI tests for any bugs found

## Accessibility identifiers

Add identifiers for reliable UI test targeting:

```swift
Text("Exercise Row")
    .accessibilityIdentifier("exercise-timeline-row")

Button("Start Workout") {
    startWorkout()
}
.accessibilityIdentifier("start-workout-button")
```

## Test file organization

```
Tests/BetterFitTests/
├── ModelTests.swift           # Unit tests for models
├── EquipmentSwapTests.swift   # Unit tests for feature managers
├── IntegrationTests.swift     # Cross-feature flow tests
└── ...

Apps/iOS/BetterFitAppUITests/
├── WorkoutFlowUITests.swift   # UI tests for workout features
├── SearchUITests.swift        # UI tests for search
└── ...                        # Add new UI test files per feature
```

## Best practices

- Use `DEMO_MODE` launch argument for consistent test data
- Keep unit tests fast — mock dependencies, avoid real network
- Use `waitForExistence(timeout:)` in UI tests for async content
- Run `mise run test` before committing to catch regressions
- Run `mise run ios:test:ui` after UI changes
- Add accessibility identifiers to custom components
- For Mobile MCP: take screenshots to document issues
- Write UI tests for bugs found during MCP exploration

## Quick decision flow

```
New feature?
├── Pure logic (model, helper)? → Unit test
├── Cross-feature flow? → Integration test
├── User-facing behavior? → UI test
└── Visual/debug issue? → Mobile MCP exploratory test
```
