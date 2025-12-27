---
applyTo: '**/*.swift, **/*.swiftpm, **/*.xcodeproj, **/*.xcworkspace'
---

# Learning Swift & iOS 26 for React/Next.js Developers

When teaching Swift and iOS development concepts, always relate them to React, Next.js, and cloud/backend patterns the user already knows. Use analogies and comparisons to accelerate understanding.

---

## Mental Model Mapping

### SwiftUI ↔ React

| React Concept | Swift/SwiftUI Equivalent | Notes |
|---------------|--------------------------|-------|
| JSX | SwiftUI's declarative syntax | Both describe UI as a function of state |
| `useState` | `@State` | Local component/view state |
| `useContext` | `@Environment` / `@EnvironmentObject` | Dependency injection down the tree |
| `props` | View initializer parameters | Pass data down; Swift uses labeled params |
| `useEffect` | `.onAppear`, `.onChange`, `.task` | Side effects tied to lifecycle |
| `useMemo` | Computed properties | Derived values, automatically cached |
| `useCallback` | Closures (stored or inline) | Swift closures are first-class |
| `children` / `slots` | `@ViewBuilder` closures | Compose child views |
| Conditional rendering (`{condition && <X/>}`) | `if`/`else` inside `body` | Swift uses control flow directly |
| `.map()` for lists | `ForEach` | Iterate over collections in views |
| `key` prop | `id:` parameter in `ForEach` | Identity for diffing |
| Higher-order components | View modifiers / `ViewModifier` protocol | Wrap and extend views |
| React Context Provider | `.environment()` / `.environmentObject()` | Inject dependencies |
| `React.memo` | SwiftUI's automatic diffing | Views re-render only when inputs change |
| Suspense / lazy loading | `LazyVStack`, `LazyHStack`, `.task` | Defer work until needed |

### Next.js ↔ iOS App Architecture

| Next.js Concept | iOS Equivalent | Notes |
|-----------------|----------------|-------|
| `pages/` or `app/` router | `NavigationStack` / `NavigationSplitView` | Declarative navigation |
| `getServerSideProps` | `.task` with async/await | Fetch data when view appears |
| `getStaticProps` | Preloaded model data or `@Query` (SwiftData) | Data available at "build" time |
| API routes | No direct equivalent (use Services layer) | iOS apps call external APIs |
| Middleware | View modifiers, `NavigationDestination` | Intercept/transform at boundaries |
| `_app.tsx` / `layout.tsx` | `@main App` struct, `WindowGroup` | Root entry point |
| `useRouter` | `@Environment(\.dismiss)`, `NavigationPath` | Programmatic navigation |
| Dynamic routes `[id]` | `.navigationDestination(for:)` | Type-safe route params |
| ISR / caching | `URLCache`, SwiftData, `@Query` | Persist and cache data |
| Environment variables | `Info.plist`, `xcconfig`, `ProcessInfo` | Build-time and runtime config |

### Cloud/Backend ↔ Swift Patterns

| Cloud/Backend Concept | Swift Equivalent | Notes |
|-----------------------|------------------|-------|
| Dependency injection (NestJS, Spring) | Protocol + Environment | Define protocols, inject via `@Environment` |
| Repository pattern | Manager classes (e.g., `PlanManager`) | Abstract data access |
| DTOs / Models | `struct` with `Codable` | Value types, JSON serialization built-in |
| Async/await (Node, Python) | `async`/`await` (native Swift) | Identical mental model |
| Promises | `Task`, `async let`, `TaskGroup` | Structured concurrency |
| Middleware chain | View modifier chain | `.modifier1().modifier2()` |
| Event emitters | `Combine` publishers, `@Observable` | Reactive streams |
| Singleton services | `static let shared` or `@Environment` | Prefer environment for testability |
| Error handling (`try/catch`) | `do { try } catch`, `Result<T, E>` | Swift uses throwing functions |
| Generics | Generics (`<T>`, `some Protocol`, `any Protocol`) | Very similar to TypeScript generics |

---

## Swift Language Essentials (for JS/TS developers)

### Type System
```swift
// Swift is statically typed like TypeScript
let name: String = "Johnny"      // const name: string = "Johnny"
var count: Int = 0               // let count: number = 0

// Type inference works like TS
let inferred = "Hello"           // inferred as String

// Optionals = T | null | undefined
var maybe: String? = nil         // let maybe: string | null = null
let unwrapped = maybe ?? "default"  // nullish coalescing, same as ??

// Optional chaining, same as ?.
let length = maybe?.count
```

### Structs vs Classes
```swift
// Structs = value types (like spreading objects in JS)
struct User {
    var name: String
    var age: Int
}
var user1 = User(name: "A", age: 30)
var user2 = user1  // COPY, not reference
user2.name = "B"   // user1.name is still "A"

// Classes = reference types (like JS objects)
class UserClass {
    var name: String
    init(name: String) { self.name = name }
}
```

