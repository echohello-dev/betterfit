import BetterFit
import SwiftUI

@main
struct BetterFitWatchApp: App {
    @StateObject private var appState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

@MainActor
class WatchAppState: ObservableObject {
    let betterFit = BetterFit()

    @Published var activeWorkout: Workout?
    @Published var currentExerciseIndex: Int = 0

    func startWorkout(_ workout: Workout) {
        activeWorkout = workout
        currentExerciseIndex = 0
        betterFit.startWorkout(workout)
    }

    func completeWorkout() {
        guard var workout = activeWorkout else { return }
        workout.isCompleted = true
        workout.duration = Date().timeIntervalSince(workout.date)
        betterFit.completeWorkout(workout)
        activeWorkout = nil
        currentExerciseIndex = 0
    }

    func updateActiveWorkout(_ workout: Workout) {
        activeWorkout = workout
    }
}
