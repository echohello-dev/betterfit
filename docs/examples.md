# BetterFit Usage Examples

This document provides practical examples of using BetterFit in your iOS/watchOS app.

## Quick Start

```swift
import BetterFit

// Initialize the BetterFit instance
let betterFit = BetterFit()
```

## Creating a Workout Template

```swift
// Define exercises
let benchPress = Exercise(
    name: "Bench Press",
    equipmentRequired: .barbell,
    muscleGroups: [.chest, .triceps]
)

let squat = Exercise(
    name: "Squat",
    equipmentRequired: .barbell,
    muscleGroups: [.quads, .glutes, .hamstrings]
)

// Create template exercises with target sets
let templateExercises = [
    TemplateExercise(
        exercise: benchPress,
        targetSets: [
            TargetSet(reps: 8, weight: 185),
            TargetSet(reps: 8, weight: 185),
            TargetSet(reps: 8, weight: 185)
        ],
        restTime: 90
    ),
    TemplateExercise(
        exercise: squat,
        targetSets: [
            TargetSet(reps: 5, weight: 225),
            TargetSet(reps: 5, weight: 225),
            TargetSet(reps: 5, weight: 225)
        ],
        restTime: 180
    )
]

// Create and save the template
let pushTemplate = WorkoutTemplate(
    name: "Upper Body Push",
    description: "Chest and triceps focus",
    exercises: templateExercises,
    tags: ["push", "chest", "strength"]
)

betterFit.templateManager.addTemplate(pushTemplate)
```

## Creating a Workout from Template

```swift
// Create workout from template
let workout = betterFit.templateManager.createWorkout(from: pushTemplate.id)

if let workout = workout {
    // Start the workout (enables auto-tracking)
    betterFit.startWorkout(workout)
}
```

## Using Auto-Tracking with Apple Watch

```swift
import CoreMotion

// In your watchOS app, collect motion data
let motionManager = CMMotionManager()
motionManager.startDeviceMotionUpdates()

// Process motion data in your workout view
func processMotionUpdate(_ motion: CMDeviceMotion) {
    let motionData = MotionData(
        acceleration: [
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z
        ],
        rotation: [
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z
        ],
        heartRate: getCurrentHeartRate()
    )
    
    // Process with BetterFit
    if let event = betterFit.processMotionData(motionData) {
        switch event {
        case .repDetected(let count):
            updateUI(repCount: count)
        case .setCompleted(let reps):
            completeSet(reps: reps)
        case .exerciseCompleted:
            moveToNextExercise()
        }
    }
}
```

## Handling Equipment Swaps

```swift
// Set available equipment (e.g., at a home gym)
betterFit.equipmentSwapManager.setAvailableEquipment([
    .dumbbell,
    .bodyweight,
    .bands
])

// Get swap suggestions for a workout
let swaps = betterFit.equipmentSwapManager.suggestSwaps(for: workout)

for (original, alternatives) in swaps {
    print("Replace \(original.name) with:")
    for alt in alternatives {
        print("  - \(alt.name)")
    }
}

// Apply a swap
if let firstAlternative = swaps.first?.alternatives.first {
    var updatedWorkout = workout
    betterFit.equipmentSwapManager.applySwap(
        workout: &updatedWorkout,
        originalExerciseId: swaps.first!.original.id,
        newExercise: firstAlternative
    )
}
```

## Creating a Training Plan

```swift
// Create training weeks
let week1 = TrainingWeek(
    weekNumber: 1,
    workouts: [pushTemplate.id],
    notes: "Focus on form"
)

let week2 = TrainingWeek(
    weekNumber: 2,
    workouts: [pushTemplate.id],
    notes: "Increase intensity by 5%"
)

// Create the plan
let plan = TrainingPlan(
    name: "8-Week Strength Builder",
    description: "Progressive strength training",
    weeks: [week1, week2],
    goal: .strength
)

// Add to plan manager and set as active
betterFit.planManager.addPlan(plan)
betterFit.planManager.setActivePlan(plan.id)
```

## Completing a Workout and AI Adaptation

```swift
// Complete the workout
betterFit.completeWorkout(workout)

// AI automatically analyzes performance and adapts the plan
// Check what adaptations were suggested
if let activePlan = betterFit.planManager.getActivePlan() {
    let adaptations = betterFit.aiAdaptationService.analyzePerformance(
        workouts: betterFit.getWorkoutHistory(),
        currentPlan: activePlan
    )
    
    for adaptation in adaptations {
        print("AI Suggestion: \(adaptation.description)")
    }
}
```

## Checking Recovery Status

```swift
// Check overall recovery
let overallRecovery = betterFit.bodyMapManager.getOverallRecoveryPercentage()
print("Overall recovery: \(overallRecovery)%")

// Check specific body regions
let legStatus = betterFit.bodyMapManager.getRecoveryStatus(for: .legs)
print("Leg recovery: \(legStatus)")

// Check if ready to train
let readyForLegs = betterFit.bodyMapManager.isReadyForTraining(region: .legs)
if readyForLegs {
    print("Ready for leg day!")
} else {
    print("Legs need more recovery time")
}

// Get recommended exercises based on recovery
let allExercises = [squat, benchPress, /* ... */]
let recommended = betterFit.bodyMapManager.getRecommendedExercises(
    available: allExercises,
    avoidSoreRegions: true
)
```

