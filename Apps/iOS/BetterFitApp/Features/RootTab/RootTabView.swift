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

    /// Returns the tab to navigate back to when dismissing search
    private var tabToReturnTo: AppTab {
        selectedTab == .search ? previousTab : selectedTab
    }

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
            .safeAreaInset(edge: .bottom) {
                startWorkoutButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
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
            .safeAreaInset(edge: .bottom) {
                startWorkoutButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Start Workout Button

    @ViewBuilder
    private var startWorkoutButton: some View {
        let shape = RoundedRectangle(cornerRadius: 27, style: .continuous)

        Button {
            // TODO: Start workout action
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .foregroundStyle(.black)

                Text("Start Workout")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background {
                if #available(iOS 26.0, *) {
                    shape
                        .fill(Color.yellow)
                        .glassEffect(.regular.interactive(), in: shape)
                } else {
                    shape
                        .fill(Color.yellow)
                        .overlay { shape.stroke(Color.yellow.opacity(0.3), lineWidth: 1) }
                        .shadow(
                            color: Color.black.opacity(0.22),
                            radius: 14,
                            x: 0,
                            y: 6
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start Workout")
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
                previousTabIcon: tabToReturnTo.icon,
                onDismiss: {
                    withAnimation { selectedTab = tabToReturnTo }
                }
            )
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "betterfit.workoutHome.demoMode")
    let theme: AppTheme = .defaultTheme
    return RootTabView(betterFit: BetterFit(), theme: theme)
        .preferredColorScheme(theme.preferredColorScheme)
}
