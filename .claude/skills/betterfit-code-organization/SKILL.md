---
name: betterfit-code-organization
description: Organize Swift code with MARK comments and consistent file structure. Use when refactoring, creating new files, or improving code navigability.
---

# BetterFit Code Organization Skill

Use this skill when organizing Swift files, adding MARK comments, or improving code navigability.

## When to activate this skill

- Creating a new SwiftUI view or screen
- Refactoring existing code for better organization
- File has grown large and needs section markers
- User asks about code style or file structure
- Code review feedback mentions organization
- Want to improve Xcode minimap/navigability

## MARK comment conventions

Use `// MARK: - ...` to group related code into navigable sections.

### Rules

- Use `// MARK:` **above declarations** (computed properties, functions, nested types)
- **Don't** put MARKs inside view builder closures
- Keep marks short and consistent
- Add them when a file has multiple logical blocks

### SwiftUI view ordering

```swift
struct WorkoutHomeView: View {
    
    // MARK: - State
    @State private var workouts: [Workout] = []
    @State private var searchText = ""
    @StateObject private var viewModel = WorkoutViewModel()
    
    // MARK: - Dependencies
    let betterFit: BetterFit
    let theme: AppTheme
    
    // MARK: - Init
    init(betterFit: BetterFit, theme: AppTheme) {
        self.betterFit = betterFit
        self.theme = theme
    }
    
    // MARK: - View
    var body: some View {
        ScrollView {
            welcomeSection
            suggestedWorkoutsSection
            recentActivitySection
        }
        .navigationTitle("Workouts")
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading) {
            Text("Good morning,")
                .font(theme.subheadline)
            Text("Ready to train?")
                .font(theme.headline)
        }
    }
    
    // MARK: - Suggested Workouts Section
    private var suggestedWorkoutsSection: some View {
        VStack(alignment: .leading) {
            Text("Suggested for You")
                .font(theme.sectionHeader)
            
            ForEach(viewModel.suggestedWorkouts) { workout in
                WorkoutCard(workout: workout, theme: theme)
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading) {
            Text("Recent")
                .font(theme.sectionHeader)
            
            ForEach(viewModel.recentWorkouts.prefix(3)) { workout in
                WorkoutRow(workout: workout, theme: theme)
            }
        }
    }
    
    // MARK: - Data
    private var filteredWorkouts: [Workout] {
        guard !searchText.isEmpty else { return workouts }
        return workouts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Actions
    private func startWorkout(_ workout: Workout) {
        betterFit.startWorkout(workout)
    }
    
    // MARK: - Supporting Types
    private struct WorkoutCard: View {
        let workout: Workout
        let theme: AppTheme
        
        var body: some View {
            // ...
        }
    }
}
```

### Manager/Service ordering

```swift
final class WorkoutManager: ObservableObject {
    
    // MARK: - Published State
    @Published var activeWorkout: Workout?
    @Published var history: [Workout] = []
    
    // MARK: - Dependencies
    private let apiClient: APIClient
    private let cache: Cache
    
    // MARK: - Init
    init(apiClient: APIClient, cache: Cache) {
        self.apiClient = apiClient
        self.cache = cache
    }
    
    // MARK: - Public API
    func startWorkout(_ workout: Workout) { ... }
    func completeWorkout(_ workout: Workout) { ... }
    func deleteWorkout(_ workout: Workout) { ... }
    
    // MARK: - Private Helpers
    private func saveToCache(_ workout: Workout) { ... }
    private func syncWithServer(_ workout: Workout) { ... }
    
    // MARK: - Computed Properties
    var totalWorkoutsCompleted: Int { history.count }
    var currentStreak: Int { calculateStreak() }
}
```

## Section naming conventions

| Section | Use for | Example |
|---------|---------|---------|
| `// MARK: - State` | `@State`, `@StateObject`, `@ObservedObject` | `@State private var isLoading` |
| `// MARK: - Dependencies` | Injected services, managers | `let apiClient: APIClient` |
| `// MARK: - Init` | Initializers | `init(...)` |
| `// MARK: - View` | `body` and main view structure | `var body: some View` |
| `// MARK: - [Name] Section` | Cohesive UI section | `welcomeSection`, `statsSection` |
| `// MARK: - Sections` | Multiple related sections | List sections, cards |
| `// MARK: - Data` | Computed properties, static data | `filteredWorkouts`, `sampleData` |
| `// MARK: - Actions` | User action handlers | `startWorkout`, `handleTap` |
| `// MARK: - Public API` | Exposed methods (managers) | `func save()`, `func load()` |
| `// MARK: - Private Helpers` | Internal implementation | `private func validate()` |
| `// MARK: - Supporting Types` | Nested structs/enums | `private struct Row: View` |

## File organization principles

### Within a file (top to bottom)

1. **Imports**
2. **Type declaration**
3. **State/Properties** (published first, then private)
4. **Dependencies**
5. **Init**
6. **Main API/View** (`body`, key methods)
7. **Sections/Subviews** (computed properties)
8. **Data/Helpers** (computed properties, private methods)
9. **Actions** (event handlers)
10. **Supporting Types** (nested structs/enums)

### Across files

See `betterfit-swift-file-splitting` skill for when/how to split large files.

## Xcode benefits

Proper MARK organization enables:
- **Minimap** shows clear section boundaries
- **Jump bar** (Ctrl+6) lists all sections
- **Code folding** works at section level
- **Quick navigation** in large files

## Quick checklist

- [ ] Add MARKs when file has 3+ logical sections
- [ ] Use `// MARK: - Name` (with dash for separator line)
- [ ] Place MARKs above declarations, not inside closures
- [ ] Follow consistent ordering: State → Dependencies → Init → View → Sections → Data → Actions → Types
- [ ] Keep section names short and consistent
- [ ] Don't over-MARK: simple files (<100 lines) may not need any
