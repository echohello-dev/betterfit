# BetterFit API Reference

Looking to run the iOS app on Simulator? Start here: [README.md](README.md).

## Core Class

### `BetterFit`

The main entry point for the BetterFit library.

```swift
public class BetterFit
```

#### Properties

- `planManager: PlanManager` - Manages training plans
- `templateManager: TemplateManager` - Manages workout templates
- `equipmentSwapManager: EquipmentSwapManager` - Handles equipment swaps
- `bodyMapManager: BodyMapManager` - Tracks recovery status
- `socialManager: SocialManager` - Manages social features
- `notificationManager: SmartNotificationManager` - Handles notifications
- `autoTrackingService: AutoTrackingService` - Processes Watch sensor data
- `aiAdaptationService: AIAdaptationService` - AI-powered plan adaptation
- `imageService: EquipmentImageService` - Equipment image management

#### Methods

##### `startWorkout(_:)`
```swift
public func startWorkout(_ workout: Workout)
```
Starts a workout and enables auto-tracking.

##### `completeWorkout(_:)`
```swift
public func completeWorkout(_ workout: Workout)
```
Completes a workout, updating history, recovery, streaks, and AI analysis.

##### `getWorkoutHistory() -> [Workout]`
```swift
public func getWorkoutHistory() -> [Workout]
```
Returns all completed workouts.

##### `getRecommendedWorkout() -> Workout?`
```swift
public func getRecommendedWorkout() -> Workout?
```
Gets a recommended workout based on current plan and recovery status.

##### `processMotionData(_:) -> TrackingEvent?`
```swift
public func processMotionData(_ data: MotionData) -> TrackingEvent?
```
Processes Apple Watch motion data for auto-tracking.

##### `getTrackingStatus() -> TrackingStatus`
```swift
public func getTrackingStatus() -> TrackingStatus
```
Returns the current auto-tracking status.

## Models

### Apple Health exports

`HealthExportParser.parseExport(data:)` and `parseExport(xml:)` return a
`HealthExport` containing `workouts`, `records`, and `activitySummaries`.
The parser uses Foundation and does not require HealthKit or UI frameworks.

Each `HealthActivitySummary` preserves the exported `dateComponents` day
string (`yyyy-MM-dd`), active energy and goal with their original unit,
exercise time and goal in minutes, and stand hours and goal. Missing or
invalid numeric attributes are nil; measured zero remains zero.
`activeEnergyKilocalories` and `activeEnergyGoalKilocalories` convert kcal,
kJ, and J to kilocalories, returning nil for missing or unsupported units.

Activity summaries remain separate from `dailySummaries(calendar:)`, which
aggregates records. Adding the two energy totals would count the same
activity twice. Older encoded exports without `activitySummaries` decode
with an empty collection.

### `Exercise`

Represents a single exercise.

```swift
public struct Exercise: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `name: String`
- `equipmentRequired: Equipment`
- `muscleGroups: [MuscleGroup]`
- `imageURL: String?`

### `Equipment`

Equipment types for exercises.

```swift
public enum Equipment: String, Codable, CaseIterable
```

#### Cases
- `barbell`, `dumbbell`, `kettlebell`, `machine`, `cable`, `bodyweight`, `bands`, `other`

#### Methods
- `alternatives() -> [Equipment]` - Returns alternative equipment options

### `MuscleGroup`

Muscle groups targeted by exercises.

```swift
public enum MuscleGroup: String, Codable, CaseIterable
```

#### Cases
- `chest`, `back`, `shoulders`, `biceps`, `triceps`, `forearms`
- `abs`, `obliques`, `quads`, `hamstrings`, `glutes`, `calves`, `traps`, `lats`

#### Properties
- `bodyMapRegion: String` - Body map region for recovery tracking

### `ExerciseSet`

Represents a single set in an exercise.

```swift
public struct ExerciseSet: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `reps: Int`
- `weight: Double?`
- `isCompleted: Bool`
- `timestamp: Date?`
- `autoTracked: Bool`

### `Workout`

Represents a workout session.

