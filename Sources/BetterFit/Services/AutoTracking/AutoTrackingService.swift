import Foundation

/// Auto-tracking service for Watch sensor data
public class AutoTrackingService {
    private var isTracking: Bool = false
    private var currentWorkout: Workout?
    private var currentExerciseIndex: Int = 0
    private var detectedReps: Int = 0

    public init() {}

    /// Start tracking a workout
    public func startTracking(workout: Workout) {
        self.currentWorkout = workout
        self.isTracking = true
        self.currentExerciseIndex = 0
        self.detectedReps = 0
    }

    /// Stop tracking
    public func stopTracking() {
        self.isTracking = false
        self.currentWorkout = nil
        self.currentExerciseIndex = 0
        self.detectedReps = 0
    }

    /// Process motion data from Watch sensors
    public func processMotionData(_ data: MotionData) -> TrackingEvent? {
        guard isTracking else { return nil }

        // Detect rep based on motion patterns
        if data.isRepetitionDetected() {
            detectedReps += 1
            return .repDetected(count: detectedReps)
        }

        // Detect rest period
        if data.isRestPeriod() {
            let event = TrackingEvent.setCompleted(reps: detectedReps)
            detectedReps = 0
            return event
        }

        return nil
    }

    /// Complete current set with auto-tracked data
    public func completeCurrentSet() -> ExerciseSet? {
        guard let workout = currentWorkout,
            currentExerciseIndex < workout.exercises.count
        else {
            return nil
        }

        let set = ExerciseSet(
            reps: detectedReps,
            isCompleted: true,
            timestamp: Date(),
            autoTracked: true
        )

        detectedReps = 0
        return set
    }

    /// Move to next exercise
    public func nextExercise() {
        currentExerciseIndex += 1
        detectedReps = 0
    }

    /// Get current tracking status
    public func getTrackingStatus() -> TrackingStatus {
        return TrackingStatus(
            isTracking: isTracking,
            currentExercise: currentExerciseIndex,
            detectedReps: detectedReps
        )
    }

    /// Get the currently tracked workout (if any)
    public func getCurrentWorkout() -> Workout? {
        return currentWorkout
    }
}

/// Motion data from Watch sensors
public struct MotionData {
    public var acceleration: [Double]
    public var rotation: [Double]
    public var heartRate: Double?
    public var timestamp: Date

    public init(
        acceleration: [Double],
        rotation: [Double],
        heartRate: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.acceleration = acceleration
        self.rotation = rotation
        self.heartRate = heartRate
        self.timestamp = timestamp
    }

    /// Detect if motion data indicates a repetition
    public func isRepetitionDetected() -> Bool {
        // Simplified detection: check for significant acceleration change
        guard acceleration.count >= 3 else { return false }
        let magnitude = sqrt(
            acceleration[0] * acceleration[0] + acceleration[1] * acceleration[1] + acceleration[2]
                * acceleration[2]
        )
        return magnitude > 1.5  // Threshold for rep detection
    }

    /// Detect if motion data indicates rest period
    public func isRestPeriod() -> Bool {
        // Simplified detection: check for minimal movement
        guard acceleration.count >= 3 else { return false }
        let magnitude = sqrt(
            acceleration[0] * acceleration[0] + acceleration[1] * acceleration[1] + acceleration[2]
                * acceleration[2]
        )
        return magnitude < 0.2  // Threshold for rest
    }
}

/// Tracking events
public enum TrackingEvent {
    case repDetected(count: Int)
    case setCompleted(reps: Int)
    case exerciseCompleted
}

/// Current tracking status
public struct TrackingStatus {
    public var isTracking: Bool
    public var currentExercise: Int
    public var detectedReps: Int

    public init(isTracking: Bool, currentExercise: Int, detectedReps: Int) {
        self.isTracking = isTracking
        self.currentExercise = currentExercise
        self.detectedReps = detectedReps
    }
}
