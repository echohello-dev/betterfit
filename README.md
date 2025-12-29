# BetterFit

BetterFit is a Swift Package (library) for building a strength training coach experience (iOS + Apple Watch).

## Features

- 📱 **iOS App**: Full-featured strength training coach with AI adaptation
- ⌚ **Apple Watch App**: Workout tracking with easy-to-use buttons, set/rep tracking, and notification reminders
- 🤖 **AI Adaptation**: Smart workout recommendations based on performance
- 📊 **Recovery Tracking**: Body map visualization of muscle recovery
- 🔔 **Smart Notifications**: Personalized workout reminders
- 📝 **Templates & Plans**: Reusable workout templates and training plans
- 🔄 **Equipment Swapping**: Fast alternatives when equipment unavailable

## Docs

- [docs/README.md](docs/README.md)
- [docs/api.md](docs/api.md)
- [docs/examples.md](docs/examples.md)

## Install (SwiftPM)

```swift
dependencies: [
  .package(url: "https://github.com/echohello-dev/betterfit.git", from: "1.0.0")
]
```

## Quick usage

```swift
import BetterFit

let betterFit = BetterFit()
// Use managers/services, e.g. templates, plans, recovery, auto-tracking
```

## Development

Dev setup and contributor workflow live in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

BetterFit is licensed under a BSD 3-Clause License with branding protection.
You're free to use, modify, and distribute this code commercially, but must
maintain the "BetterFit" branding for deployments over 50 users.

For enterprise white-label licensing, contact: business@echohello.dev

See [LICENSE](LICENSE) for full terms.

## Run Apps

### iOS App
```bash
# Open in Xcode
mise run ios:open

# Build for simulator
mise run ios:build:prod
```

### Apple Watch App
```bash
# Open in Xcode
mise run watch:open

# Build for watch simulator
mise run watch:build
```

See [Apps/iOS/BetterFitWatchApp/README.md](Apps/iOS/BetterFitWatchApp/README.md) for detailed watch app documentation.

## Run on Simulator

See [docs/README.md](docs/README.md) (or [CONTRIBUTING.md](CONTRIBUTING.md)) for the iOS Simulator instructions.
