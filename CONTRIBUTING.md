# Contributing

We welcome contributions to BetterFit! By contributing, you help make this project better for everyone.

## Contributor License Agreement (CLA)

By contributing to this project after December 29, 2025, you agree to:

- License your contributions under the [BSD 3-Clause License with Branding Protection](LICENSE)
- Acknowledge that echoHello may use your contributions in both the open-source version and any commercial offerings
- Grant echoHello the right to relicense your contributions as needed for commercial purposes

**Note:** All contributions made before December 29, 2025 remain under their original MIT license terms.

## How to Contribute

1. **Fork the repository** and create a new branch for your feature/fix
2. **Make your changes** following our code style (see below)
3. **Test your changes** - run `mise run test` and verify iOS/watch apps work
4. **Submit a pull request** with a clear description of what you've changed and why

## Code Style

- Follow Swift API Design Guidelines
- Use `// MARK:` to organize code into navigable sections
- Keep view files focused and split when they exceed ~300-500 lines
- Prefer native iOS APIs over custom solutions
- See [AGENTS.md](AGENTS.md) for detailed coding philosophy

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

## Run the watch app (Simulator)

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

### Build from the CLI

```bash
mise run watch:build
```

## Docs

- High-level entrypoint: `README.md` (root)
- Reference material lives in `docs/`
- iOS Simulator run steps live in `docs/README.md`
