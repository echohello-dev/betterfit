# BetterFit Apple Watch App

A standalone Apple Watch app for manual workout tracking on your wrist. The MVP uses three bundled workout templates and saves completed workouts through BetterFit’s local persistence. iPhone sync and HealthKit recording are not included.

## Features

### 🏋️ Workout Tracking
- **Browse Workouts**: View recommended and available workouts
- **Start Workouts**: Begin tracking with a single tap
- **Live Timer**: Track active workout time, excluding pauses, with a once-per-second display
- **Easy Navigation**: Large, touch-friendly buttons optimized for watch interaction

### 📊 Set & Rep Tracking
- **One-tap Logging**: The pinned Log Set action records the displayed targets without scrolling or opening an editor
- **Quick Editing**: Tap reps or weight and turn the Digital Crown directly on the workout screen, then log without opening or closing a sheet. The selected field gains a border and Crown icon; logging or opening Actions releases Crown focus.
- **Touch Alternative**: Long-press a value or choose Edit Reps / Edit Weight in Actions for the large +/- editor. VoiceOver also exposes adjustable actions and Edit with Buttons.
- **Undo**: Reopen the last logged set from Actions, or directly from the completion screen
- **Rep Counter**: Bold, easy-to-read display of current reps
- **Weight Tracking**: Adjust weight in 5lb increments with the Crown or quick buttons
- **Set Progress**: See which set you're on and mark sets as complete
- **Finish or Discard**: Save after all sets are logged, or open Actions to discard with confirmation
- **Automatic Rest**: A 60-second countdown starts after logging, alongside the next set; logging never requires dismissing it. Choose Off, 30, 60, 90, 120, or 180 seconds in Actions. The preference persists between workouts.
- **Haptics**: Feedback after logging and when rest ends while the app is active
- **Auto-Advance**: Immediately moves to the next unfinished set, including the next exercise; repeated taps on a previous set are ignored

### 🔔 Workout Reminders
- **Custom Schedule**: Set reminder times that work for you
- **Day Selection**: Choose which days to receive reminders
- **Smart Notifications**: AI-powered suggestions based on your workout history and recovery

### 🎯 User Experience
- **Large Buttons**: 44-point minimum touch targets, with one primary yellow action
- **Accessible Values**: VoiceOver labels, units, adjustable actions, and layouts that stack at large Dynamic Type sizes
- **Double Tap**: Log a set using Apple’s primary hand gesture on compatible watches running watchOS 11 or later
- **Clear Typography**: High-contrast, bold text for quick reading
- **Progress Indicators**: Visual feedback for sets, exercises, and workout completion
- **Seamless Navigation**: Intuitive flow between exercises and sets

## Project Structure

```
Apps/iOS/BetterFitWatchApp/
├── BetterFitWatchApp.swift      # App entry point and state management
├── ContentView.swift             # Main navigation container
├── WorkoutListView.swift         # Browse and start workouts
├── ActiveWorkoutView.swift       # Glanceable current set and pinned logging
├── WorkoutTrackingControls.swift # Accessible value editing and timer displays
├── WorkoutActionsView.swift      # Pause, undo, rest preferences, and discard
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

## Verifying Workout Tracking

Run `mise run test` for set progression, duplicate completion, nonnegative values, bodyweight sets, and pause-aware duration tests.

On a watchOS simulator or device:
1. Start Push Day. Verify reps, weight, and Log Set appear together on the 40 mm screen at the default text size.
2. Tap a value and turn the Crown. Confirm the selected field has a visible focus border, and that Log Set is still reachable. Log directly without tapping Done. After advancing, the Crown must not keep editing the next set.
3. Long-press a value, or choose Edit Reps / Edit Weight in Actions. Test the +/- editor and Done; this touch-only alternative must remain available without requiring a long press.
4. Verify that rest appears beside the next set and you can edit or log while it counts down. In Actions, test Skip Rest, Auto Rest Off, and a different duration.
5. Use Actions → Undo Last Set; verify that the previous values return and its completion is removed.
6. Use Actions → Pause; verify that timing freezes, value editing is disabled, and the primary action becomes Resume.
7. Finish every set, undo the final one, log it again, and save. Discard a second workout through the confirmation dialog.
8. Verify VoiceOver reads exercise, set, values with units, and button actions; use the adjustable actions on reps and weight. Check Double Tap and haptic feedback on real supported hardware.

Run `mise run watch:test:ui` for automated Crown editing, one-tap logging, quick-action reachability, and large-text checks. The default destination is the 40 mm Apple Watch SE 3 simulator; set `WATCH_DESTINATION` to another Xcode destination when needed.

Debug builds support the `UI_TESTING_LARGE_TEXT` launch argument to force the largest accessibility text size. The simulator does not expose watchOS text-size changes through `simctl ui content_size`. Values stack and remain scrollable; the main action stays pinned. This override is excluded from Release builds.

## UI Design Principles

- The exercise name gets its own full-width row, with set count and an unbroken rest countdown below. Values show their units inline; elapsed time and less frequent operations live in Actions.
- Logging a planned set takes one tap. Rest never replaces the next-set screen or requires an extra tap before logging.
- Use native sheets, familiar SF Symbols, scalable system fonts, and monospaced digits.
- Yellow `#FFD60A` with black ink marks the primary action; other controls use neutral surfaces.
- Support large text and VoiceOver without relying on color or gestures alone. Button alternatives remain available for Crown editing and Double Tap.

The interaction choices are informed by [Strong’s focused set screen and Crown editing](https://help.strongapp.io/article/224-workout-on-apple-watch) and [Hevy’s automatic rest timer](https://www.hevyapp.com/features/workout-rest-timer/). BetterFit keeps rest alongside the next set, and pins logging independently of the scroll position.

## Integration with BetterFit Library

The watch app uses the core `BetterFit` library for:
- **Workout Management**: Starting and completing workouts
- **Smart Recommendations**: AI-powered workout suggestions
- **Notification Scheduling**: Smart reminder system
- **History Tracking**: Locally persisted completed workouts
- **Recovery Integration**: Body map and recovery tracking

## Future Enhancements

- [ ] Live heart rate tracking during workouts
- [ ] Apple Health integration for calories and activity rings
- [ ] Voice control for hands-free set tracking
- [x] Haptic feedback for set completions and foreground rest timers
- [ ] Complications for quick workout access
- [x] Standalone watch app (independent of iPhone)
- [ ] Sync workouts with iPhone
- [ ] Rep detection via motion sensors
- [ ] Social features: share workouts with friends

## Notes

- The watch app requires the BetterFit SwiftPM package (supports watchOS 10+)
- Project is managed via XcodeGen - edit `Apps/iOS/project.yml` for configuration changes
- Do not manually edit `BetterFit.xcodeproj` - regenerate with `mise run watch:gen`
