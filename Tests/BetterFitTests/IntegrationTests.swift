import XCTest

@testable import BetterFit

final class IntegrationTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear all persistence data before each test to ensure test isolation
        let persistence = LocalPersistenceService()
        try await persistence.clearAllData()
        // Add a small delay to ensure cleanup completes
        try await Task.sleep(nanoseconds: 50_000_000)  // 0.05 seconds
    }

    override func tearDown() async throws {
        // Clear all persistence data after each test to ensure test isolation
        let persistence = LocalPersistenceService()
        try await persistence.clearAllData()
        // Add a small delay to ensure cleanup completes
        try await Task.sleep(nanoseconds: 50_000_000)  // 0.05 seconds
        try await super.tearDown()
    }

    func testBetterFitInitialization() {
        let betterFit = BetterFit()

        XCTAssertNotNil(betterFit.planManager)
        XCTAssertNotNil(betterFit.templateManager)
        XCTAssertNotNil(betterFit.equipmentSwapManager)
        XCTAssertNotNil(betterFit.bodyMapManager)
        XCTAssertNotNil(betterFit.socialManager)
        XCTAssertNotNil(betterFit.notificationManager)
        XCTAssertNotNil(betterFit.autoTrackingService)
        XCTAssertNotNil(betterFit.aiAdaptationService)
        XCTAssertNotNil(betterFit.imageService)
    }

    func testCompleteWorkoutFlow() {
        let betterFit = BetterFit()

        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )

        let set = ExerciseSet(reps: 5, weight: 225.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        var workout = Workout(name: "Leg Day", exercises: [workoutExercise])
        workout.isCompleted = true

        betterFit.startWorkout(workout)
        betterFit.completeWorkout(workout)

        let history = betterFit.getWorkoutHistory()
        XCTAssertEqual(history.count, 1)

        let streak = betterFit.socialManager.getCurrentStreak()
        XCTAssertEqual(streak, 1)
    }

    func testTemplateToWorkoutIntegration() {
        let betterFit = BetterFit()

        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )

        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: [TargetSet(reps: 8, weight: 185.0)]
        )

        let template = WorkoutTemplate(
            name: "Push Day",
            exercises: [templateExercise]
        )

        betterFit.templateManager.addTemplate(template)

        let workout = betterFit.templateManager.createWorkout(from: template.id)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.name, "Push Day")
    }

    // MARK: - Persistence Integration Tests

    func testBetterFitWithLocalPersistence() async throws {
        let persistence = LocalPersistenceService()
        let betterFit = BetterFit(persistenceService: persistence)

        // Wait for BetterFit to finish loading persisted data
        try await Task.sleep(nanoseconds: 50_000_000)  // 0.05 seconds

        // Create and complete a workout
        let exercise = Exercise(
            name: "Deadlift",
            equipmentRequired: .barbell,
            muscleGroups: [.hamstrings, .back]
        )

        let set = ExerciseSet(reps: 5, weight: 315.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        var workout = Workout(name: "Back Day", exercises: [workoutExercise])
        workout.isCompleted = true

        betterFit.completeWorkout(workout)

        // Wait for async persistence operations to complete
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds

        // Verify workout was saved
        let savedWorkouts = try await persistence.getWorkouts()
        XCTAssertEqual(savedWorkouts.count, 1)
        XCTAssertEqual(savedWorkouts.first?.name, "Back Day")
        XCTAssertEqual(savedWorkouts.first?.exercises.first?.sets.first?.weight, 315.0)
    }

    func testPersistenceWorkoutSaveAndRetrieve() async throws {
        let persistence = LocalPersistenceService()

        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )

        let set = ExerciseSet(reps: 10, weight: 225.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        let workout = Workout(name: "Leg Day", exercises: [workoutExercise])

        try await persistence.saveWorkout(workout)

        let retrievedWorkouts = try await persistence.getWorkouts()
        XCTAssertEqual(retrievedWorkouts.count, 1)
        XCTAssertEqual(retrievedWorkouts.first?.id, workout.id)
        XCTAssertEqual(retrievedWorkouts.first?.name, "Leg Day")
    }

    func testPersistenceTemplateSaveAndRetrieve() async throws {
        let persistence = LocalPersistenceService()

        let exercise = Exercise(
            name: "Overhead Press",
            equipmentRequired: .barbell,
            muscleGroups: [.shoulders, .triceps]
        )

        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: [TargetSet(reps: 8, weight: 135.0)]
        )

        let template = WorkoutTemplate(
            name: "Shoulder Day",
            exercises: [templateExercise]
        )

        try await persistence.saveTemplate(template)

        let retrievedTemplates = try await persistence.getTemplates()
        XCTAssertEqual(retrievedTemplates.count, 1)
        XCTAssertEqual(retrievedTemplates.first?.id, template.id)
        XCTAssertEqual(retrievedTemplates.first?.name, "Shoulder Day")
    }

    func testPersistenceUserProfileSaveAndRetrieve() async throws {
        let persistence = LocalPersistenceService()

        let profile = UserProfile(
            username: "testuser", currentStreak: 5, longestStreak: 10, totalWorkouts: 25)

        try await persistence.saveUserProfile(profile)

        let retrievedProfile = try await persistence.getUserProfile()
        XCTAssertNotNil(retrievedProfile)
        XCTAssertEqual(retrievedProfile?.username, "testuser")
        XCTAssertEqual(retrievedProfile?.currentStreak, 5)
        XCTAssertEqual(retrievedProfile?.longestStreak, 10)
        XCTAssertEqual(retrievedProfile?.totalWorkouts, 25)
    }

    func testPersistenceStreakDataSaveAndRetrieve() async throws {
        let persistence = LocalPersistenceService()

        let now = Date()
        try await persistence.saveStreakData(
            currentStreak: 5,
            longestStreak: 10,
            lastWorkoutDate: now
        )

        let streakData = try await persistence.getStreakData()
        XCTAssertEqual(streakData.currentStreak, 5)
        XCTAssertEqual(streakData.longestStreak, 10)
        XCTAssertNotNil(streakData.lastWorkoutDate)
    }

    func testPersistenceBodyMapRecoverySaveAndRetrieve() async throws {
        let persistence = LocalPersistenceService()

        var recovery = BodyMapRecovery()
        // Update via workout (existing API)
        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        let set = ExerciseSet(reps: 10, weight: 225, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        let workout = Workout(name: "Leg Day", exercises: [workoutExercise])

        recovery.recordWorkout(workout)

        try await persistence.saveBodyMapRecovery(recovery)

        let retrievedRecovery = try await persistence.getBodyMapRecovery()
        XCTAssertNotNil(retrievedRecovery)
    }

    func testPersistenceDeleteOperations() async throws {
        let persistence = LocalPersistenceService()

        // Save a workout
        let exercise = Exercise(
            name: "Test", equipmentRequired: .bodyweight, muscleGroups: [.chest])
        let set = ExerciseSet(reps: 10, weight: 100, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        let workout = Workout(name: "Test Workout", exercises: [workoutExercise])

        try await persistence.saveWorkout(workout)
        var workouts = try await persistence.getWorkouts()
        XCTAssertEqual(workouts.count, 1)

        // Delete the workout
        try await persistence.deleteWorkout(workout.id)
        workouts = try await persistence.getWorkouts()
        XCTAssertEqual(workouts.count, 0)

        // Save a template
        let templateExercise = TemplateExercise(
            exercise: exercise,
            targetSets: [TargetSet(reps: 10, weight: 100)]
        )
        let template = WorkoutTemplate(name: "Test Template", exercises: [templateExercise])

        try await persistence.saveTemplate(template)
        var templates = try await persistence.getTemplates()
        XCTAssertEqual(templates.count, 1)

        // Delete the template
        try await persistence.deleteTemplate(template.id)
        templates = try await persistence.getTemplates()
        XCTAssertEqual(templates.count, 0)
    }

    func testPersistenceClearAllData() async throws {
        let persistence = LocalPersistenceService()

        // Add various data
        let exercise = Exercise(
            name: "Test", equipmentRequired: .bodyweight, muscleGroups: [.chest])
        let set = ExerciseSet(reps: 10, weight: 100, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        let workout = Workout(name: "Test", exercises: [workoutExercise])

        try await persistence.saveWorkout(workout)
        try await persistence.saveStreakData(
            currentStreak: 5, longestStreak: 10, lastWorkoutDate: Date())

        let profile = UserProfile(username: "testuser")
        try await persistence.saveUserProfile(profile)

        // Clear all data
        try await persistence.clearAllData()

        // Verify everything is cleared
        let workouts = try await persistence.getWorkouts()
        XCTAssertEqual(workouts.count, 0)

        let streakData = try await persistence.getStreakData()
        XCTAssertEqual(streakData.currentStreak, 0)
        XCTAssertEqual(streakData.longestStreak, 0)
        XCTAssertNil(streakData.lastWorkoutDate)

        let retrievedProfile = try await persistence.getUserProfile()
        XCTAssertNil(retrievedProfile)
    }

    func testWorkoutPersistenceAcrossMultipleSaves() async throws {
        let persistence = LocalPersistenceService()

        // Save multiple workouts
        for i in 1...3 {
            let exercise = Exercise(
                name: "Exercise \(i)", equipmentRequired: .bodyweight, muscleGroups: [.chest])
            let set = ExerciseSet(reps: 10, weight: Double(i * 100), isCompleted: true)
            let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
            let workout = Workout(name: "Workout \(i)", exercises: [workoutExercise])

            try await persistence.saveWorkout(workout)
        }

        let workouts = try await persistence.getWorkouts()
        XCTAssertEqual(workouts.count, 3)
        XCTAssertTrue(workouts.contains(where: { $0.name == "Workout 1" }))
        XCTAssertTrue(workouts.contains(where: { $0.name == "Workout 2" }))
        XCTAssertTrue(workouts.contains(where: { $0.name == "Workout 3" }))
    }

    // MARK: - Auth Service Integration Tests

    func testAuthServiceGuestMode() async {
        let authService = await AuthService(
            supabaseURL: URL(string: "https://test.supabase.co")!,
            supabaseAnonKey: "test-key"
        )

        await authService.continueAsGuest()

        let isGuest = await authService.isGuest
        let isAuthenticated = await authService.isAuthenticated

        XCTAssertTrue(isGuest)
        XCTAssertFalse(isAuthenticated)
    }

    func testBetterFitWithPersistenceInjection() {
        let localPersistence = LocalPersistenceService()
        let betterFit = BetterFit(persistenceService: localPersistence)

        XCTAssertNotNil(betterFit.planManager)
        XCTAssertNotNil(betterFit.templateManager)

        // Verify that persistence is properly integrated
        let exercise = Exercise(
            name: "Test", equipmentRequired: .bodyweight, muscleGroups: [.chest])
        let set = ExerciseSet(reps: 10, weight: 100, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        var workout = Workout(name: "Test", exercises: [workoutExercise])
        workout.isCompleted = true

        betterFit.completeWorkout(workout)

        let history = betterFit.getWorkoutHistory()
        XCTAssertEqual(history.count, 1)
    }

    func testCompleteWorkoutFlowWithPersistence() async throws {
        let persistence = LocalPersistenceService()
        let betterFit = BetterFit(persistenceService: persistence)

        // Wait for BetterFit to finish loading persisted data
        try await Task.sleep(nanoseconds: 50_000_000)  // 0.05 seconds

        let exercise = Exercise(
            name: "Bench Press",
            equipmentRequired: .barbell,
            muscleGroups: [.chest, .triceps]
        )

        let set = ExerciseSet(reps: 8, weight: 185.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        var workout = Workout(name: "Push Day", exercises: [workoutExercise])
        workout.isCompleted = true

        // Complete the workout (should save via persistence)
        betterFit.completeWorkout(workout)

        // Wait for async persistence operations to complete
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds

        // Verify workout was saved to persistence
        let savedWorkouts = try await persistence.getWorkouts()
        XCTAssertEqual(savedWorkouts.count, 1)
        XCTAssertEqual(savedWorkouts.first?.name, "Push Day")

        // Verify streak was updated
        let streakData = try await persistence.getStreakData()
        XCTAssertEqual(streakData.currentStreak, 1)

        // Verify recovery data was updated
        let recovery = try await persistence.getBodyMapRecovery()
        XCTAssertNotNil(recovery)
    }
}
