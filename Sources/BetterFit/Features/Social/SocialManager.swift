import Foundation

/// Manages social features including streaks and challenges
public class SocialManager {
    private var userProfile: UserProfile
    private var challenges: [Challenge]
    private var streak: Streak
    
    public init(
        userProfile: UserProfile = UserProfile(username: "User"),
        challenges: [Challenge] = [],
        streak: Streak = Streak()
    ) {
        self.userProfile = userProfile
        self.challenges = challenges
        self.streak = streak
    }
    
    // MARK: - Streak Management
    
    /// Update streak with completed workout
    public func recordWorkout(date: Date = Date()) {
        streak.updateWithWorkout(date: date)
        userProfile.currentStreak = streak.currentStreak
        userProfile.longestStreak = max(userProfile.longestStreak, streak.currentStreak)
        userProfile.totalWorkouts += 1
    }
    
    /// Get current streak
    public func getCurrentStreak() -> Int {
        return streak.currentStreak
    }
    
    /// Get longest streak
    public func getLongestStreak() -> Int {
        return streak.longestStreak
    }
    
    // MARK: - Challenge Management
    
    /// Get all challenges
    public func getAllChallenges() -> [Challenge] {
        return challenges
    }
    
    /// Get active challenges for user
    public func getActiveChallenges() -> [Challenge] {
        let now = Date()
        return challenges.filter { challenge in
            challenge.startDate <= now &&
            challenge.endDate >= now &&
            challenge.participants.contains(userProfile.id)
        }
    }
    
    /// Join a challenge
    public func joinChallenge(_ challengeId: UUID) -> Bool {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
            return false
        }
        
        if !challenges[index].participants.contains(userProfile.id) {
            challenges[index].participants.append(userProfile.id)
            userProfile.activeChallenges.append(challengeId)
        }
        
        return true
    }
    
    /// Leave a challenge
    public func leaveChallenge(_ challengeId: UUID) -> Bool {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
            return false
        }
        
        challenges[index].participants.removeAll { $0 == userProfile.id }
        userProfile.activeChallenges.removeAll { $0 == challengeId }
        
        return true
    }
    
    /// Create a new challenge
    public func createChallenge(_ challenge: Challenge) {
        challenges.append(challenge)
    }
    
    /// Update challenge progress
    public func updateChallengeProgress(
        challengeId: UUID,
        userId: UUID,
        progress: Double
    ) -> Bool {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
            return false
        }
        
        challenges[index].progress[userId] = progress
        return true
    }
    
    /// Get challenge leaderboard
    public func getChallengeLeaderboard(challengeId: UUID) -> [(userId: UUID, progress: Double)] {
        guard let challenge = challenges.first(where: { $0.id == challengeId }) else {
            return []
        }
        
        return challenge.progress.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }
    
    /// Check if user completed challenge goal
    public func checkChallengeCompletion(challengeId: UUID, userId: UUID) -> Bool {
        guard let challenge = challenges.first(where: { $0.id == challengeId }),
              let progress = challenge.progress[userId] else {
            return false
        }
        
        switch challenge.goal {
        case .workoutCount(let target):
            return progress >= Double(target)
        case .totalVolume(let target):
            return progress >= target
        case .consecutiveDays(let target):
            return progress >= Double(target)
        case .specificExercise(_, let target):
            return progress >= Double(target)
        }
    }
    
    // MARK: - User Profile
    
    /// Get user profile
    public func getUserProfile() -> UserProfile {
        return userProfile
    }
    
    /// Update user profile
    public func updateUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
    }
}