```swift
public struct Workout: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `name: String`
- `exercises: [WorkoutExercise]`
- `date: Date`
- `duration: TimeInterval?`
- `isCompleted: Bool`
- `templateId: UUID?`

### `WorkoutTemplate`

Reusable workout template.

```swift
public struct WorkoutTemplate: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `name: String`
- `description: String?`
- `exercises: [TemplateExercise]`
- `tags: [String]`
- `createdDate: Date`
- `lastUsedDate: Date?`

#### Methods
- `createWorkout() -> Workout` - Converts template to a workout

### `TrainingPlan`

Training plan for structured programming.

```swift
public struct TrainingPlan: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `name: String`
- `description: String?`
- `weeks: [TrainingWeek]`
- `currentWeek: Int`
- `goal: TrainingGoal`
- `createdDate: Date`
- `aiAdapted: Bool`

#### Methods
- `getCurrentWeek() -> TrainingWeek?`
- `advanceWeek()`

### `TrainingGoal`

Training goal types.

```swift
public enum TrainingGoal: String, Codable, CaseIterable
```

#### Cases
- `strength`, `hypertrophy`, `endurance`, `powerlifting`, `generalFitness`, `weightLoss`

#### Properties
- `repRange: ClosedRange<Int>` - Recommended rep range
- `restTime: TimeInterval` - Recommended rest time

### `BodyMapRecovery`

Body map for tracking recovery.

```swift
public struct BodyMapRecovery: Codable, Equatable
```

#### Properties
- `regions: [BodyRegion: RecoveryStatus]`
- `lastUpdated: Date`

#### Methods
- `recordWorkout(_:)` - Update each targeted body region once per recorded workout. Multiple muscles or exercises in the same region share one fatigue transition; separate recorded workouts can increase fatigue further.
- `updateRecovery()` - Update based on time elapsed

### `RecoveryStatus`

Recovery status for muscle groups.

```swift
public enum RecoveryStatus: String, Codable, Equatable
```

#### Cases
- `recovered`, `slightlyFatigued`, `fatigued`, `sore`

#### Properties
- `recommendedRestHours: Double`

### `UserProfile`

User profile for social features.

```swift
public struct UserProfile: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `username: String`
- `currentStreak: Int`
- `longestStreak: Int`
- `totalWorkouts: Int`
- `activeChallenges: [UUID]`

### `Challenge`

Workout challenge.

```swift
public struct Challenge: Identifiable, Codable, Equatable
```

#### Properties
- `id: UUID`
- `name: String`
- `description: String`
- `goal: ChallengeGoal`
- `startDate: Date`
- `endDate: Date`
- `participants: [UUID]`
- `progress: [UUID: Double]`

### `ChallengeGoal`

Challenge goal types.

```swift
public enum ChallengeGoal: Codable, Equatable
```

#### Cases
- `workoutCount(target: Int)`
- `totalVolume(target: Double)`
- `consecutiveDays(target: Int)`
- `specificExercise(exerciseId: UUID, target: Int)`

## Managers

### `PlanManager`

Manages training plans.

```swift
public class PlanManager
```

#### Methods
- `getActivePlan() -> TrainingPlan?`
- `setActivePlan(_:)`
- `addPlan(_:)`
- `updatePlan(_:)`
- `removePlan(_:)`
- `getAllPlans() -> [TrainingPlan]`

### `TemplateManager`

Manages workout templates.

```swift
public class TemplateManager
```

#### Methods
- `getAllTemplates() -> [WorkoutTemplate]`
- `getTemplate(id:) -> WorkoutTemplate?`
- `addTemplate(_:)`
- `updateTemplate(_:)`
- `deleteTemplate(id:)`
- `searchByTag(_:) -> [WorkoutTemplate]`
- `searchByName(_:) -> [WorkoutTemplate]`
- `getRecentTemplates(limit:) -> [WorkoutTemplate]`
- `createWorkout(from:) -> Workout?`
- `createTemplate(from:name:tags:) -> WorkoutTemplate`

### `EquipmentSwapManager`

Manages equipment swaps.

```swift
public class EquipmentSwapManager
```

#### Methods
- `setAvailableEquipment(_:)`
- `isAvailable(_:) -> Bool`
- `findAlternatives(for:) -> [Exercise]`
- `suggestSwaps(for:) -> [(original: Exercise, alternatives: [Exercise])]`
- `applySwap(workout:originalExerciseId:newExercise:) -> Bool`

