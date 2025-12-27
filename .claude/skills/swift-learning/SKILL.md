---
name: swift-ios-teaching
description: Teach Swift and iOS 26 development to experienced React/Next.js developers
---

# Swift & iOS Teaching Skill

Use this skill whenever the user asks about Swift language features, SwiftUI patterns, iOS development concepts, or needs help understanding code in this project. Always explain concepts by relating them to React, Next.js, and cloud/backend patterns.

## When to activate this skill

- User asks "how does X work in Swift?"
- User is confused by Swift syntax or SwiftUI patterns
- User asks to compare Swift to TypeScript/JavaScript
- User needs help understanding Xcode, schemes, or build concepts
- User is implementing a new SwiftUI view or feature
- User asks about iOS 26-specific features (Liquid Glass, etc.)

## Core mental model mappings

Always use these analogies when explaining:

### SwiftUI → React
| Swift | React | Quick explanation |
|-------|-------|-------------------|
| `@State` | `useState` | Local view state |
| `@Binding` | Passing `setState` as prop | Two-way binding to parent |
| `@Environment` | `useContext` | Inject values down tree |
| `@Observable` | Zustand/Jotai store | Observed class instance |
| `var body: some View` | `return <JSX>` | Declarative render |
| `.onAppear` | `useEffect(() => {}, [])` | Mount effect |
| `.task` | `useEffect` + async | Async effect with auto-cancel |
| `.onChange(of:)` | `useEffect(() => {}, [dep])` | Effect on dep change |
| `ForEach` | `.map()` | Iterate with identity |
| `NavigationStack` | React Router / Next.js router | Declarative routing |
| View modifiers | Styled-components / Tailwind | Chained styling |

### Swift → TypeScript
| Swift | TypeScript |
|-------|------------|
| `let x: String` | `const x: string` |
| `var x: Int` | `let x: number` |
| `String?` | `string \| null` |
| `??` | `??` (nullish coalescing) |
| `?.` | `?.` (optional chaining) |
| `protocol` | `interface` |
| `struct` | Plain object (value semantics) |
| `class` | `class` (reference semantics) |
| `enum` with associated values | Discriminated union |
| `async/await` | `async/await` |
| `throws` | Function that can throw |

## Teaching approach

1. **Start with the familiar**: "This is like X in React..."
2. **Show the Swift way**: Provide concise code example
3. **Highlight differences**: What's different and why it matters
4. **Warn about gotchas**: Common mistakes React devs make

## Common gotchas to proactively mention

When relevant, warn about these:

1. **Modifier order matters**: `.padding().background()` ≠ `.background().padding()`
2. **Structs are copied**: Assigning a struct creates a copy, not a reference
3. **`@State` must be private**: The view owns it; share via `@Binding`
4. **No virtual DOM**: SwiftUI diffs directly; views are value types
5. **`body` is computed**: Don't do side effects in `body`
6. **ARC memory**: Use `[weak self]` in closures to avoid retain cycles
7. **Strong typing**: No `any` escape hatch; embrace protocols

## iOS 26 specifics

When discussing iOS 26 features:

- **Liquid Glass**: New design language with `.glassEffect()` modifier
- **Always use `@available`**: Gate iOS 26 APIs with availability checks
- **Materials**: `.ultraThinMaterial`, `.regularMaterial`, `.thickMaterial`

## Project-specific context

This BetterFit project:

- SwiftPM library in `Sources/BetterFit/`
- iOS host app in `Apps/iOS/BetterFitApp/`
- watchOS app in `Apps/iOS/BetterFitWatchApp/`
- Uses facade pattern (`BetterFit.swift`) for DI (like NestJS module)
- Feature-based organization (like Next.js `app/` directory)
- Custom UI primitives: `BFCard`, `LiquidGlassBackground`, etc.

## Build commands to reference

```bash
mise run build          # swift build
mise run test           # swift test
mise run lint           # swiftlint
mise run ios:open       # Open Xcode project
mise run ios:build:dev  # Build for development
```

## Example teaching response format

When explaining a concept:

```
**In React terms**: This is like `useState` - it's local state owned by the component.

**Swift version**:
```swift
@State private var count = 0
```

**Key difference**: In Swift, `@State` must be `private` because the view owns the source of truth. To share state with children, you pass a `@Binding` (similar to passing `setState` as a prop).

**Watch out**: Unlike React's `useState`, mutating `@State` triggers an immediate re-render synchronously.
```

## Full reference

For comprehensive mappings, see:
`.github/instructions/learning-swift.instructions.md`