**Rule of thumb**: Use `struct` for data/models, `class` for identity-based objects or when you need inheritance.

### Closures (Lambdas/Arrow Functions)
```swift
// Swift closure syntax
let add: (Int, Int) -> Int = { a, b in a + b }

// Trailing closure syntax (very common in SwiftUI)
Button("Tap") {
    print("Tapped")
}
// Equivalent to: Button("Tap", action: { print("Tapped") })

// Capture semantics: [weak self] prevents retain cycles (like cleanup in useEffect)
someAsyncCall { [weak self] result in
    self?.handleResult(result)
}
```

### Protocols (Interfaces)
```swift
// Protocol = TypeScript interface
protocol Identifiable {
    var id: String { get }
}

struct Item: Identifiable {
    let id: String
    let name: String
}

// Protocol with associated type = generic interface
protocol Repository {
    associatedtype Model
    func fetch(id: String) async throws -> Model
}
```

### Enums (Algebraic Data Types)
```swift
// Swift enums are MUCH more powerful than TS enums
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
}

// Pattern matching (like switch but exhaustive)
switch state {
case .idle:
    Text("Ready")
case .loading:
    ProgressView()
case .success(let data):
    DataView(data: data)
case .failure(let error):
    ErrorView(error: error)
}
```

### Async/Await & Structured Concurrency
```swift
// Identical to JS async/await
func fetchUser() async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// Parallel execution (like Promise.all)
async let user = fetchUser()
async let posts = fetchPosts()
let (u, p) = await (try user, try posts)

// Task = detached async work (like spawning a promise)
Task {
    await doSomething()
}
```

---

## SwiftUI Fundamentals

### Basic View Structure
```swift
// Think of this as a React functional component
struct GreetingView: View {
    // @State = useState
    @State private var count = 0
    
    // Props (passed via initializer)
    let name: String
    
    // body = render() / return JSX
    var body: some View {
        VStack {  // Like <div style={{ display: 'flex', flexDirection: 'column' }}>
            Text("Hello, \(name)!")
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

### Property Wrappers (State Management)

```swift
// @State - local state, owned by this view (useState)
@State private var text = ""

// @Binding - two-way binding to parent's state (like passing setState down)
@Binding var isOn: Bool

// @StateObject - owns an ObservableObject (useState with class instance)
@StateObject private var viewModel = MyViewModel()

// @ObservedObject - observes but doesn't own (prop that's an observable)
@ObservedObject var viewModel: MyViewModel

// @EnvironmentObject - global state from context (useContext)
@EnvironmentObject var appState: AppState

// @Environment - system-provided values (useContext for system stuff)
@Environment(\.colorScheme) var colorScheme
@Environment(\.dismiss) var dismiss

// iOS 17+: @Observable macro (simpler than ObservableObject)
@Observable class Counter {
    var count = 0  // Automatically tracked
}
```

### View Modifiers (Like Styled Components / Tailwind)
```swift
Text("Hello")
    .font(.title)                    // fontSize
    .foregroundStyle(.blue)          // color
    .padding()                        // padding: 16px (default)
    .background(.gray.opacity(0.2))  // backgroundColor
    .clipShape(RoundedRectangle(cornerRadius: 8))  // borderRadius
    
// Modifiers chain and order matters (like CSS specificity)
// .padding().background() ≠ .background().padding()
```

### Navigation (React Router / Next.js Router)
```swift
// NavigationStack = BrowserRouter + Routes
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {  // <Link to={...}>
            Text(item.name)
        }
    }
    .navigationDestination(for: Item.self) { item in
        // This is like your route component
        ItemDetailView(item: item)
    }
}

// Programmatic navigation
@Environment(\.dismiss) var dismiss  // Like router.back()
dismiss()

// Or with NavigationPath (like router.push)
@State private var path = NavigationPath()
path.append(someItem)  // Navigate to item
```

### Lists & ForEach (map + key)
```swift
// ForEach = .map() with automatic keys
List {
    ForEach(items) { item in  // item must be Identifiable (have id)
        RowView(item: item)
    }
}

// Or with explicit id
ForEach(items, id: \.name) { item in
    Text(item.name)
}

// Sections (like grouping in React)
List {
    Section("Active") {
        ForEach(activeItems) { ... }
    }
    Section("Completed") {
        ForEach(completedItems) { ... }
    }
}
```

### Side Effects
```swift
// .onAppear = useEffect with [] deps
.onAppear {
    loadData()
}

// .task = useEffect with async support + auto-cancellation
.task {
    await fetchData()  // Cancelled if view disappears
}

// .onChange = useEffect with [dep] 
.onChange(of: searchText) { oldValue, newValue in
    performSearch(newValue)
}

