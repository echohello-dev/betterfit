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

## Library docs

- [API Reference](api.md)
- [Usage Examples](examples.md)
