---
name: swiftui-reactivity
description: Prevent unwanted re-renders in SwiftUI by extracting high-frequency state into isolated child components. Use when views flicker, performance degrades, or @State updates cascade to siblings.
---

# BetterFit SwiftUI Reactivity Skill

Use this skill when SwiftUI views re-render too frequently, causing flickering or performance issues.

## When to activate this skill

- Views flicker during animations or gestures
- Timer/animation loops cause cascading re-renders
- Drag gestures make unrelated UI elements update
- Performance profiling shows excessive body evaluations
- User mentions "flickering", "jitter", or "lag" in SwiftUI
- `@State` property changes trigger parent/sibling re-renders unnecessarily

## The Problem

Reading frequently-changing `@State` in a computed property causes SwiftUI to re-evaluate that property on every state change. This cascades to all sibling views in the same parent.

**Example problems:**
- `elapsedTimeUpdateTrigger` toggled 100x/second → parent re-renders entire view hierarchy
- `cardSwipeOffset` updated every frame during drag → unrelated sections flicker
- Timer callbacks updating `@State` → entire list redraws

## The Solution: Reactivity Boundaries

Extract the view that reads the frequently-changing state into its own child component with `@Binding`. This creates a "reactivity boundary" — only the child re-renders, not the parent or siblings.

### Pattern

```swift
// Parent (WorkoutHomeView)
@State var elapsedTimeUpdateTrigger = false

var compactWelcomeSection: some View {
    // Isolated child—only this component re-renders on timer ticks
    ElapsedTimeDisplay(
        elapsedTimeUpdateTrigger: $elapsedTimeUpdateTrigger,
        startTime: workoutStartTime
    )
}

// Child (private struct)
private struct ElapsedTimeDisplay: View {
    @Binding var elapsedTimeUpdateTrigger: Bool
    let startTime: Date
    
    var body: some View {
        let _ = elapsedTimeUpdateTrigger  // Force read on every state change
        // Only this view re-renders, not parent siblings
        Text(formatElapsed(since: startTime))
            .font(.system(.title2, design: .rounded, weight: .bold))
    }
}
```

### Key rules

1. **Move state to child**: Use `@State private` in the child component
2. **Pass binding from parent**: `$propertyName` creates the binding
3. **Child reads the binding**: The `let _ = trigger` pattern forces SwiftUI to track the dependency
4. **Only child re-renders**: Parent and siblings are isolated from the high-frequency updates

## When to extract

| Scenario | Extract? | Pattern |
|----------|----------|---------|
| Timer/animation >10x/sec | ✅ Yes | Extract to child with `@Binding` |
| Drag gesture updating every frame | ✅ Yes | Extract to child with `@Binding` |
| Stable state (changes on user tap) | ❌ No | Keep in parent as computed property |
| Text input with @State | ❌ No | SwiftUI handles this natively |
| Scroll position tracking | ⚠️ Consider | Use `onChange` or `@StateObject` |

## Anti-patterns to avoid

### ❌ Reading high-frequency state in parent
```swift
struct BadExample: View {
    @State var timerTick = false
    
    var body: some View {
        let _ = timerTick  // DON'T: Entire body re-renders 100x/sec
        VStack {
            TimerDisplay()     // Re-renders unnecessarily
            TargetMuscles()    // Re-renders unnecessarily
            WorkoutList()      // Re-renders unnecessarily
        }
    }
}
```

### ✅ Isolating in child component
```swift
struct GoodExample: View {
    @State var timerTick = false
    
    var body: some View {
        VStack {
            TimerDisplay(trigger: $timerTick)  // Only this re-renders
            TargetMuscles()                      // Stable
            WorkoutList()                        // Stable
        }
    }
}
```

## Common scenarios

### Timer-triggered updates
```swift
// Parent
@State private var elapsedTimeTrigger = false

private let timer = Timer.publish(every: 0.1, on: .main, in: .common)
    .autoconnect()

var body: some View {
    ElapsedTimeView(trigger: $elapsedTimeTrigger)
        .onReceive(timer) { _ in
            elapsedTimeTrigger.toggle()
        }
}

// Child
private struct ElapsedTimeView: View {
    @Binding var trigger: Bool
    let startTime: Date
    
    var body: some View {
        let _ = trigger
        Text(formatElapsed(since: startTime))
    }
}
```

### Drag gesture offset
```swift
// Parent
@State private var cardOffset: CGSize = .zero

var body: some View {
    SwipeableCard(offset: $cardOffset)
    RelatedInfo()  // Won't re-render during swipe
}

// Child
private struct SwipeableCard: View {
    @Binding var offset: CGSize
    
    var body: some View {
        CardContent()
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { offset = $0.translation }
            )
    }
}
```

## Performance checklist

- [ ] Profile with SwiftUI Instruments to find excessive body evaluations
- [ ] Identify which `@State` properties change most frequently
- [ ] Check if parent computed properties read high-frequency state
- [ ] Extract high-frequency readers into child components
- [ ] Verify siblings no longer re-render (use `.printChanges()`)
- [ ] Don't over-extract: stable state can stay in parent
