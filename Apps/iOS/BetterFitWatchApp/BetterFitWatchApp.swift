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
    @Published private(set) var isSeeded = false

    init() {
        seedDemoData()
    }

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

    // MARK: - Seed Data

    private func seedDemoData() {
        guard !isSeeded else { return }

        // Profile
        var profile = betterFit.socialManager.getUserProfile()
        profile.username = "Watch User"
        betterFit.socialManager.updateUserProfile(profile)

        // Exercises
        let bench = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )
        let row = Exercise(
            name: "Cable Row",
            equipmentRequired: .cable,
            muscleGroups: [.back, .lats]
        )
        let squat = Exercise(
            name: "Back Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        let press = Exercise(
            name: "Overhead Press",
            equipmentRequired: .dumbbell,
            muscleGroups: [.shoulders, .triceps]
        )
        let curl = Exercise(
            name: "Dumbbell Curl",
            equipmentRequired: .dumbbell,
            muscleGroups: [.biceps]
        )
        let hinge = Exercise(
            name: "Romanian Deadlift",
            equipmentRequired: .barbell,
            muscleGroups: [.hamstrings, .glutes]
        )
        let core = Exercise(
            name: "Plank",
            equipmentRequired: .bodyweight,
            muscleGroups: [.abs]
        )

        // Templates
        let pushDay = WorkoutTemplate(
            name: "Push Day",
            description: "Chest + shoulders + triceps",
            exercises: [
                TemplateExercise(
                    exercise: bench,
                    targetSets: [
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 6, weight: 65),
                    ]
                ),
                TemplateExercise(
                    exercise: press,
                    targetSets: [TargetSet(reps: 10, weight: 18), TargetSet(reps: 10, weight: 18)]
                ),
            ],
            tags: ["strength", "upper"]
        )

        let pullDay = WorkoutTemplate(
            name: "Pull Day",
            description: "Back + biceps",
            exercises: [
                TemplateExercise(
                    exercise: row,
                    targetSets: [TargetSet(reps: 12, weight: 45), TargetSet(reps: 10, weight: 50)]
                ),
                TemplateExercise(
                    exercise: curl,
                    targetSets: [TargetSet(reps: 12, weight: 12), TargetSet(reps: 10, weight: 12)]
                ),
            ],
            tags: ["strength", "upper"]
        )

        let legsDay = WorkoutTemplate(
            name: "Leg Day",
            description: "Quads + hamstrings + glutes",
            exercises: [
                TemplateExercise(
                    exercise: squat,
                    targetSets: [TargetSet(reps: 5, weight: 90), TargetSet(reps: 5, weight: 90)]
                ),
                TemplateExercise(
                    exercise: hinge,
                    targetSets: [TargetSet(reps: 8, weight: 80), TargetSet(reps: 8, weight: 80)]
                ),
                TemplateExercise(
                    exercise: core,
                    targetSets: [TargetSet(reps: 60, weight: nil)]
                ),
            ],
            tags: ["strength", "lower"]
        )

        [pushDay, pullDay, legsDay].forEach { betterFit.templateManager.addTemplate($0) }

        // Training plan
        let plan = TrainingPlan(
            name: "Watch Plan",
            description: "A simple 3-day split.",
            weeks: [
                TrainingWeek(weekNumber: 1, workouts: [pushDay.id, pullDay.id, legsDay.id])
            ],
            goal: .hypertrophy
        )
        betterFit.planManager.addPlan(plan)
        betterFit.planManager.setActivePlan(plan.id)

        isSeeded = true
    }
}
