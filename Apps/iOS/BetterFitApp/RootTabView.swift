import BetterFit
import SwiftUI

struct RootTabView: View {
    let betterFit: BetterFit
    let theme: AppTheme

    var body: some View {
        TabView {
            NavigationStack {
                WorkoutHomeView(betterFit: betterFit, theme: theme)
            }
            .tabItem {
                Label("Workout", systemImage: "figure.strengthtraining.traditional")
            }

            NavigationStack {
                RecoveryView(betterFit: betterFit, theme: theme)
            }
            .tabItem {
                Label("Recovery", systemImage: "heart")
            }

            NavigationStack {
                TrendsView(theme: theme)
            }
            .tabItem {
                Label("Trends", systemImage: "chart.bar")
            }

            NavigationStack {
                ProfileView(theme: theme)
            }
            .tabItem {
                Label("You", systemImage: "person")
            }
        }
        .tint(theme.accent)
    }
}

#Preview {
    RootTabView(betterFit: BetterFit(), theme: .forest)
}
