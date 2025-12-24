# Contributing

## Dev setup

### Prereqs

- Xcode (for iOS Simulator)
- `mise` (recommended)
- XcodeGen (only needed if you don’t use the `mise` tasks): `brew install xcodegen`

### Install tools

From the repo root:

```bash
mise install
```

### Build + test

```bash
mise run build
mise run test
```

## Run the iOS host app (Simulator)

BetterFit is a Swift Package (library). The runnable iOS host app lives in `Apps/iOS` and is generated via XcodeGen.

### Open in Xcode (recommended)

```bash
mise run ios:open
```

In Xcode:

1. Pick a scheme: **BetterFit** (Prod) or **BetterFitDev** (Dev)
2. Pick an iPhone Simulator
3. Press **Run**

### Generate the project only

```bash
mise run ios:gen
```

### Build from the CLI

```bash
mise run ios:build:prod
mise run ios:build:dev
```

### Simulator troubleshooting

```bash
mise run ios:sim:reset
```

## Docs

- High-level entrypoint: `README.md` (root)
- Reference material lives in `docs/`
- iOS Simulator run steps live in `docs/README.md`
