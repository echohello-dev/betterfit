# BetterFit

> **Train with direction. Get better with every session.**
>
> A personal strength-training coach for iPhone and Apple Watch. BetterFit turns workout history, performance, and recovery into a clear next action.

[![The BetterFit Workout tab — identity mark, weekly conclusion, next session, and one-tap start.](docs/assets/screenshots/workout-home@2x.png)](docs/assets/screenshots/workout-home@2x.png)

*Lead with the next action: the Workout tab opens on what you're about to do.*

---

## What it is, really

BetterFit is a calm, dark-first training surface for iPhone and Apple Watch. It helps you decide what to train, move through a session with less friction, understand recovery, and keep building momentum. It speaks like a knowledgeable training partner standing nearby — short, direct, useful — never a drill sergeant, an influencer, a clinical dashboard, or a neon fitness game.

The interface is built around a single rule: **lead with the next action or conclusion**. Stats are context, never the headline. Recovery is colour *and* text, never colour alone. Identity yellow is reserved for brand moments; ordinary product screens use ember for the one primary action.

---

## A look inside

[![The Plan tab — week strip, today's workout, exercises with sets and weight, and recovery state per muscle.](docs/assets/screenshots/plan-week@2x.png)](docs/assets/screenshots/plan-week@2x.png)
**Plan your week, see what's sore.** The week strip selects a day; today's exercises carry sets and target weight; the body-map companion shows recovery in colour and a written headline.

[![The Me tab — guest avatar using the brand mark, account CTA, health overview, and 24-day streak.](docs/assets/screenshots/profile-health@2x.png)](docs/assets/screenshots/profile-health@2x.png)
**Health overview that reads in one glance.** BMI, strength score, resting HR, active calories — each card leads with the value and a short label. Recovery dots sit on the streak card with semantic colour plus a written status.

---

## What you can do with it

- **Decide what to train.** Recommended sessions pull from your plan, history, equipment, and recovery.
- **Run it on your wrist.** The watchOS companion ships big buttons, sets/reps on the wrist, haptics on set completion, and a rest timer that survives the screen-off state.
- **Adapt as you go.** The AI adaptation engine adjusts volume, intensity, and exercise selection based on what you actually completed.
- **See recovery, not just history.** A full body-map view of muscle recovery with semantic colour and accessible labels.
- **Swap equipment on the fly.** Barbell taken? The equipment swap manager suggests equivalents from what you have available.
- **Reminders that respect you.** Personalised workout reminders with snooze, never shaming, never missable.

---

## Architecture

```
Apps/iOS/
  BetterFitApp/        # SwiftUI host app (iPhone + iPad)
  BetterFitWatchApp/   # SwiftUI watchOS companion
Sources/BetterFit/      # Public SwiftPM library
```

BetterFit ships as a Swift Package. The same `BetterFit` library powers the iOS host app, the watchOS companion, and any future embed of the coach experience.

```swift
import BetterFit

let betterFit = BetterFit(persistenceService: LocalPersistenceService())
let plan = betterFit.planManager.generatePlan(for: .hypertrophy)
betterFit.startWorkout(plan.workouts[0])
betterFit.completeWorkout(plan.workouts[0])
```

The full API surface is documented in [`docs/api.md`](docs/api.md) with usage examples in [`docs/examples.md`](docs/examples.md).

---

## Install (SwiftPM)

```swift
dependencies: [
    .package(url: "https://github.com/echohello-dev/betterfit.git", from: "1.0.0")
]
```

## Run the apps

### iOS

```bash
mise run ios:open       # XcodeGen + open in Xcode
mise run ios:build:dev   # CLI build for the iPhone simulator
```

### Apple Watch

```bash
mise run watch:open     # open the watch target
mise run watch:build
```

See [`docs/README.md`](docs/README.md) for the full setup, troubleshooting, and pipeline scripts.

## Development workflow

```bash
mise install            # install pinned tools (swift, xcodegen, swiftlint, etc.)
mise run lint           # fast style feedback
mise run test           # 95 SwiftPM tests
mise run ios:test:ui    # XCUITest on the iPhone simulator
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contributor guide and the [design system](design.md) for the visual rules.

---

## License

BetterFit is licensed under a BSD 3-Clause License with branding protection.
You're free to use, modify, and distribute this code commercially, but must
maintain the "BetterFit" branding for deployments over 50 users.

For enterprise white-label licensing, contact: business@echohello.dev

See [LICENSE](LICENSE) for full terms.