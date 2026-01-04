# BetterFit UI Tests

Automated UI tests for verifying the BetterFit app functionality, with a focus on the Adjust Sets feature.

## Running Tests

### Quick Start
```bash
# Run all UI tests
mise run ios:test:ui

# Or via Xcode
mise run ios:open
# Then: Cmd+U or Product > Test
```

### Test Coverage

#### `AdjustSetsUITests.swift`
Tests for the Adjust Sets functionality in PlanView:

- **Navigation Tests**
  - `testNavigateToPlanView` - Verifies tab navigation to Plan view
  - `testPlanViewShowsWeekDays` - Checks week schedule rendering
  - `testTodaysPlanSectionExists` - Validates exercises or empty state

- **Swipe Actions**
  - `testSwipeToRevealAdjustSets` - Swipe left reveals "Adjust Sets" button
  - `testAdjustSetsSheetOpens` - Tapping action opens modal sheet

- **Sheet Controls**
  - `testAdjustSetsSheetControls` - Verifies all controls exist (sets stepper, reps field, weight field, save button)
  - `testAdjustSetsIncrement` - Tests + button increments sets
  - `testAdjustSetsDecrement` - Tests - button decrements sets
  - `testAdjustSetsSaveAndDismiss` - Save button dismisses sheet
  - `testAdjustSetsCancelDismisses` - Cancel button dismisses sheet

- **Context Menu**
  - `testLongPressShowsAdjustSets` - Long press shows "Adjust Sets" in menu

## Requirements

- **Xcode 15.0+**
- **iOS 17.0+ Simulator**
- Demo mode enabled for consistent test data

## Architecture

### Test Structure
```
BetterFitAppUITests/
├── AdjustSetsUITests.swift      # Adjust sets functionality tests
└── README.md                     # This file
```

### Accessibility Identifiers
Tests rely on accessibility identifiers added to components:
- `exercise-timeline-row` - Timeline exercise rows in UnifiedExerciseTimeline

### Test Helpers
- `navigateToPlan()` - Navigates to Plan tab
- `openAdjustSetsSheet()` - Opens adjust sets sheet for first exercise

## Demo Mode

Tests run with these launch arguments:
- `UI_TESTING` - Enables UI testing mode
- `DEMO_MODE` - Uses consistent seed data

This ensures predictable test results regardless of user data.

## Troubleshooting

### Tests Skip Due to No Exercises
If tests skip with "No exercises found in plan":
1. Verify demo mode is generating exercise data
2. Check `WorkoutPlanManager.generateInitialPlan()` in demo mode
3. Ensure at least one day has exercises

### Sheet Not Opening
If "Adjust Sets" sheet doesn't open:
1. Check accessibility identifier is set on timeline rows
2. Verify swipe gesture is working (try manual test)
3. Ensure `onAdjustSets` callback is wired in PlanView

### Simulator Issues
```bash
# Reset simulator if tests fail unexpectedly
mise run ios:sim:reset

# Boot fresh simulator
mise run ios:sim:boot26
```

## Future Tests

Potential additions:
- Test replacing exercises
- Test creating supersets
- Test drag-to-reorder exercises
- Test workout execution flow
- Test active workout tracking
- Test watch app sync