### `BodyMapManager`

Manages body map recovery.

```swift
public class BodyMapManager
```

#### Methods
- `getRecoveryMap() -> BodyMapRecovery`
- `recordWorkout(_:)`
- `getRecoveryStatus(for:) -> RecoveryStatus`
- `isReadyForTraining(region:) -> Bool`
- `getRecommendedExercises(available:avoidSoreRegions:) -> [Exercise]`
- `getOverallRecoveryPercentage() -> Double`
- `reset()`

### `SocialManager`

Manages social features.

```swift
public class SocialManager
```

#### Methods
- `recordWorkout(date:)`
- `getCurrentStreak() -> Int`
- `getLongestStreak() -> Int`
- `getAllChallenges() -> [Challenge]`
- `getActiveChallenges() -> [Challenge]`
- `joinChallenge(_:) -> Bool`
- `leaveChallenge(_:) -> Bool`
- `createChallenge(_:)`
- `updateChallengeProgress(challengeId:userId:progress:) -> Bool`
- `getChallengeLeaderboard(challengeId:) -> [(userId: UUID, progress: Double)]`
- `checkChallengeCompletion(challengeId:userId:) -> Bool`
- `getUserProfile() -> UserProfile`
- `updateUserProfile(_:)`

### `SmartNotificationManager`

Manages smart notifications.

```swift
public class SmartNotificationManager
```

#### Methods
- `scheduleNotifications(userProfile:workoutHistory:activePlan:)`
- `getScheduledNotifications() -> [SmartNotification]`
- `cancelNotification(id:)`
- `cancelAllNotifications()`

## Services

### Health export sleep summaries

`HealthExportParser.parseExport(xml:)` reads Apple Health export XML without
requiring HealthKit. Call `dailySummaries(calendar:)` on the result to aggregate
records by their start date in the supplied calendar.

