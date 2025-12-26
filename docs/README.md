# BetterFit Docs

## Run the app (iOS Simulator)

BetterFit is a Swift Package (library). To run something on Simulator, use the iOS host app in `Apps/iOS`.

### Prereqs

- Xcode (Simulator)
- XcodeGen (`brew install xcodegen`) if you’re not using `mise` tasks

### Open in Xcode (recommended)

From the repo root:

```bash
mise run ios:open
```

In Xcode:

1. Pick a scheme: **BetterFit** (Prod) or **BetterFitDev** (Dev)
2. Pick an iPhone Simulator
3. Press **Run**

### Generate the Xcode project only

```bash
mise run ios:gen
```

### Build from the CLI (no UI)

```bash
mise run ios:build:prod
mise run ios:build:dev
```

### Troubleshooting

- If Simulator is acting up:

```bash
mise run ios:sim:reset
```

## Run the app (watchOS Simulator)

The watch app lives in `Apps/iOS` and is generated via XcodeGen.

### Boot the watch simulator

```bash
mise run watch:sim:boot
```

### Open in Xcode (recommended)

```bash
mise run watch:open
```

In Xcode:

1. Pick scheme: **BetterFitWatch**
2. Pick a paired destination (an iPhone Simulator + an Apple Watch Simulator)
3. Press **Run**

### Build from the CLI (no UI)

```bash
mise run watch:build
```

## Library docs

- [API Reference](api.md)
- [Usage Examples](examples.md)
