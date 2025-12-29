import Foundation

/// BetterFit - Open-source strength training coach for iOS and Apple Watch
///
/// Core Features:
/// - Plan mode with AI adaptation
/// - Reusable workout templates
/// - Fast equipment swaps
/// - Body-map recovery view
/// - Social streaks and challenges
/// - Smart notifications
/// - Auto-tracking via Watch sensors
/// - Clean consistent 3D/AI equipment images
public class BetterFit {

    // MARK: - Core Services

    public let planManager: PlanManager
    public let templateManager: TemplateManager
    public let equipmentSwapManager: EquipmentSwapManager
    public let bodyMapManager: BodyMapManager
    public let socialManager: SocialManager
    public let notificationManager: SmartNotificationManager

    // MARK: - Advanced Services

    public let autoTrackingService: AutoTrackingService
    public let aiAdaptationService: AIAdaptationService
    public let imageService: EquipmentImageService

    // MARK: - Persistence

    public let persistenceService: PersistenceProtocol

    // MARK: - State

    private var workoutHistory: [Workout] = []

    // MARK: - Initialization

    public init(persistenceService: PersistenceProtocol? = nil) {
        // Default to local persistence (guest mode) if none provided
        self.persistenceService = persistenceService ?? LocalPersistenceService()

        self.planManager = PlanManager()
        self.templateManager = TemplateManager()
        self.equipmentSwapManager = EquipmentSwapManager()
        self.bodyMapManager = BodyMapManager()
        self.socialManager = SocialManager()
        self.notificationManager = SmartNotificationManager()

        self.autoTrackingService = AutoTrackingService()
        self.aiAdaptationService = AIAdaptationService()
        self.imageService = EquipmentImageService()

        // Load persisted data
        Task {
            await loadPersistedData()
        }
    }

    // MARK: - Data Loading

    /// Load persisted data from storage
    private func loadPersistedData() async {
        do {
            // Load workout history
            workoutHistory = try await persistenceService.getWorkouts()

            // Load user profile
            if let profile = try await persistenceService.getUserProfile() {
                socialManager.updateUserProfile(profile)
            }

            // Load streak data
            _ = try await persistenceService.getStreakData()
            // Update social manager with streak data (implementation depends on SocialManager API)

            // Load active plan
            if let activePlan = try await persistenceService.getActivePlan() {
                planManager.updatePlan(activePlan)
            }

            // Load templates
            let templates = try await persistenceService.getTemplates()
            for template in templates {
                templateManager.addTemplate(template)
            }

            // Load recovery data
            if try await persistenceService.getBodyMapRecovery() != nil {
                // Update body map with recovery data (implementation depends on BodyMapManager API)
                // bodyMapManager.setRecovery(recovery)
            }

        } catch {
            print("Failed to load persisted data: \(error)")
        }
    }

    // MARK: - Workout Management

    /// Start a new workout
    public func startWorkout(_ workout: Workout) {
        autoTrackingService.startTracking(workout: workout)

        // Schedule smart notifications
        scheduleWorkoutNotifications()
    }

    /// Complete a workout
    public func completeWorkout(_ workout: Workout) {
        autoTrackingService.stopTracking()

        // Record in history
        workoutHistory.append(workout)

        // Persist workout
        Task {
            try? await persistenceService.saveWorkout(workout)
        }

        // Update recovery map
        bodyMapManager.recordWorkout(workout)

        // Update streak
        socialManager.recordWorkout(date: workout.date)

        // Persist user profile, streak data, and recovery map
        Task {
            try? await persistenceService.saveUserProfile(socialManager.getUserProfile())
            try? await persistenceService.saveStreakData(
                currentStreak: socialManager.getCurrentStreak(),
                longestStreak: socialManager.getLongestStreak(),
                lastWorkoutDate: socialManager.getLastWorkoutDate()
            )
            try? await persistenceService.saveBodyMapRecovery(bodyMapManager.getRecoveryMap())
        }

        // Analyze and adapt plan if needed
        if let activePlan = planManager.getActivePlan() {
            let adaptations = aiAdaptationService.analyzePerformance(
                workouts: workoutHistory,
                currentPlan: activePlan
            )

            if !adaptations.isEmpty {
                var updatedPlan = activePlan
                aiAdaptationService.applyAdaptations(adaptations, to: &updatedPlan)
                planManager.updatePlan(updatedPlan)

                // Persist updated plan
                Task {
                    try? await persistenceService.savePlan(updatedPlan)
                }
            }
        }
    }

    /// Get workout history
    public func getWorkoutHistory() -> [Workout] {
        return workoutHistory
    }

    // MARK: - Smart Features

    // MARK: - Suggested Workouts Section
    /// Get recommended workout based on recovery and plan
    public func getRecommendedWorkout() -> Workout? {
        // Get current plan week
        guard let activePlan = planManager.getActivePlan(),
            let currentWeek = activePlan.getCurrentWeek(),
            let firstWorkoutId = currentWeek.workouts.first
        else {
            return nil
        }

        // Get template for workout
        guard let template = templateManager.getTemplate(id: firstWorkoutId) else {
            return nil
        }

        var workout = template.createWorkout()

        // Check for equipment swaps needed
        let swaps = equipmentSwapManager.suggestSwaps(for: workout)
        if !swaps.isEmpty {
            // Apply first available alternative for each
            for (original, alternatives) in swaps {
                if let alternative = alternatives.first {
                    _ = equipmentSwapManager.applySwap(
                        workout: &workout,
                        originalExerciseId: original.id,
                        newExercise: alternative
                    )
                }
            }
        }

        return workout
    }

    /// Schedule smart notifications
    private func scheduleWorkoutNotifications() {
        notificationManager.scheduleNotifications(
            userProfile: socialManager.getUserProfile(),
            workoutHistory: workoutHistory,
            activePlan: planManager.getActivePlan()
        )
    }

    // MARK: - Health Integration

    /// Process motion data from Watch
    public func processMotionData(_ data: MotionData) -> TrackingEvent? {
        return autoTrackingService.processMotionData(data)
    }

    /// Get tracking status
    public func getTrackingStatus() -> TrackingStatus {
        return autoTrackingService.getTrackingStatus()
    }

    /// Get active workout when auto-tracking is running
    public func getActiveWorkout() -> Workout? {
        return autoTrackingService.getCurrentWorkout()
    }
}
