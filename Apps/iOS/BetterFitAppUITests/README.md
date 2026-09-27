# BetterFit UI Tests

Automated UI tests for verifying the BetterFit app functionality, with a focus on workout planning journeys and the redesigned tab structure.

## Running Tests

### Quick Start
```bash
# Run all UI tests
mise run ios:test:ui

# Or via Xcode
mise run ios:open
# Then: Cmd+U or Product > Test
```

## Tab Structure

Tests navigate via the tab bar titles defined by `AppTab` in
`Apps/iOS/BetterFitApp/Features/RootTab/RootTabView.swift`:

| Tab | Screen | Contents |
|-----|--------|----------|
| **Workout** | `WorkoutHomeView` | Today's plan ("The work"), quick actions, "Start something else", floating Start workout dock |
| **Body** | `RecoveryView` | Overall recovery readout, per-muscle recovery rows |
| **Targets** | `TargetsView` | This week slab, weekly targets, the week, streak, records |
| **Log** | `LogView` | Streak readout, consistency heatmap, month ledger, all-time stats |

Prefer `app.tabBars.buttons["<Title>"]` over index-based tab access.

### Test Coverage

#### `AdjustSetsUITests.swift`
Core workout planning journeys:

- **Plan Navigation** — Workout tab loads today's plan; the work list renders planned exercises with set counts
- **Exercise Detail (adjust sets)** — tapping the focus exercise row opens the `ExerciseDetailSheet` set editor (sets section, KG/REPS columns, Save/Cancel)
- **Recovery Insights** — recovery rows live on the Body tab
- **Weekly Stats** — weekly progress lives on the Targets tab

#### `TabNavigationUITests.swift`
- All four tabs are reachable and show distinct content
- The Start workout dock only appears on the Workout tab
- The dock does not overlap scrollable content on other tabs
- Starting a workout transitions to the active session

#### `ProfileJourneyUITests.swift`
Content that moved off the old Profile tab:

- Health/recovery overview → Body tab
- Weekly targets → Targets tab
- Personal records / empty state → Targets tab

#### `WorkoutPreviewUITests.swift`
The workout preview sheet opened from "Start something else" (Legs A renders its work, Close dismisses).

#### `WorkoutSummaryUITests.swift`
Finishing a demo session shows the summary (session complete, what you lifted, next row) and hides the recovery section when no sets were logged.

#### `LogViewUITests.swift`
Streak readout, consistency heatmap (26 weeks), all-time stats, log-a-past-workout sheet.

#### `TargetsViewUITests.swift`
This week slab, weekly target rows, week day rows, streak and records sections.

## Requirements

- **Xcode 15.0+**
- **iOS 17.0+ Simulator**
- Demo mode enabled for consistent test data

## Accessibility Identifiers

Current tests match on accessibility labels (section rules, row titles, button
labels) rather than custom identifiers. Known identifiers in the app:

- `exercise-timeline-row` — rows in `UnifiedExerciseTimeline` (currently only used by the unwired `PlanView`)

## Demo Mode

Tests run with these launch arguments:
- `UI_TESTING` - Enables UI testing mode
- `DEMO_MODE` - Uses consistent seed data

This ensures predictable test results regardless of user data. Note that the
demo plan is a Push/Pull/Legs split (`WorkoutPlanManager`), so today's session
name varies by weekday — assert structural markers ("The work", "Focus
exercise", "Exercise 01") rather than session names.

## Coverage Gaps

- **ProfileView sheet is unreachable** — `WorkoutHomeView.onProfile` is never
  invoked, so profile-only surfaces are untested: PR detail sheet, achievements,
  yearly wrapped, settings sheet, guest/sign-in prompt.
- **AppSearchView sheet is unreachable** — `WorkoutHomeView.onSearch` is never
  invoked, so search/categories are untested.
- **`PlanView` (Trends) is unwired** — the old week-schedule plan screen is not
  in the tab hierarchy; the week now lives on the Targets tab.

## Troubleshooting

### Tests Can't Find a Tab
Verify the tab titles match `AppTab.title` in `RootTabView.swift`
(Workout, Body, Targets, Log).

### No Exercises in the Plan
If the work list is empty:
1. Verify demo mode is generating exercise data
2. Check `WorkoutPlanManager.generateInitialPlan()` and
   `WorkoutHomeView.loadPlan()` (falls back to the demo Pull Day)

### Sheet Not Opening
If a sheet (workout preview, exercise detail) doesn't open:
1. Confirm the row is hittable (scroll it on screen first)
2. Verify the tap target — plan rows open the detail sheet via the
   exercise-name button ("Focus exercise" meta on the first row)

### Simulator Issues
```bash
# Reset simulator if tests fail unexpectedly
mise run ios:sim:reset

# Boot fresh simulator
mise run ios:sim:boot26
```

## Future Tests

Potential additions:
- Test replacing exercises and supersets (swipe actions on plan rows)
- Test workout execution flow (logging sets in the active session)
- Test active workout pause/resume/stop (minimized session dock)
- Test watch app sync
- Re-add Profile coverage once `onProfile` is wired to a UI entry point