## Social Features

### Managing Streaks

```swift
// Record a workout (automatically updates streak)
betterFit.socialManager.recordWorkout()

// Get current streak
let currentStreak = betterFit.socialManager.getCurrentStreak()
print("Current streak: \(currentStreak) days")

// Get longest streak
let longestStreak = betterFit.socialManager.getLongestStreak()
print("Longest streak: \(longestStreak) days")
```

### Creating and Joining Challenges

```swift
// Create a challenge
let challenge = Challenge(
    name: "30 Day Challenge",
    description: "Complete 30 workouts in 30 days",
    goal: .workoutCount(target: 30),
    startDate: Date(),
    endDate: Date().addingTimeInterval(30 * 86400)
)

betterFit.socialManager.createChallenge(challenge)

// Join a challenge
betterFit.socialManager.joinChallenge(challenge.id)

// Update progress
betterFit.socialManager.updateChallengeProgress(
    challengeId: challenge.id,
    userId: userProfile.id,
    progress: 15 // 15 workouts completed
)

// Check leaderboard
let leaderboard = betterFit.socialManager.getChallengeLeaderboard(
    challengeId: challenge.id
)
for (index, entry) in leaderboard.enumerated() {
    print("\(index + 1). User \(entry.userId): \(entry.progress)")
}
```

## Smart Notifications

```swift
// Schedule smart notifications
betterFit.notificationManager.scheduleNotifications(
    userProfile: betterFit.socialManager.getUserProfile(),
    workoutHistory: betterFit.getWorkoutHistory(),
    activePlan: betterFit.planManager.getActivePlan()
)

// Get scheduled notifications
let scheduled = betterFit.notificationManager.getScheduledNotifications()
for notification in scheduled {
    print("\(notification.type): \(notification.message)")
    print("Scheduled for: \(notification.scheduledTime)")
}

// Cancel a specific notification
betterFit.notificationManager.cancelNotification(id: notificationId)

// Cancel all notifications
betterFit.notificationManager.cancelAllNotifications()
```

## Equipment Images

```swift
// Get image for equipment
if let image = betterFit.imageService.getImage(for: .barbell) {
    print("Barbell image URL: \(image.url)")
    print("Is 3D: \(image.is3D)")
    print("Is AI generated: \(image.isAIGenerated)")
}

// Get image for an exercise
if let exerciseImage = betterFit.imageService.getImage(for: benchPress) {
    // Load image from URL
    loadImage(from: exerciseImage.url)
}

// Generate AI image for custom exercise
Task {
    do {
        let aiImage = try await betterFit.imageService.generateAIImage(
            for: benchPress,
            style: .realistic3D
        )
        print("Generated image: \(aiImage.url)")
    } catch {
        print("Failed to generate image: \(error)")
    }
}
```

## Complete Workout Flow Example

```swift
func performWorkout() {
    // 1. Get or create workout
    let workout: Workout
    if let template = betterFit.templateManager.getRecentTemplates(limit: 1).first {
        workout = betterFit.templateManager.createWorkout(from: template.id)!
    } else {
        // Create a new workout
        workout = Workout(name: "Quick Session")
    }
    
    // 2. Check for equipment swaps
    var finalWorkout = workout
    let swaps = betterFit.equipmentSwapManager.suggestSwaps(for: workout)
    if !swaps.isEmpty {
        // Apply swaps if needed
        for (original, alternatives) in swaps {
            if let alt = alternatives.first {
                betterFit.equipmentSwapManager.applySwap(
                    workout: &finalWorkout,
                    originalExerciseId: original.id,
                    newExercise: alt
                )
            }
        }
    }
    
    // 3. Start workout with auto-tracking
    betterFit.startWorkout(finalWorkout)
    
    // 4. During workout: process motion data
    // (See auto-tracking example above)
    
    // 5. Complete workout
    betterFit.completeWorkout(finalWorkout)
    
    // 6. Check updated streak and recovery
    print("Streak: \(betterFit.socialManager.getCurrentStreak())")
    print("Recovery: \(betterFit.bodyMapManager.getOverallRecoveryPercentage())%")
}
```

## Best Practices

1. **Initialize Once**: Create a single BetterFit instance and reuse it throughout your app
2. **Save State**: Persist templates, plans, and user profiles to storage
3. **Background Updates**: Update recovery status in the background as time passes
4. **Watch Connectivity**: Use WatchConnectivity framework to sync workout data between iOS and watchOS
5. **Notification Permissions**: Request notification permissions before scheduling smart notifications
6. **Motion Permissions**: Request motion and fitness permissions on Apple Watch for auto-tracking
