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

## Running the app

For detailed instructions on running iOS and watchOS apps, including simulators and troubleshooting, see:

- **[Local Development Guide](docs/local-development.md)** - Complete setup and common tasks
- **[Main Docs](docs/README.md)** - iOS and watchOS simulator instructions

## Documentation

- **[Local Development Guide](docs/local-development.md)** - Setup, environment variables, common tasks
- **[Docs Index](docs/README.md)** - API reference, examples, iOS/watchOS run instructions
- **[Authentication Guide](docs/auth.md)** - Auth methods and configuration
- **[Root README](../README.md)** - Project overview
- **[AGENTS.md](AGENTS.md)** - Code organization and philosophy
