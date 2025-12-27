# TabView Patterns (iOS 17+ / iOS 26+)

This document covers SwiftUI TabView patterns used in BetterFit, including iOS 26 Liquid Glass adoption.

## Basic Structure

Use an enum for tabs to get type-safety and `CaseIterable` iteration:

```swift
enum AppTab: String, CaseIterable {
    case workout
    case plan
    case recovery
    case search

    var title: String {
        switch self {
        case .workout: "Workout"
        case .plan: "Plan"
        case .recovery: "Recovery"
        case .search: "Search"
        }
    }

    var icon: String {
        switch self {
        case .workout: "figure.run"
        case .plan: "waveform"
        case .recovery: "clock"
        case .search: "magnifyingglass"
        }
    }
}
```

## iOS 26+ TabView with `Tab(value:)`

iOS 26 introduces a new `Tab` type with richer APIs:

```swift
if #available(iOS 26.0, *) {
    TabView(selection: $selectedTab) {
        ForEach(AppTab.allCases, id: \.self) { tab in
            Tab(value: tab, role: tab == .search ? .search : nil) {
                tabContent(for: tab)
            } label: {
                Label(tab.title, systemImage: tab.icon)
            }
        }
    }
    .tint(theme.accent)
    .tabBarMinimizeBehavior(.onScrollDown)
}
```

### Key iOS 26 Features

| Modifier | Purpose |
|----------|---------|
| `Tab(value:role:)` | New tab initializer; `role: .search` marks a search tab |
| `.tabBarMinimizeBehavior(.onScrollDown)` | Auto-hide tab bar when scrolling down |
| `.tabBarMinimizeBehavior(.never)` | Keep tab bar visible always |

### Search Tab Pattern

Use `role: .search` for a dedicated search tab. Handle it specially to present a sheet instead of navigating:

```swift
.onChange(of: selectedTab) { oldTab, newTab in
    if newTab == .search {
        withAnimation { showSearch = true }
        selectedTab = oldTab  // Return to previous tab
    }
}
.sheet(isPresented: $showSearch) {
    AppSearchView(theme: theme, betterFit: betterFit, query: $searchQuery)
}
```

## iOS 17–25 Fallback

For older iOS versions, use the classic `.tabItem` API:

```swift
TabView(selection: $selectedTab) {
    ForEach(AppTab.allCases, id: \.self) { tab in
        tabContent(for: tab)
            .tabItem {
                Label(tab.title, systemImage: tab.icon)
            }
            .tag(tab)
    }
}
.tint(theme.accent)
```

## Complete Example

```swift
struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var selectedTab: AppTab = .workout
    @State private var showSearch = false
    @State private var searchQuery = ""

    var body: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Tab(value: tab, role: tab == .search ? .search : nil) {
                        tabContent(for: tab)
                    } label: {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
            }
            .tint(theme.accent)
            .tabBarMinimizeBehavior(.onScrollDown)
            .onChange(of: selectedTab) { oldTab, newTab in
                if newTab == .search {
                    withAnimation { showSearch = true }
                    selectedTab = oldTab
                }
            }
            .sheet(isPresented: $showSearch) {
                AppSearchView(theme: theme, betterFit: betterFit, query: $searchQuery)
            }
        } else {
            // iOS 17–25 fallback
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    tabContent(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .tint(theme.accent)
            .onChange(of: selectedTab) { oldTab, newTab in
                if newTab == .search {
                    withAnimation { showSearch = true }
                    selectedTab = oldTab
                }
            }
            .sheet(isPresented: $showSearch) {
                AppSearchView(theme: theme, betterFit: betterFit, query: $searchQuery)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .workout:
            NavigationStack {
                WorkoutHomeView(betterFit: betterFit, theme: theme)
            }
        case .plan:
            NavigationStack {
                TrendsView(theme: theme)
            }
        case .recovery:
            NavigationStack {
                RecoveryView(betterFit: betterFit, theme: theme)
            }
        case .search:
            EmptyView()  // Handled via sheet
        }
    }
}
```

## Best Practices

1. **Use an enum for tabs** — provides type safety, iteration, and a single source of truth for titles/icons.

2. **Wrap each tab in NavigationStack** — keeps navigation state isolated per tab.

3. **Use `@available` checks** — iOS 26 APIs aren't available on older versions; always provide a fallback.

4. **Prefer `.tabBarMinimizeBehavior(.onScrollDown)`** — gives more screen space on iOS 26 when scrolling content.

5. **Handle special tabs (search, compose) via sheets** — use `role: .search` or `role: .compose` and present modally rather than navigating.

6. **Keep tab content extraction simple** — a `@ViewBuilder` function or switch is cleaner than inline closures.

## Related

- [Apple: Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)
- [Apple: Adopting Liquid Glass](https://developer.apple.com/documentation/swiftui/adopting-the-liquid-glass-design-language-in-your-app)
- See `Apps/iOS/BetterFitApp/Features/RootTab/RootTabView.swift` for the live implementation.
