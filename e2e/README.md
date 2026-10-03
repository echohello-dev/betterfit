# BetterFit e2e — mobilewright

Deterministic iOS E2E tests driving the built app on a simulator, using the
Playwright-style API from [mobilewright](https://mobilewright.dev). Complements
the XCUITest suite in `Apps/iOS/BetterFitAppUITests/`.

## Run

```bash
mise run ios:e2e              # build app → boot sim → install agent → test
mise run ios:e2e -- --grep "rest"   # pass flags through to mobilewright
```

Or manually (sim already booted, app already built):

```bash
cd e2e && npx mobilewright test
npx mobilewright doctor        # environment check
```

## How tests work here

- **Launch args**: the app gates demo/onboarding on `UI_TESTING` / `DEMO_MODE`
  (`BetterFitApp.swift` reads `ProcessInfo.arguments`). mobilewright cannot pass
  launch args, so `tests/helpers.ts` does the reset itself:
  `simctl uninstall → install current build → simctl launch … UI_TESTING DEMO_MODE`.
  Always start a test with `await resetAndLaunch(device)` for pristine demo data.
- **Locators**: match on accessibility labels/roles (`getByRole('button', …)`,
  `getByText(…)`). `getByText` is **exact** by default — pass
  `{ exact: false }` for substring matches. Dynamic values (e.g. `Log 185 × 6`)
  match with regex.
- **View tree on failure**: `viewTree: 'on-failure'` in
  `mobilewright.config.ts` attaches the accessibility tree to the HTML report
  when a test fails — the fastest way to fix a broken locator.

## Layout

```
mobilewright.config.ts   # ios simulator, bundleId, autoAppLaunch: false
tests/
  helpers.ts              # resetAndLaunch(), findBuiltApp()
  smoke.test.ts           # plan tab + all four tabs reachable
  active-workout.test.ts  # Figma flows 2–3: log a set → rest timer → skip
```

## Flow coverage map

| Figma flow (App Screens) | XCUITest | mobilewright |
|---|---|---|
| 1 Plan | AdjustSets, TabNavigation | smoke.test.ts |
| 2 Log a set | — | active-workout.test.ts |
| 3 Rest | — | active-workout.test.ts |
| 4 Swap exercise | — | gap |
| 5 Recovery | AdjustSets (Body tab) | smoke.test.ts (tab reachability) |
| 6 Workout summary | WorkoutSummaryUITests | gap |

Known gaps (from the XCUITest README) still apply: Profile sheet, AppSearch
sheet, and PlanView are unreachable from the tab hierarchy.
