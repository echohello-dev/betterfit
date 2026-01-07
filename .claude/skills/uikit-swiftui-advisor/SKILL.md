---
name: uikit-swiftui-advisor
description: Advise on when to use UIKit vs SwiftUI for iOS development. Use when implementing complex UI features that may require UIViewRepresentable.
---

# UIKit vs SwiftUI Advisor Skill

Use this skill when deciding whether to implement a feature in pure SwiftUI or drop to UIKit via UIViewRepresentable.

## When to activate this skill

- User is implementing a complex UI feature and unsure which framework to use
- User encounters SwiftUI limitations (performance, gestures, text editing, etc.)
- User asks "should I use UIKit or SwiftUI for X?"
- User is building forms with multiple text fields
- User needs high-performance scrolling or layouts
- User is implementing custom camera, document scanning, or media features
- User needs advanced gestures (multi-finger, complex coordination)
- User asks about UIViewRepresentable or UIViewControllerRepresentable

## Decision workflow

### 1. Default to SwiftUI
Always start with SwiftUI unless you have a specific reason not to. Only drop to UIKit for documented limitations.

### 2. Check AGENTS.md first
Read AGENTS.md lines 11-72 for the current project guidance on SwiftUI vs UIKit.

### 3. Use tools to get context
If you need additional context beyond AGENTS.md:
- Use `mcp__exa__get_code_context_exa` for code examples and implementation patterns
- Use `mcp__ref__ref_search_documentation` for official SwiftUI/UIKit documentation
- Use `WebSearch` for iOS 26 feature updates or specific limitation research

### 4. Match against known limitations

**Use UIKit when:**

1. **Complex keyboard management** - Multi-field forms where @FocusState causes keyboard bounce, custom return key behavior needed
2. **Performance-critical scrolling** - 10,000+ items needing 120 FPS, or NavigationStack memory issues
3. **Multi-finger gestures** - 2-finger, 3-finger taps (TapGesture can't specify finger count)
4. **Camera/scanning** - Custom camera, document scanning (no native SwiftUI API)
5. **Complex compositional layouts** - Netflix-style carousels + grids with orthogonal scrolling
6. **Pinch-to-zoom photo viewers** - Proper content centering, insets, deceleration
7. **Real-time graphics** - Particle systems, physics animations, direct CALayer access

**iOS 26+ improvements to consider:**
- Native SwiftUI WebView (no longer need WKWebView wrapper)
- TextEditor supports AttributedString (bold, italic, colors)
- UIGestureRecognizerRepresentable (iOS 18+) for gesture bridging

### 5. Consider helper libraries
Before writing custom wrappers:
- **IQKeyboardManager** - Automatic keyboard management
- **Introspect** - Access underlying UIKit views from SwiftUI
- Use tools to search for relevant libraries: `mcp__exa__get_code_context_exa`

### 6. Provide implementation

**If SwiftUI:** Provide SwiftUI code directly.

**If UIKit needed:** Provide UIViewRepresentable wrapper following this pattern:

```swift
struct CustomUIKitView: UIViewRepresentable {
    @Binding var state: SomeState
    let config: Configuration

    func makeUIView(context: Context) -> SomeUIView {
        let view = SomeUIView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: SomeUIView, context: Context) {
        uiView.updateFromState(state, config: config)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, SomeDelegate {
        let parent: CustomUIKitView

        init(_ parent: CustomUIKitView) {
            self.parent = parent
        }

        func didUpdateValue(_ value: SomeValue) {
            parent.state = value
        }
    }
}
```

**UIKit interop rules:**
- Keep wrappers thin - logic lives in SwiftUI view models
- Use @Binding for state synchronization
- Extract reusable components (CustomTextField, DocumentScanner)
- Prefer UIHostingConfiguration for SwiftUI cells in UICollectionView (iOS 16+)

## Common code patterns

### CustomTextField with keyboard management
```swift
struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let returnKeyType: UIReturnKeyType
    let onReturn: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.returnKeyType = returnKeyType
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                parent.text = updatedText
            }
            return true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onReturn()
            return false
        }
    }
}
```

### Two-finger tap gesture
```swift
struct TwoFingerTapGesture: UIViewRepresentable {
    let onTwoFingerTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        gesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTwoFingerTap: onTwoFingerTap)
    }

    class Coordinator: NSObject {
        let onTwoFingerTap: () -> Void

        init(onTwoFingerTap: @escaping () -> Void) {
            self.onTwoFingerTap = onTwoFingerTap
        }

        @objc func handleTap() {
            onTwoFingerTap()
        }
    }
}
```

## BetterFit project context

Current features are appropriate for SwiftUI: workout lists, timers, cards, navigation.

**Watch for these scenarios:**
- Multi-step workout entry forms with many text fields → Consider UITextField wrappers
- 10,000+ workout history items → Consider UICollectionView
- Custom body map with multi-touch gestures → Consider UIGestureRecognizer
- Video player with custom controls → Consider AVPlayerViewController

## Quick decision checklist

- [ ] Read AGENTS.md SwiftUI vs UIKit section
- [ ] Ask user: What specific feature? What limitation hit? What iOS version?
- [ ] Check if pure SwiftUI can handle it
- [ ] Use tools (exa/ref/WebSearch) for additional context if needed
- [ ] Match against known limitations above
- [ ] Recommend approach with clear rationale
- [ ] Provide working code (SwiftUI or UIViewRepresentable)
- [ ] Suggest helper libraries if applicable