// .onDisappear = useEffect cleanup
.onDisappear {
    cleanup()
}
```

---

## iOS 26 Specific Features

### Liquid Glass Design Language
iOS 26 introduces a new "Liquid Glass" design system. Think of it as Apple's new design tokens.

```swift
// Glass material backgrounds
.background(.ultraThinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)

// New in iOS 26: glassEffect modifier
@available(iOS 26.0, *)
.glassEffect()  // Applies liquid glass styling

// Vibrancy for text on glass
.foregroundStyle(.secondary)  // Automatically adapts to glass
```

### Modern App Structure
```swift
@main
struct BetterFitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// WindowGroup = your app's main window (like _app.tsx)
// Scene = top-level container (can have multiple for iPad)
```

### SwiftData (Like Prisma/Drizzle for iOS)
```swift
// Define model with @Model macro
@Model
class Workout {
    var name: String
    var date: Date
    var exercises: [Exercise]
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
        self.exercises = []
    }
}

// Query in views (like useQuery from React Query)
@Query var workouts: [Workout]

// Or with sorting/filtering
@Query(sort: \.date, order: .reverse)
var recentWorkouts: [Workout]

// Insert/update via modelContext
@Environment(\.modelContext) var context
context.insert(newWorkout)
try context.save()
```

---

## Project Structure Patterns

### Feature-Based Organization (Like Next.js app/ directory)
```
Sources/BetterFit/
├── Features/           # Feature modules (like app/(features)/)
│   ├── BodyMap/
│   │   └── BodyMapManager.swift
│   ├── PlanMode/
│   │   ├── PlanManager.swift
│   │   └── TrainingPlan.swift
├── Models/             # Domain models (like types/ or models/)
│   ├── Exercise.swift
│   └── Workout.swift
├── Services/           # Business logic (like lib/ or services/)
│   └── AI/
│       └── AIAdaptationService.swift
└── BetterFit.swift     # Facade/orchestrator (like a DI container)
```

### Dependency Injection Pattern
```swift
// This project uses a facade pattern (BetterFit.swift)
// Similar to a NestJS module or Next.js context provider

public final class BetterFit {
    public let planManager: PlanManager
    public let bodyMapManager: BodyMapManager
    public let socialManager: SocialManager
    
    public init() {
        self.planManager = PlanManager()
        self.bodyMapManager = BodyMapManager()
        self.socialManager = SocialManager()
    }
    
    // Orchestrates cross-feature flows
    public func completeWorkout(_ workout: Workout) {
        // Updates multiple managers atomically
    }
}

// In SwiftUI, inject via environment
ContentView()
    .environmentObject(betterFit)
```

---

## Common Gotchas for React Developers

1. **No Virtual DOM**: SwiftUI diffs the view tree directly. Views are value types (structs), recreated frequently but diffed efficiently.

2. **`body` is a computed property**: It's called whenever state changes. Don't do side effects here (same as render in React).

3. **Modifiers return new views**: Each `.modifier()` wraps the view. Order matters!

4. **`@State` must be `private`**: The view owns it. To share, pass as `@Binding` or use `@Observable`.

5. **No JSX string interpolation for views**: Use `\(variable)` in Text, not `{variable}`.

6. **Strong typing everywhere**: No `any` escape hatch. Embrace protocols and generics.

7. **Memory management**: Swift uses ARC (Automatic Reference Counting). Use `[weak self]` in closures to avoid retain cycles.

8. **No CSS**: All styling via view modifiers. No external stylesheets.

9. **Previews = Storybook**: Use `#Preview` macro to see live UI during development.

```swift
#Preview {
    MyView()
        .environmentObject(MockData())
}
```

---

## Build & Run Commands (mise tasks)

```bash
mise run build      # swift build (compile the SwiftPM library)
mise run test       # swift test (run unit tests)
mise run lint       # swiftlint (like eslint)
mise run ios:open   # Generate and open Xcode project
mise run ios:build:dev   # Build iOS app for development
mise run ios:build:prod  # Build iOS app for production
mise run watch:open      # Open watchOS project
```

---

## AI Instructions for Code Generation

When generating Swift/SwiftUI code for this user:

1. **Draw parallels**: Always explain new concepts by comparing to React/Next.js equivalents
2. **Use modern Swift**: Prefer `@Observable` (iOS 17+), `async/await`, `some View`
3. **Follow project conventions**: See AGENTS.md for file organization, `// MARK:` usage, and splitting large files
4. **Prefer structs**: Use value types for models and views
5. **Use protocol-oriented design**: Define protocols for dependencies, inject via environment
6. **Explain Xcode-specific concepts**: Schemes, targets, signing, provisioning when relevant
7. **iOS 26 awareness**: This project targets iOS 26; use new APIs when appropriate with `@available` checks
8. **Error handling**: Use `do/try/catch` and `Result` types; explain how they map to try/catch in JS