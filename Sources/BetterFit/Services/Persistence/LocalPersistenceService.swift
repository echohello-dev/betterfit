import Foundation

/// Local persistence service using UserDefaults
/// Used for guest mode (unauthenticated users)
public final class LocalPersistenceService: PersistenceProtocol {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Keys

    private enum Keys {
        static let workouts = "bf_workouts"
        static let templates = "bf_templates"
        static let plans = "bf_plans"
        static let activePlanId = "bf_active_plan_id"
        static let userProfile = "bf_user_profile"
        static let bodyMapRecovery = "bf_body_map_recovery"
        static let currentStreak = "bf_current_streak"
        static let longestStreak = "bf_longest_streak"
        static let lastWorkoutDate = "bf_last_workout_date"
    }

    // MARK: - Initialization

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Workouts

    public func saveWorkout(_ workout: Workout) async throws {
        var workouts = try await getWorkouts()

        // Remove existing workout with same ID if present
        workouts.removeAll { $0.id == workout.id }

        // Add new/updated workout
        workouts.append(workout)

        // Save to UserDefaults
        let data = try encoder.encode(workouts)
        userDefaults.set(data, forKey: Keys.workouts)
    }

    public func getWorkouts() async throws -> [Workout] {
        guard let data = userDefaults.data(forKey: Keys.workouts) else {
            return []
        }
        return try decoder.decode([Workout].self, from: data)
    }

    public func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        let allWorkouts = try await getWorkouts()
        return allWorkouts.filter { workout in
            workout.date >= startDate && workout.date <= endDate
        }
    }

    public func deleteWorkout(_ workoutId: UUID) async throws {
        var workouts = try await getWorkouts()
        workouts.removeAll { $0.id == workoutId }
        let data = try encoder.encode(workouts)
        userDefaults.set(data, forKey: Keys.workouts)
    }

    // MARK: - Templates

    public func saveTemplate(_ template: WorkoutTemplate) async throws {
        var templates = try await getTemplates()
        templates.removeAll { $0.id == template.id }
        templates.append(template)
        let data = try encoder.encode(templates)
        userDefaults.set(data, forKey: Keys.templates)
    }

    public func getTemplates() async throws -> [WorkoutTemplate] {
        guard let data = userDefaults.data(forKey: Keys.templates) else {
            return []
        }
        return try decoder.decode([WorkoutTemplate].self, from: data)
    }

    public func deleteTemplate(_ templateId: UUID) async throws {
        var templates = try await getTemplates()
        templates.removeAll { $0.id == templateId }
        let data = try encoder.encode(templates)
        userDefaults.set(data, forKey: Keys.templates)
    }

    // MARK: - Training Plans

    public func savePlan(_ plan: TrainingPlan) async throws {
        var plans = try await getPlans()
        plans.removeAll { $0.id == plan.id }
        plans.append(plan)
        let data = try encoder.encode(plans)
        userDefaults.set(data, forKey: Keys.plans)
    }

    public func getActivePlan() async throws -> TrainingPlan? {
        guard let activePlanIdString = userDefaults.string(forKey: Keys.activePlanId),
            let activePlanId = UUID(uuidString: activePlanIdString)
        else {
            return nil
        }

        let plans = try await getPlans()
        return plans.first { $0.id == activePlanId }
    }

    public func getPlans() async throws -> [TrainingPlan] {
        guard let data = userDefaults.data(forKey: Keys.plans) else {
            return []
        }
        return try decoder.decode([TrainingPlan].self, from: data)
    }

    public func deletePlan(_ planId: UUID) async throws {
        var plans = try await getPlans()
        plans.removeAll { $0.id == planId }
        let data = try encoder.encode(plans)
        userDefaults.set(data, forKey: Keys.plans)

        // Clear active plan ID if this was the active plan
        if let activePlanIdString = userDefaults.string(forKey: Keys.activePlanId),
            let activePlanId = UUID(uuidString: activePlanIdString),
            activePlanId == planId
        {
            userDefaults.removeObject(forKey: Keys.activePlanId)
        }
    }

    // MARK: - User Profile

    public func saveUserProfile(_ profile: UserProfile) async throws {
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: Keys.userProfile)
    }

    public func getUserProfile() async throws -> UserProfile? {
        guard let data = userDefaults.data(forKey: Keys.userProfile) else {
            return nil
        }
        return try decoder.decode(UserProfile.self, from: data)
    }

    // MARK: - Body Map Recovery

    public func saveBodyMapRecovery(_ recovery: BodyMapRecovery) async throws {
        let data = try encoder.encode(recovery)
        userDefaults.set(data, forKey: Keys.bodyMapRecovery)
    }

    public func getBodyMapRecovery() async throws -> BodyMapRecovery? {
        guard let data = userDefaults.data(forKey: Keys.bodyMapRecovery) else {
            return nil
        }
        return try decoder.decode(BodyMapRecovery.self, from: data)
    }

    // MARK: - Streaks

    public func saveStreakData(currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?)
        async throws
    {
        userDefaults.set(currentStreak, forKey: Keys.currentStreak)
        userDefaults.set(longestStreak, forKey: Keys.longestStreak)
        if let lastWorkoutDate {
            userDefaults.set(lastWorkoutDate, forKey: Keys.lastWorkoutDate)
        } else {
            userDefaults.removeObject(forKey: Keys.lastWorkoutDate)
        }
    }

    public func getStreakData() async throws -> (
        currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?
    ) {
        let currentStreak = userDefaults.integer(forKey: Keys.currentStreak)
        let longestStreak = userDefaults.integer(forKey: Keys.longestStreak)
        let lastWorkoutDate = userDefaults.object(forKey: Keys.lastWorkoutDate) as? Date
        return (currentStreak, longestStreak, lastWorkoutDate)
    }

    // MARK: - Migration

    public func clearAllData() async throws {
        userDefaults.removeObject(forKey: Keys.workouts)
        userDefaults.removeObject(forKey: Keys.templates)
        userDefaults.removeObject(forKey: Keys.plans)
        userDefaults.removeObject(forKey: Keys.activePlanId)
        userDefaults.removeObject(forKey: Keys.userProfile)
        userDefaults.removeObject(forKey: Keys.bodyMapRecovery)
        userDefaults.removeObject(forKey: Keys.currentStreak)
        userDefaults.removeObject(forKey: Keys.longestStreak)
        userDefaults.removeObject(forKey: Keys.lastWorkoutDate)
    }
}
