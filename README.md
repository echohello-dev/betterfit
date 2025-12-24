# BetterFit

**Open-source strength training coach for iOS and Apple Watch**

BetterFit is a comprehensive workout tracking application that combines intelligent automation with powerful features to optimize your strength training journey.

## Core Features

### 🎯 Plan Mode
- **AI-Adapted Training Plans**: Dynamic workout programming that automatically adjusts based on your performance
- **Progressive Overload Tracking**: AI analyzes your workout history and suggests volume/intensity adjustments
- **Multiple Training Goals**: Strength, hypertrophy, endurance, powerlifting, general fitness, and weight loss
- **Weekly Progression**: Structured training weeks with automatic advancement

### 📋 Reusable Workout Templates
- **Template Library**: Create and save workout templates for quick reuse
- **Smart Template Creation**: Convert any completed workout into a reusable template
- **Template Tags**: Organize templates with custom tags (e.g., "Push Day", "Legs", "Full Body")
- **Recent Templates**: Quick access to your most frequently used templates

### 🔄 Fast Equipment Swaps
- **Available Equipment Tracking**: Set which equipment you have access to
- **Automatic Alternatives**: Smart suggestions for alternative exercises when equipment isn't available
- **Muscle Group Matching**: Alternative exercises target the same muscle groups
- **One-Tap Swaps**: Quickly replace exercises in your workout

### 🗺️ Body-Map Recovery View
- **Visual Recovery Tracking**: Body map showing recovery status for each muscle group region
- **Recovery States**: Recovered, slightly fatigued, fatigued, and sore
- **Time-Based Recovery**: Automatic recovery progression based on time elapsed
- **Smart Exercise Recommendations**: Suggests exercises based on which muscle groups are ready to train

### 🏆 Social Features
- **Workout Streaks**: Track consecutive workout days and compete with yourself
- **Challenges**: Create and join workout challenges with friends
- **Multiple Challenge Types**: 
  - Workout count challenges
  - Total volume challenges
  - Consecutive day challenges
  - Specific exercise challenges
- **Leaderboards**: Real-time progress tracking for all challenge participants

### 🔔 Smart Notifications
- **Optimal Time Detection**: Learns your typical workout times and reminds you accordingly
- **Streak Maintenance**: Gentle reminders to maintain your workout streak
- **Rest Day Alerts**: Warns when you might be overtraining
- **Plan Progress Updates**: Weekly updates on your training plan progress
- **Minimal Admin Time**: Intelligent notifications that reduce gym planning overhead

### ⌚ Apple Watch Auto-Tracking
- **Sensor-Based Rep Detection**: Automatically counts reps using Watch accelerometer and gyroscope
- **Set Completion Detection**: Identifies rest periods to automatically complete sets
- **Real-Time Tracking**: Live rep counting during your workout
- **Hands-Free Training**: Focus on your workout, not on manually logging

### 🎨 Clean Consistent 3D/AI Equipment Images
- **3D Equipment Visualization**: High-quality 3D renders of gym equipment
- **AI-Generated Images**: Consistent visual style across all exercises
- **Equipment Library**: Complete library of barbell, dumbbell, machine, cable, bodyweight, and more
- **Custom Exercise Images**: Support for custom exercise visualizations

## Technical Implementation

### Architecture
- **Swift Package Manager**: Modern Swift package with iOS 17+ and watchOS 10+ support
- **Model-Driven Design**: Clean separation between data models and business logic
- **Service Layer**: Modular services for tracking, AI, images, and notifications
- **Feature Modules**: Organized feature-specific implementations

### Core Components

#### Models
- `Exercise`: Exercise definitions with equipment and muscle group targeting
- `Workout`: Workout sessions with exercises and sets
- `WorkoutTemplate`: Reusable workout configurations
- `TrainingPlan`: Structured multi-week training programs
- `BodyMapRecovery`: Recovery tracking for body regions
- `UserProfile`, `Challenge`, `Streak`: Social features

#### Services
- `AutoTrackingService`: Apple Watch sensor data processing
- `AIAdaptationService`: Workout analysis and plan adaptation
- `EquipmentImageService`: 3D/AI image management

#### Features
- `PlanManager`: Training plan management
- `TemplateManager`: Workout template operations
- `EquipmentSwapManager`: Equipment alternative suggestions
- `BodyMapManager`: Recovery tracking and recommendations
- `SocialManager`: Streaks and challenges
- `SmartNotificationManager`: Intelligent notification scheduling

## Installation

Add BetterFit to your Swift project:

```swift
dependencies: [
    .package(url: "https://github.com/echohello-dev/betterfit.git", from: "1.0.0")
]
```

## Usage

```swift
import BetterFit

// Initialize BetterFit
let betterFit = BetterFit()

// Create a workout from a template
if let workout = betterFit.templateManager.createWorkout(from: templateId) {
    betterFit.startWorkout(workout)
}

// Auto-track with Watch sensors
let motionData = MotionData(acceleration: [x, y, z], rotation: [rx, ry, rz])
if let event = betterFit.processMotionData(motionData) {
    switch event {
    case .repDetected(let count):
        print("Detected rep #\(count)")
    case .setCompleted(let reps):
        print("Set complete with \(reps) reps")
    case .exerciseCompleted:
        print("Exercise complete")
    }
}

// Complete workout (automatic streak update, recovery tracking, AI analysis)
betterFit.completeWorkout(workout)

// Check recovery status
let recoveryStatus = betterFit.bodyMapManager.getRecoveryStatus(for: .legs)
print("Legs recovery: \(recoveryStatus)")

// Get AI recommendations
if let plan = betterFit.planManager.getActivePlan() {
    let adaptations = betterFit.aiAdaptationService.analyzePerformance(
        workouts: betterFit.getWorkoutHistory(),
        currentPlan: plan
    )
}
```

## Building and Testing

```bash
# Build the package
swift build

# Run tests
swift test

# Run specific tests
swift test --filter ModelTests
```

## Run the iOS host app (Simulator)

BetterFit is a SwiftPM library; the iOS host app lives in `Apps/iOS` and exists just to run the package on Simulator.

```bash
mise run ios:open
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See LICENSE file for details.
