import BetterFit
import SwiftUI
import WatchKit

@main
struct BetterFitWatchApp: App {
    @StateObject private var appState = WatchAppState()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                #if DEBUG
                .environment(
                    \.dynamicTypeSize,
                    ProcessInfo.processInfo.arguments.contains("UI_TESTING_LARGE_TEXT")
                        ? .accessibility5 : dynamicTypeSize
                )
                #endif
        }
    }
}

@MainActor
final class WatchAppState: ObservableObject {
    let betterFit = BetterFit()

    @Published var session: WorkoutTrackingSession?
    @Published private(set) var isSeeded = false

    init() {
        seedDemoData()
    }

    // MARK: - Workout Tracking

    func startWorkout(_ workout: Workout) {
        guard session == nil else { return }
        let restDuration = UserDefaults.standard.object(forKey: "watch.restDuration") as? Double ?? 60
        let trackingSession = WorkoutTrackingSession(workout: workout, restDuration: restDuration)
        session = trackingSession
        betterFit.startWorkout(trackingSession.workout)
    }

    func logSet(id: UUID) {
        guard session?.currentSet?.id == id, session?.isPaused == false else { return }
        session?.completeSet(id: id)
        WKInterfaceDevice.current().play(.success)
    }

    func undoLastSet() {
        let wasFinished = session?.isFinished == true
        session?.undoLastSet()
        if wasFinished { betterFit.resumeWorkout() }
        WKInterfaceDevice.current().play(.click)
    }

    func setRestDuration(_ duration: TimeInterval) {
        session?.setRestDuration(duration)
        UserDefaults.standard.set(duration, forKey: "watch.restDuration")
    }

    func togglePause() {
        guard let session else { return }
        if session.isPaused {
            self.session?.resume()
            betterFit.resumeWorkout()
        } else {
            self.session?.pause()
            betterFit.pauseWorkout()
        }
    }

    func completeWorkout() {
        guard let workout = session?.completedWorkout() else { return }
        // This standalone MVP has no HealthKit authorization flow yet.
        betterFit.completeWorkout(workout, saveToHealthKit: false)
        session = nil
    }

    func discardWorkout() {
        betterFit.cancelWorkout()
        session = nil
    }

    // MARK: - Seed Data

    private func seedDemoData() {
        guard !isSeeded else { return }

        // Profile
        var profile = betterFit.socialManager.getUserProfile()
        profile.username = "Watch User"
        betterFit.socialManager.updateUserProfile(profile)

        let templates = demoTemplates()
        templates.forEach { betterFit.templateManager.addTemplate($0) }
        let plan = TrainingPlan(
            name: "Watch Plan",
            description: "A simple 3-day split.",
            weeks: [TrainingWeek(weekNumber: 1, workouts: templates.map(\.id))],
            goal: .hypertrophy
        )
        betterFit.planManager.addPlan(plan)
        betterFit.planManager.setActivePlan(plan.id)
        isSeeded = true
    }

    private func demoTemplates() -> [WorkoutTemplate] {
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

        return [
            pushTemplate(bench: bench, press: press),
            pullTemplate(row: row, curl: curl),
            legsTemplate(squat: squat, hinge: hinge, core: core)
        ]
    }

    private func pushTemplate(bench: Exercise, press: Exercise) -> WorkoutTemplate {
        WorkoutTemplate(
            name: "Push Day",
            description: "Chest + shoulders + triceps",
            exercises: [
                TemplateExercise(
                    exercise: bench,
                    targetSets: [
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 8, weight: 60),
                        TargetSet(reps: 6, weight: 65)
                    ]
                ),
                TemplateExercise(
                    exercise: press,
                    targetSets: [TargetSet(reps: 10, weight: 18), TargetSet(reps: 10, weight: 18)]
                )
            ],
            tags: ["strength", "upper"]
        )
    }

    private func pullTemplate(row: Exercise, curl: Exercise) -> WorkoutTemplate {
        WorkoutTemplate(
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
                )
            ],
            tags: ["strength", "upper"]
        )
    }

    private func legsTemplate(squat: Exercise, hinge: Exercise, core: Exercise) -> WorkoutTemplate {
        WorkoutTemplate(
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
                )
            ],
            tags: ["strength", "lower"]
        )
    }
}
