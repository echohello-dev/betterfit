# BetterFit (iOS host app)

This is a tiny iOS host app used to run the BetterFit Swift package on the iOS Simulator.

It includes two installable variants:

- **BetterFit** (Prod)
- **BetterFit Dev** (Dev)

## Generate the Xcode project

If you don’t have XcodeGen installed:

```bash
brew install xcodegen
```

Then from the repo root:

```bash
cd Apps/iOS
xcodegen generate
```

This will generate `BetterFit.xcodeproj` in this folder.

## Run on Simulator

```bash
open BetterFit.xcodeproj
```

Or use mise from the repo root:

```bash
mise run ios:open
```

In Xcode:

1. Select a scheme: **BetterFit** or **BetterFitDev**.
2. Select an iPhone Simulator (top toolbar).
3. Press **Run** (▶︎).

Xcode will build, install, and launch the app in Simulator.
