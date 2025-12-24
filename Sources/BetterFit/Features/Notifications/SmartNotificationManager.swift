import Foundation

/// Smart notification manager to minimize gym admin time
public class SmartNotificationManager {
    private var scheduledNotifications: [SmartNotification] = []
    
    public init() {}
    
    /// Schedule smart notifications based on workout patterns
    public func scheduleNotifications(
        userProfile: UserProfile,
        workoutHistory: [Workout],
        activePlan: TrainingPlan?
    ) {
        scheduledNotifications.removeAll()
        
        // Workout reminder based on typical workout times
        if let optimalTime = detectOptimalWorkoutTime(workoutHistory) {
            let notification = SmartNotification(
                type: .workoutReminder,
                scheduledTime: optimalTime,
                message: "Time for your workout! Let's maintain that \(userProfile.currentStreak)-day streak."
            )
            scheduledNotifications.append(notification)
        }
        
        // Rest day reminder for overtraining
        if needsRestDayReminder(workoutHistory) {
            let notification = SmartNotification(
                type: .restDayReminder,
                scheduledTime: Date().addingTimeInterval(3600),
                message: "Your body needs recovery. Consider taking a rest day."
            )
            scheduledNotifications.append(notification)
        }
        
        // Plan progress update
        if let plan = activePlan, let week = plan.getCurrentWeek() {
            let notification = SmartNotification(
                type: .planProgress,
                scheduledTime: Date().addingTimeInterval(86400),
                message: "Week \(week.weekNumber) complete! Ready for the next challenge?"
            )
            scheduledNotifications.append(notification)
        }
        
        // Streak maintenance
        if userProfile.currentStreak > 0 {
            let notification = SmartNotification(
                type: .streakMaintenance,
                scheduledTime: Date().addingTimeInterval(18 * 3600),
                message: "Don't break your \(userProfile.currentStreak)-day streak! Quick workout?"
            )
            scheduledNotifications.append(notification)
        }
    }
    
    /// Detect optimal workout time based on history
    private func detectOptimalWorkoutTime(_ workouts: [Workout]) -> Date? {
        guard !workouts.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let hourCounts = workouts.reduce(into: [Int: Int]()) { counts, workout in
            let hour = calendar.component(.hour, from: workout.date)
            counts[hour, default: 0] += 1
        }
        
        // Find most common hour
        guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        // Schedule for tomorrow at that hour
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = mostCommonHour
        components.minute = 0
        
        if let scheduled = calendar.date(from: components),
           scheduled < Date() {
            // If time has passed today, schedule for tomorrow
            return calendar.date(byAdding: .day, value: 1, to: scheduled)
        }
        
        return calendar.date(from: components)
    }
    
    /// Check if user needs a rest day reminder
    private func needsRestDayReminder(_ workouts: [Workout]) -> Bool {
        let recentWorkouts = workouts.filter {
            $0.date > Date().addingTimeInterval(-7 * 86400)
        }
        
        // More than 6 workouts in a week might indicate overtraining
        return recentWorkouts.count > 6
    }
    
    /// Get all scheduled notifications
    public func getScheduledNotifications() -> [SmartNotification] {
        return scheduledNotifications.filter { $0.scheduledTime > Date() }
    }
    
    /// Cancel a notification
    public func cancelNotification(id: UUID) {
        scheduledNotifications.removeAll { $0.id == id }
    }
    
    /// Cancel all notifications
    public func cancelAllNotifications() {
        scheduledNotifications.removeAll()
    }
}

/// Smart notification model
public struct SmartNotification: Identifiable, Equatable {
    public let id: UUID
    public var type: NotificationType
    public var scheduledTime: Date
    public var message: String
    
    public init(
        id: UUID = UUID(),
        type: NotificationType,
        scheduledTime: Date,
        message: String
    ) {
        self.id = id
        self.type = type
        self.scheduledTime = scheduledTime
        self.message = message
    }
}

/// Notification types
public enum NotificationType: String, Codable {
    case workoutReminder
    case restDayReminder
    case planProgress
    case streakMaintenance
    case challengeUpdate
    case recoveryAlert
}
