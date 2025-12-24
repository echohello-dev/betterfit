# BetterFit

BetterFit is a Swift Package (library) for building a strength training coach experience (iOS + Apple Watch).

## Docs

- [docs/readme.md](docs/readme.md)
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

```bash
mise run build
mise run test
```

## Run on Simulator

The runnable iOS host app lives in `Apps/iOS` (generated via XcodeGen).

```bash
mise run ios:open
```
