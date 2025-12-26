# BetterFit Apple Watch App

An Apple Watch companion app for BetterFit that provides workout tracking on your wrist.

## Features

### 🏋️ Workout Tracking
- **Browse Workouts**: View recommended and available workouts
- **Start Workouts**: Begin tracking with a single tap
- **Live Timer**: Track elapsed workout time in real-time
- **Easy Navigation**: Large, touch-friendly buttons optimized for watch interaction

### 📊 Set & Rep Tracking
- **Visual Controls**: Large +/- buttons for easy adjustments
- **Rep Counter**: Bold, easy-to-read display of current reps
- **Weight Tracking**: Adjust weight in 5lb increments with quick buttons
- **Set Progress**: See which set you're on and mark sets as complete
- **Auto-Advance**: Automatically moves to next set after completion

### 🔔 Workout Reminders
- **Custom Schedule**: Set reminder times that work for you
- **Day Selection**: Choose which days to receive reminders
- **Smart Notifications**: AI-powered suggestions based on your workout history and recovery

### 🎯 User Experience
- **Large Buttons**: All interactive elements are sized for easy tapping on the watch
- **Clear Typography**: High-contrast, bold text for quick reading
- **Progress Indicators**: Visual feedback for sets, exercises, and workout completion
- **Seamless Navigation**: Intuitive flow between exercises and sets

## Project Structure

```
Apps/iOS/BetterFitWatchApp/
├── BetterFitWatchApp.swift      # App entry point and state management
├── ContentView.swift             # Main navigation container
├── WorkoutListView.swift         # Browse and start workouts
├── ActiveWorkoutView.swift       # Live workout tracking with set/rep controls
├── NotificationsView.swift       # Reminder configuration
├── Info.plist                    # watchOS app configuration
└── Assets.xcassets/              # App icons and colors
```

## Building & Running

### Prerequisites
- Xcode 15+ with watchOS 10+ SDK
- mise installed (for task automation)

### Commands

```bash
# Generate Xcode project
mise run watch:gen

# Open project in Xcode
mise run watch:open

# Build for watchOS Simulator
mise run watch:build
```

## UI Design Principles

### Button Sizing
- **Primary Actions**: Full-width buttons with prominent styling
- **Increment Controls**: Large circular buttons (title font size) for +/-
- **Navigation**: Bordered/prominent button styles for clear hierarchy

### Typography
- **Numbers**: Size 48pt for reps, 32pt for weight (monospacedDigit)
- **Headlines**: Title2/Title3 for exercise names
- **Captions**: Small, secondary-colored text for labels

### Colors
- **Green**: Completion states and positive actions
- **Red**: Destructive actions and decrement controls
- **Blue**: Primary actions (complete set, next exercise)
- **Gray Opacity**: Background cards for grouped content

## Integration with BetterFit Library

The watch app uses the core `BetterFit` library for:
- **Workout Management**: Starting and completing workouts
- **Smart Recommendations**: AI-powered workout suggestions
- **Notification Scheduling**: Smart reminder system
- **History Tracking**: Synced workout records
- **Recovery Integration**: Body map and recovery tracking

## Future Enhancements

- [ ] Live heart rate tracking during workouts
- [ ] Apple Health integration for calories and activity rings
- [ ] Voice control for hands-free set tracking
- [ ] Haptic feedback for set completions and rest timers
- [ ] Complications for quick workout access
- [ ] Standalone watch app (independent of iPhone)
- [ ] Rep detection via motion sensors
- [ ] Social features: share workouts with friends

## Notes

- The watch app requires the BetterFit SwiftPM package (supports watchOS 10+)
- Project is managed via XcodeGen - edit `Apps/iOS/project.yml` for configuration changes
- Do not manually edit `BetterFit.xcodeproj` - regenerate with `mise run watch:gen`
