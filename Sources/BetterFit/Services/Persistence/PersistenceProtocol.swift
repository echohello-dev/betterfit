import Foundation

/// Protocol for abstracting data persistence
/// Allows switching between local (guest mode) and cloud (authenticated) storage
public protocol PersistenceProtocol {
    // MARK: - Workouts

    /// Save a workout
    func saveWorkout(_ workout: Workout) async throws

    /// Get all workouts
    func getWorkouts() async throws -> [Workout]

    /// Get workouts within a date range
    func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]

    /// Delete a workout
    func deleteWorkout(_ workoutId: UUID) async throws

    // MARK: - Templates

    /// Save a workout template
    func saveTemplate(_ template: WorkoutTemplate) async throws

    /// Get all templates
    func getTemplates() async throws -> [WorkoutTemplate]

    /// Delete a template
    func deleteTemplate(_ templateId: UUID) async throws

    // MARK: - Training Plans

    /// Save a training plan
    func savePlan(_ plan: TrainingPlan) async throws

    /// Get active training plan
    func getActivePlan() async throws -> TrainingPlan?

    /// Get all training plans
    func getPlans() async throws -> [TrainingPlan]

    /// Delete a plan
    func deletePlan(_ planId: UUID) async throws

    // MARK: - User Profile

    /// Save user profile
    func saveUserProfile(_ profile: UserProfile) async throws

    /// Get user profile
    func getUserProfile() async throws -> UserProfile?

    // MARK: - Body Map Recovery

    /// Save body map recovery data
    func saveBodyMapRecovery(_ recovery: BodyMapRecovery) async throws

    /// Get body map recovery data
    func getBodyMapRecovery() async throws -> BodyMapRecovery?

    // MARK: - Streaks

    /// Save streak data
    func saveStreakData(currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?) async throws

    /// Get streak data
    func getStreakData() async throws -> (
        currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?
    )

    // MARK: - Migration

    /// Clear all data (used after successful migration from guest to authenticated)
    func clearAllData() async throws
}