`DailyHealthSummary.sleepDuration` reports seconds asleep for legacy asleep,
unspecified, core, deep and REM categories, including their numeric HealthKit
values. Overlapping asleep intervals count once, including duplicates from
different sources. Awake, in-bed, unknown categories and incomplete or
non-positive intervals are excluded. A day without valid asleep intervals has
`nil` sleep duration, which remains an empty field in CSV and is omitted in JSON.
Apple documents the sleep categories and overlapping samples in
[HKCategoryValueSleepAnalysis](https://developer.apple.com/documentation/healthkit/hkcategoryvaluesleepanalysis).

Intervals crossing midnight remain entirely on their start day. The summary does
not prioritise sources or subtract awake samples that conflict with asleep
samples. CSV and JSON exports use the same corrected duration.

### `AutoTrackingService`

Auto-tracking service for Watch sensors.

```swift
public class AutoTrackingService
```

#### Methods
- `startTracking(workout:)`
- `stopTracking()`
- `processMotionData(_:) -> TrackingEvent?`
- `completeCurrentSet() -> ExerciseSet?`
- `nextExercise()`
- `getTrackingStatus() -> TrackingStatus`

### `MotionData`

Motion data from Watch sensors.

```swift
public struct MotionData
```

#### Properties
- `acceleration: [Double]`
- `rotation: [Double]`
- `heartRate: Double?`
- `timestamp: Date`

#### Initializer

```swift
public init(
	acceleration: [Double],
	rotation: [Double],
	heartRate: Double? = nil,
	timestamp: Date = Date()
)
```

#### Methods
- `isRepetitionDetected() -> Bool`
- `isRestPeriod() -> Bool`

### `TrackingEvent`

Tracking events from auto-tracking.

```swift
public enum TrackingEvent
```

#### Cases
- `repDetected(count: Int)`
- `setCompleted(reps: Int)`
- `exerciseCompleted`

### `TrackingStatus`

Current auto-tracking status.

```swift
public struct TrackingStatus
```

#### Properties
- `isTracking: Bool`
- `currentExercise: Int`
- `detectedReps: Int`

### `AIAdaptationService`

AI service for adaptive training.

```swift
public class AIAdaptationService
```

#### Methods
- `analyzePerformance(workouts:currentPlan:) -> [Adaptation]`
- `applyAdaptations(_:to:)`

### `Adaptation`

Training plan adaptation suggestions.

```swift
public enum Adaptation: Equatable
```

#### Cases
- `reduceVolume(percentage: Int)`
- `increaseVolume(percentage: Int)`
- `adjustIntensity(change: Int)`
- `deloadWeek`

### `EquipmentImageService`

Service for equipment images.

```swift
public class EquipmentImageService
```

#### Methods
- `getImage(for: Equipment) -> EquipmentImage?`
- `getImage(for: Exercise) -> EquipmentImage?`
- `cacheImage(_:for:)`
- `getAllImages() -> [EquipmentImage]`
- `loadCustomImage(url:for:) async throws -> EquipmentImage`
- `generateAIImage(for:style:) async throws -> EquipmentImage`

### `EquipmentImage`

Equipment image model.

```swift
public struct EquipmentImage: Identifiable, Equatable
```

#### Properties
- `id: UUID`
- `equipmentType: Equipment`
- `url: String`
- `is3D: Bool`
- `isAIGenerated: Bool`

### `ImageStyle`

Image generation styles.

```swift
public enum ImageStyle: String, CaseIterable
```

#### Cases
- `realistic3D`, `cartoon`, `schematic`, `photographic`

### `HealthExportParser`

Parses an Apple Health export (`export.xml`). Foundation only, so it runs off device and in tests.

```swift
public enum HealthExportParser
```

#### Methods
- `parseWorkouts(data:)` / `parseWorkouts(xml:)` - workouts with child statistics
- `parseRecords(data:)` / `parseRecords(xml:)` - top-level records (steps, heart rate, energy, distance, body mass, sleep)
- `parseExport(data:)` / `parseExport(xml:)` - both of the above as one `HealthExport`

Throws `HealthExportParser.ParseError.malformedXML` on malformed XML.

### `ParsedWorkout` and `WorkoutStatistics`

A workout from the export, with one `WorkoutStatistics` per quantity type nested under it. `ParsedWorkout` exposes per-workout summaries: `activeEnergyKilocalories`, `basalEnergyKilocalories`, `distanceMetres`, `averageHeartRate`, `minimumHeartRate`, `maximumHeartRate`, and `stepCount`. Statistics win over the totals written on the workout element, and unknown statistic types are kept as `.other(type)`.

### `HealthRecord` and `HealthExport`

A top-level record from the export. Quantity records carry a numeric `value`. Category records, such as sleep analysis, carry `categoryValue` as a string instead. Normalised helpers: `valueKilocalories`, `valueMetres`, `valueKilograms`, and `duration` from the start and end dates. Unknown record types are kept as `.other(type)`.

`HealthExport` holds `workouts` and `records` together, with `records(of:)` to filter records by kind.

### Weekly training summary export

`HealthExport.weeklyTrainingSummaries(calendar:)` groups workouts by their start
date into calendar weeks and returns summaries in date order. Workouts without
a start date are skipped. Pass an explicit calendar to control the time zone
and first day of the week.

`[WeeklyTrainingSummary]` supports `csvString()`, `jsonData()`, `writeCSV(to:)`
and `writeJSON(to:)`. All four methods throw on encoding or file errors. Exports
preserve array order and use ISO8601 dates. File writes atomically create or
replace the destination, whose parent directory must already exist.

CSV columns are `week_start`, `workout_count`, `duration_seconds`,
`active_energy_kcal`, `distance_metres`, `average_heart_rate`,
`maximum_heart_rate` and `activity_counts`. Heart rates are in beats per minute;
the average is the unweighted mean of per-workout averages. Missing metrics
are empty CSV fields and omitted JSON properties; measured zero stays zero.
Activity counts use a JSON object with sorted keys inside a quoted CSV field,
so activity names containing commas or quotes are preserved. Empty CSV exports
contain only the header and a newline; empty JSON exports contain an empty array.

```swift
let export = try HealthExportParser.parseExport(data: xmlData)
let weeks = export.weeklyTrainingSummaries(calendar: calendar)
try weeks.writeCSV(to: csvURL)
try weeks.writeJSON(to: jsonURL)

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let restored = try decoder.decode([WeeklyTrainingSummary].self, from: weeks.jsonData())
```
