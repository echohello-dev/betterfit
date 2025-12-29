import Foundation
import PostgREST
import Supabase

/// Supabase persistence service using PostgreSQL
/// Used for authenticated users (cloud sync)
public final class SupabasePersistenceService: PersistenceProtocol {
    private let client: SupabaseClient
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Table Names

    private enum Tables {
        static let workouts = "workouts"
        static let templates = "workout_templates"
        static let plans = "training_plans"
        static let userProfiles = "user_profiles"
        static let bodyMapRecovery = "body_map_recovery"
        static let streaks = "streak_data"
    }

    // MARK: - Initialization

    public init(supabaseClient: SupabaseClient) {
        self.client = supabaseClient
    }

    // MARK: - Workouts

    public func saveWorkout(_ workout: Workout) async throws {
        try await client
            .from(Tables.workouts)
            .upsert(workout)
            .execute()
    }

    public func getWorkouts() async throws -> [Workout] {
        let response: [Workout] =
            try await client
            .from(Tables.workouts)
            .select()
            .order("date", ascending: false)
            .execute()
            .value

        return response
    }

    public func getWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        let startStr = ISO8601DateFormatter().string(from: startDate)
        let endStr = ISO8601DateFormatter().string(from: endDate)

        let response: [Workout] =
            try await client
            .from(Tables.workouts)
            .select()
            .gte("date", value: startStr)
            .lte("date", value: endStr)
            .order("date", ascending: false)
            .execute()
            .value

        return response
    }

    public func deleteWorkout(_ workoutId: UUID) async throws {
        try await client
            .from(Tables.workouts)
            .delete()
            .eq("id", value: workoutId.uuidString)
            .execute()
    }

    // MARK: - Templates

    public func saveTemplate(_ template: WorkoutTemplate) async throws {
        try await client
            .from(Tables.templates)
            .upsert(template)
            .execute()
    }

    public func getTemplates() async throws -> [WorkoutTemplate] {
        let response: [WorkoutTemplate] =
            try await client
            .from(Tables.templates)
            .select()
            .execute()
            .value

        return response
    }

    public func deleteTemplate(_ templateId: UUID) async throws {
        try await client
            .from(Tables.templates)
            .delete()
            .eq("id", value: templateId.uuidString)
            .execute()
    }

    // MARK: - Training Plans

    public func savePlan(_ plan: TrainingPlan) async throws {
        try await client
            .from(Tables.plans)
            .upsert(plan)
            .execute()
    }

    public func getActivePlan() async throws -> TrainingPlan? {
        let response: [TrainingPlan] =
            try await client
            .from(Tables.plans)
            .select()
            .limit(1)
            .execute()
            .value

        return response.first
    }

    public func getPlans() async throws -> [TrainingPlan] {
        let response: [TrainingPlan] =
            try await client
            .from(Tables.plans)
            .select()
            .execute()
            .value

        return response
    }

    public func deletePlan(_ planId: UUID) async throws {
        try await client
            .from(Tables.plans)
            .delete()
            .eq("id", value: planId.uuidString)
            .execute()
    }

    // MARK: - User Profile

    public func saveUserProfile(_ profile: UserProfile) async throws {
        try await client
            .from(Tables.userProfiles)
            .upsert(profile)
            .execute()
    }

    public func getUserProfile() async throws -> UserProfile? {
        let response: [UserProfile] =
            try await client
            .from(Tables.userProfiles)
            .select()
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Body Map Recovery

    public func saveBodyMapRecovery(_ recovery: BodyMapRecovery) async throws {
        try await client
            .from(Tables.bodyMapRecovery)
            .upsert(recovery)
            .execute()
    }

    public func getBodyMapRecovery() async throws -> BodyMapRecovery? {
        let response: [BodyMapRecovery] =
            try await client
            .from(Tables.bodyMapRecovery)
            .select()
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Streaks

    public func saveStreakData(currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?)
        async throws
    {
        struct StreakDataRequest: Encodable {
            let currentStreak: Int
            let longestStreak: Int
            let lastWorkoutDate: String?

            enum CodingKeys: String, CodingKey {
                case currentStreak = "current_streak"
                case longestStreak = "longest_streak"
                case lastWorkoutDate = "last_workout_date"
            }
        }

        let lastWorkoutDateStr = lastWorkoutDate.map { ISO8601DateFormatter().string(from: $0) }
        let streakData = StreakDataRequest(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastWorkoutDate: lastWorkoutDateStr
        )

        try await client
            .from(Tables.streaks)
            .upsert(streakData)
            .execute()
    }

    public func getStreakData() async throws -> (
        currentStreak: Int, longestStreak: Int, lastWorkoutDate: Date?
    ) {
        struct StreakResponse: Decodable {
            let currentStreak: Int
            let longestStreak: Int
            let lastWorkoutDate: String?

            enum CodingKeys: String, CodingKey {
                case currentStreak = "current_streak"
                case longestStreak = "longest_streak"
                case lastWorkoutDate = "last_workout_date"
            }
        }

        let response: [StreakResponse] =
            try await client
            .from(Tables.streaks)
            .select()
            .limit(1)
            .execute()
            .value

        guard let streakResponse = response.first else {
            return (0, 0, nil)
        }

        let lastWorkoutDate: Date?
        if let dateString = streakResponse.lastWorkoutDate {
            lastWorkoutDate = ISO8601DateFormatter().date(from: dateString)
        } else {
            lastWorkoutDate = nil
        }

        return (
            streakResponse.currentStreak,
            streakResponse.longestStreak,
            lastWorkoutDate
        )
    }

    // MARK: - Migration

    public func clearAllData() async throws {
        // Delete all user's data from all tables
        try await client.from(Tables.workouts).delete().neq("id", value: "").execute()
        try await client.from(Tables.templates).delete().neq("id", value: "").execute()
        try await client.from(Tables.plans).delete().neq("id", value: "").execute()
        try await client.from(Tables.userProfiles).delete().neq("id", value: "").execute()
        try await client.from(Tables.bodyMapRecovery).delete().neq("id", value: "").execute()
        try await client.from(Tables.streaks).delete().neq("id", value: "").execute()
    }
}
