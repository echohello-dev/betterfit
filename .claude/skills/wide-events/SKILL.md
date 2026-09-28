---
name: wide-events
description: Implement wide event (canonical log line) telemetry for the BetterFit app. Use when adding logging, observability, or telemetry to track user actions, errors, or performance.
---

# BetterFit Wide Event Logging Skill

Use this skill when adding logging, observability, or telemetry to the BetterFit app.

## When to activate this skill

- User wants to add logging for debugging
- User wants to track user actions or feature usage
- User needs to monitor performance or errors
- User asks about analytics, telemetry, or observability
- User wants to understand app behavior in production
- Adding new features that need monitoring

## Philosophy

**Emit one comprehensive log event per request/operation** with full context (user, business, infrastructure, performance) rather than scattering multiple log statements.

This enables effective debugging at scale — one query finds everything about an operation.

## Wide event structure

A wide event contains all dimensions of an operation in a single structured log line:

```swift
struct WorkoutCompletedEvent: WideEvent {
    // User context
    let userId: String
    let deviceId: String
    
    // Business context
    let workoutId: String
    let workoutName: String
    let exercisesCompleted: Int
    let totalSets: Int
    let totalVolume: Double
    let durationSeconds: Int
    
    // Infrastructure context
    let appVersion: String
    let osVersion: String
    let deviceModel: String
    
    // Performance context
    let startTime: Date
    let endTime: Date
    let networkRequests: Int
    let cacheHits: Int
}
```

## Implementation pattern

### 1. Define the event

```swift
// Sources/BetterFit/Services/Logging/WideEvent.swift
protocol WideEvent: Encodable {
    static var eventName: String { get }
    var timestamp: Date { get }
}

extension WideEvent {
    func emit() {
        let logger = Logger(subsystem: "dev.echohello.betterfit", category: Self.eventName)
        
        do {
            let data = try JSONEncoder().encode(self)
            if let json = String(data: data, encoding: .utf8) {
                logger.info("\(json, privacy: .public)")
            }
        } catch {
            logger.error("Failed to encode event: \(error.localizedDescription)")
        }
    }
}
```

### 2. Emit at operation boundaries

```swift
// In BetterFit facade
func completeWorkout(_ workout: Workout) {
    let startTime = Date()
    
    // ... business logic ...
    
    let event = WorkoutCompletedEvent(
        userId: currentUser.id,
        deviceId: deviceIdentifier,
        workoutId: workout.id,
        workoutName: workout.name,
        exercisesCompleted: workout.exercises.count,
        totalSets: workout.totalSets,
        totalVolume: workout.totalVolume,
        durationSeconds: Int(Date().timeIntervalSince(startTime)),
        appVersion: appVersion,
        osVersion: UIDevice.current.systemVersion,
        deviceModel: UIDevice.current.model,
        startTime: startTime,
        endTime: Date(),
        networkRequests: networkLayer.requestCount,
        cacheHits: cacheLayer.hitCount
    )
    
    event.emit()
}
```

### 3. What NOT to do

❌ **Don't scatter logs:**
```swift
// BAD: Multiple log statements for one operation
logger.info("Starting workout: \(workout.name)")
logger.info("User: \(userId)")
logger.info("Completed exercise: \(exercise.name)")
logger.info("Total sets: \(sets)")
logger.info("Workout complete")
```

✅ **Do emit one wide event:**
```swift
// GOOD: Single comprehensive event
WorkoutCompletedEvent(...).emit()
```

## Event categories

### User action events
Track what users do:
```swift
struct WorkoutStartedEvent: WideEvent { ... }
struct ExerciseCompletedEvent: WideEvent { ... }
struct PlanChangedEvent: WideEvent { ... }
struct SearchPerformedEvent: WideEvent { ... }
```

### Performance events
Track timing and resources:
```swift
struct ApiRequestEvent: WideEvent {
    let endpoint: String
    let durationMs: Int
    let statusCode: Int
    let bytesTransferred: Int
    let cacheHit: Bool
}

struct ScreenLoadEvent: WideEvent {
    let screenName: String
    let durationMs: Int
    let fromCache: Bool
}
```

### Error events
Track failures with context:
```swift
struct ErrorEvent: WideEvent {
    let errorType: String
    let errorMessage: String
    let stackTrace: String?
    let recoveryAction: String?
    let userImpact: String
}
```

## Privacy considerations

- Use `privacy: .private` for sensitive data (user IDs, health data)
- Use `privacy: .public` for non-sensitive structured data
- Consider local differential privacy for aggregate metrics
- Anonymize user identifiers in analytics pipelines

## Testing events

Verify events are emitted correctly:

```swift
func testWorkoutCompletionEmitsEvent() {
    // Given
    let expectation = expectation(description: "Event emitted")
    var capturedEvent: WorkoutCompletedEvent?
    
    EventLogger.shared.onEvent = { event in
        capturedEvent = event as? WorkoutCompletedEvent
        expectation.fulfill()
    }
    
    // When
    betterFit.completeWorkout(mockWorkout)
    
    // Then
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(capturedEvent?.workoutName, "Push Day")
    XCTAssertEqual(capturedEvent?.exercisesCompleted, 4)
}
```

## Quick checklist

- [ ] One event per operation (not scattered logs)
- [ ] Include user, business, infrastructure, and performance context
- [ ] Emit at operation boundaries (start/end or completion)
- [ ] Use structured encodable types
- [ ] Consider privacy for sensitive fields
- [ ] Test event emission in unit tests
- [ ] Don't over-log: focus on actionable events
