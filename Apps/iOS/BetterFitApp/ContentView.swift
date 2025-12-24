import BetterFit
import SwiftUI

struct ContentView: View {
    let betterFit: BetterFit

    @State private var lastEvent: String = ""
    @State private var recoveryPercent: Double = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    LabeledContent("Overall recovery") {
                        Text("\(Int(recoveryPercent))%")
                            .monospacedDigit()
                    }

                    if !lastEvent.isEmpty {
                        LabeledContent("Last event") {
                            Text(lastEvent)
                        }
                    }
                }

                Section("Quick actions") {
                    Button("Simulate workout + update recovery") {
                        simulateWorkout()
                    }
                }
            }
            .navigationTitle("BetterFit")
        }
        .onAppear {
            refreshRecovery()
        }
    }

    private func refreshRecovery() {
        recoveryPercent = betterFit.bodyMapManager.getOverallRecoveryPercentage()
    }

    private func simulateWorkout() {
        // Minimal "fake" workout flow just to prove the library runs in an app.
        let benchPress = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )

        let workout = Workout(
            name: "Quick Session",
            exercises: [
                WorkoutExercise(exercise: benchPress, sets: [ExerciseSet(reps: 8, weight: 60)])
            ]
        )

        betterFit.startWorkout(workout)
        betterFit.completeWorkout(workout)

        lastEvent = "Completed workout"
        refreshRecovery()
    }
}

#Preview {
    ContentView(betterFit: BetterFit())
}
