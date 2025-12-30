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

    // MARK: - Helpers

    /// Gets the current authenticated user's ID
    private func getCurrentUserId() async throws -> UUID {
        guard let user = client.auth.currentUser else {
            throw PersistenceError.notAuthenticated
        }
        return user.id
    }

    /// Error types for persistence operations
    public enum PersistenceError: Error, LocalizedError {
        case notAuthenticated

        public var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "User must be authenticated to perform this operation"
            }
        }
    }

    // MARK: - Workouts

    /// Wrapper to include user_id when saving workouts
    private struct WorkoutRecord: Encodable {
        let id: UUID
        let userId: UUID
        let name: String
        let exercises: [WorkoutExercise]
        let date: Date
        let duration: TimeInterval?
        let isCompleted: Bool
        let templateId: UUID?

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case name
            case exercises
            case date
            case duration
            case isCompleted = "is_completed"
            case templateId = "template_id"
        }
    }

    public func saveWorkout(_ workout: Workout) async throws {
        let userId = try await getCurrentUserId()
        let record = WorkoutRecord(
            id: workout.id,
            userId: userId,
            name: workout.name,
            exercises: workout.exercises,
            date: workout.date,
            duration: workout.duration,
            isCompleted: workout.isCompleted,
            templateId: workout.templateId
        )
        try await client
            .from(Tables.workouts)
            .upsert(record)
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

    /// Wrapper to include user_id when saving templates
    private struct TemplateRecord: Encodable {
        let id: UUID
        let userId: UUID
        let name: String
        let description: String?
        let exercises: [TemplateExercise]
        let tags: [String]
        let createdDate: Date
        let lastUsedDate: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case name
            case description
            case exercises
            case tags
            case createdDate = "created_date"
            case lastUsedDate = "last_used_date"
        }
    }

    public func saveTemplate(_ template: WorkoutTemplate) async throws {
        let userId = try await getCurrentUserId()
        let record = TemplateRecord(
            id: template.id,
            userId: userId,
            name: template.name,
            description: template.description,
            exercises: template.exercises,
            tags: template.tags,
            createdDate: template.createdDate,
            lastUsedDate: template.lastUsedDate
        )
        try await client
            .from(Tables.templates)
            .upsert(record)
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

    /// Wrapper to include user_id when saving plans
    private struct PlanRecord: Encodable {
        let id: UUID
        let userId: UUID
        let name: String
        let description: String?
        let weeks: [TrainingWeek]
        let currentWeek: Int
        let goal: TrainingGoal
        let createdDate: Date
        let aiAdapted: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case name
            case description
            case weeks
            case currentWeek = "current_week"
            case goal
            case createdDate = "created_date"
            case aiAdapted = "ai_adapted"
        }
    }

    public func savePlan(_ plan: TrainingPlan) async throws {
        let userId = try await getCurrentUserId()
        let record = PlanRecord(
            id: plan.id,
            userId: userId,
            name: plan.name,
            description: plan.description,
            weeks: plan.weeks,
            currentWeek: plan.currentWeek,
            goal: plan.goal,
            createdDate: plan.createdDate,
            aiAdapted: plan.aiAdapted
        )
        try await client
            .from(Tables.plans)
            .upsert(record)
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

    /// Wrapper to include user_id when saving profiles
    private struct ProfileRecord: Encodable {
        let id: UUID
        let userId: UUID
        let username: String
        let currentStreak: Int
        let longestStreak: Int
        let totalWorkouts: Int
        let activeChallenges: [UUID]

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case username
            case currentStreak = "current_streak"
            case longestStreak = "longest_streak"
            case totalWorkouts = "total_workouts"
            case activeChallenges = "active_challenges"
        }
    }

    public func saveUserProfile(_ profile: UserProfile) async throws {
        let userId = try await getCurrentUserId()
        let record = ProfileRecord(
            id: profile.id,
            userId: userId,
            username: profile.username,
            currentStreak: profile.currentStreak,
            longestStreak: profile.longestStreak,
            totalWorkouts: profile.totalWorkouts,
            activeChallenges: profile.activeChallenges
        )
        try await client
            .from(Tables.userProfiles)
            .upsert(record)
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

    /// Wrapper to include user_id when saving recovery data
    private struct RecoveryRecord: Encodable {
        let userId: UUID
        let regions: [BodyRegion: RecoveryStatus]
        let lastUpdated: Date

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case regions
            case lastUpdated = "last_updated"
        }
    }

    public func saveBodyMapRecovery(_ recovery: BodyMapRecovery) async throws {
        let userId = try await getCurrentUserId()
        let record = RecoveryRecord(
            userId: userId,
            regions: recovery.regions,
            lastUpdated: recovery.lastUpdated
        )
        try await client
            .from(Tables.bodyMapRecovery)
            .upsert(record, onConflict: "user_id")
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
        let userId = try await getCurrentUserId()

        struct StreakDataRequest: Encodable {
            let userId: UUID
            let currentStreak: Int
            let longestStreak: Int
            let lastWorkoutDate: String?

            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case currentStreak = "current_streak"
                case longestStreak = "longest_streak"
                case lastWorkoutDate = "last_workout_date"
            }
        }

        let lastWorkoutDateStr = lastWorkoutDate.map { ISO8601DateFormatter().string(from: $0) }
        let streakData = StreakDataRequest(
            userId: userId,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastWorkoutDate: lastWorkoutDateStr
        )

        try await client
            .from(Tables.streaks)
            .upsert(streakData, onConflict: "user_id")
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
