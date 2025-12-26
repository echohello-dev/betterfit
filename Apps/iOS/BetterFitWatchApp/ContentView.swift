import BetterFit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: WatchAppState

    var body: some View {
        if let activeWorkout = appState.activeWorkout {
            ActiveWorkoutView(workout: activeWorkout)
        } else {
            NavigationStack {
                TabView {
                    WorkoutListView()
                        .tabItem {
                            Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                        }

                    NotificationsView()
                        .tabItem {
                            Label("Reminders", systemImage: "bell.fill")
                        }
                }
            }
        }
    }
}
