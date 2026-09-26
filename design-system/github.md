repo: echohello-dev/betterfit
branch: main
path: Apps/iOS

## Last sync

date: 2026-07-30T11:17:04Z

### Updated in this project

- Read upstream `design.md` and `BFColors.swift`: the repo had moved product accent to ember orange `#FF5A3C`.
- Rejected that direction. Rewrote `design.md` in this project as the two-colour source of truth: yellow `#FFD60A` is the accent, black is its ink, no third hue.
- Added guidance the repo doc lacked: yellow-versus-amber separation, one yellow fill per screen, AA pairing rule, and a note not to restate another training app's layout.
- Marked `BFColors.brandAccent` deprecated in the implementation reference; tokens in this project were already orange-free.
- Reimagined the iPhone screen layouts on a new in-house language ("The Ledger" — ruled rows, a 32px mono gutter, one squared yellow slab per screen, bars never rings). Rebuilt Plan, Body, Targets, Log, Session and Summary; retired `HomeScreen` and `PlanScreen` (duplicated Plan and Body); retired `IdentityBand` in favour of `Slab`.

### Divergence from upstream

`design.md` here supersedes `Apps/iOS/.../design.md`. Ember orange is deprecated by design decision, not drift — port this doc back to the repo before changing tokens there.

### Not yet recreated

New upstream surfaces with no screen in this kit: `Components/AdjustSetsSheet`, `ExerciseDetailSheet`, `HealthKitComponents`, `UnifiedExerciseTimeline`, `Features/StreakSummary/StreakSummarySheetView`, `BetterFitWatchApp/NotificationsView`, `DesignSystem/BFBodyMap`, `BFIllustrations`.

## Screen map

| Project screen | Repo files |
| --- | --- |
| `ui_kits/ios_app/SignInScreen.jsx` | `Apps/iOS/BetterFitApp/Features/Auth/SignInView.swift` |
| `ui_kits/ios_app/MyPlanScreen.jsx` | `Apps/iOS/BetterFitApp/Features/WorkoutHome/WorkoutHomeView.swift`, `WorkoutHomeView+Sections.swift`, `WorkoutHomeComponents.swift`, `Features/Trends/PlanView.swift` |
| `ui_kits/ios_app/BodyScreen.jsx` | `Apps/iOS/BetterFitApp/Features/Recovery/RecoveryView.swift` |
| `ui_kits/ios_app/TargetsScreen.jsx` | — (no repo counterpart) |
| `ui_kits/ios_app/LogScreen.jsx` | — (no repo counterpart) |
| `ui_kits/ios_app/SummaryScreen.jsx` | — (no repo counterpart) |
| `ui_kits/ios_app/SessionScreen.jsx` | `Apps/iOS/BetterFitApp/Features/ActiveWorkout/ActiveSessionView.swift` |
| `ui_kits/ios_app/SearchScreen.jsx` | `Apps/iOS/BetterFitApp/Features/AppSearch/AppSearchView.swift` |
| `ui_kits/ios_app/ProfileScreen.jsx` | `Apps/iOS/BetterFitApp/Features/Profile/ProfileView.swift` |
| `ui_kits/ios_app/SettingsScreen.jsx` | `Apps/iOS/BetterFitApp/Features/Profile/SettingsView.swift`, `Features/Theme/ThemePickerView.swift` |
| `ui_kits/ios_app/AppShell.jsx` | `Apps/iOS/BetterFitApp/Features/RootTab/RootTabView.swift` |
| `ui_kits/watch_app/WatchScreens.jsx` | `Apps/iOS/BetterFitWatchApp/WorkoutListView.swift`, `ActiveWorkoutView.swift`, `ContentView.swift` |
| `ui_kits/watch_app/WatchShell.jsx` | `Apps/iOS/BetterFitWatchApp/WatchTheme.swift` |
| `tokens/*.css` | `Apps/iOS/BetterFitApp/DesignSystem/BFColors.swift`, `BFTypography.swift`, `BFSpacing.swift`, `AppTheme.swift` |
| `design.md` | `design.md` (repo root) — diverged, see above |
| `components/**` | `Apps/iOS/BetterFitApp/DesignSystem/BFComponents.swift`, `BFButtonStyles.swift`, `BFRecovery.swift`, `UIComponents.swift`, `Features/**` |

## Sync history

- 2026-07-26 — built the token layer from `BFColors`/`BFTypography`/`BFSpacing`/`AppTheme`, authored 30 components mapped to the SwiftUI primitives, recreated the iPhone app as 7 screens and the Watch app as 3, copied the logo artwork and BBH Hegarty Regular into `assets/`.
