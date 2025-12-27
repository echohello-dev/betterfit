import BetterFit
import SwiftUI

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

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    @State private var selectedTab: AppTab = .workout
    @State private var previousTab: AppTab = .workout
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
                if newTab == .search && oldTab != .search {
                    previousTab = oldTab
                }
            }
        } else {
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
                if newTab == .search && oldTab != .search {
                    previousTab = oldTab
                }
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
            AppSearchView(
                theme: theme,
                betterFit: betterFit,
                query: $searchQuery,
                previousTabIcon: previousTab.icon,
                onDismiss: {
                    withAnimation { selectedTab = previousTab }
                }
            )
        }
    }
}

#Preview {
    let theme: AppTheme = .defaultTheme
    RootTabView(betterFit: BetterFit(), theme: theme)
        .preferredColorScheme(theme.preferredColorScheme)
}
