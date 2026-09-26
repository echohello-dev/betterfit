# BetterFit Apple Watch — UI kit

Three screens, recreated from `Apps/iOS/BetterFitWatchApp/`:

| Screen | Source |
| --- | --- |
| `WatchList` — today's session + workout list | `WorkoutListView.swift`, `ContentView.swift` |
| `WatchActive` — elapsed timer, current set, log/pause/end | `ActiveWorkoutView.swift` |
| `WatchSummary` — completion stats and recovery change | `ActiveWorkoutView.swift` (CompleteWorkoutView) |

Watch rules that differ from iPhone:

- Controls are full width and at least 44px tall — `WatchButton`, not the phone `Button`.
- Screen is 198×242 CSS px here, standing in for the 45mm 396×484 point display at 2×.
- Palette is the same two-colour system as the phone, with the slightly stronger 10%-white border `WatchTheme.swift` uses.
- Timer and load values dominate; labels shrink to 9–11px because they are glanceable, not readable copy.
- One yellow identity block per session (today's card); everything else is dark surface.
