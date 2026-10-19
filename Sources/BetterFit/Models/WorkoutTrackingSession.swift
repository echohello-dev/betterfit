import Foundation

/// Manual set logging with one source of truth for progress and active duration.
public struct WorkoutTrackingSession {
    public private(set) var workout: Workout
    public private(set) var isPaused = false
    private var accumulatedDuration: TimeInterval = 0
    private var runningSince: Date
    private var lastLoggedPosition: (exercise: Int, set: Int)?
    private var restStartedAtDuration: TimeInterval?
    public private(set) var restID: UUID?
    public private(set) var restDuration: TimeInterval

    public init(workout: Workout, startedAt: Date = Date(), restDuration: TimeInterval = 60) {
        self.workout = workout
        self.workout.date = startedAt
        self.workout.duration = nil
        self.workout.isCompleted = false
        runningSince = startedAt
        self.restDuration = restDuration.isFinite ? max(0, restDuration) : 60
    }

    // MARK: - Progress

    public var currentExerciseIndex: Int? {
        workout.exercises.firstIndex { $0.sets.contains { !$0.isCompleted } }
    }

    public var currentSetIndex: Int? {
        guard let index = currentExerciseIndex else { return nil }
        return workout.exercises[index].sets.firstIndex { !$0.isCompleted }
    }

    public var currentSet: ExerciseSet? {
        guard let exercise = currentExerciseIndex, let set = currentSetIndex else { return nil }
        return workout.exercises[exercise].sets[set]
    }

    public var completedSetCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count }
    }

    public var totalSetCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }

    public var isFinished: Bool { currentSet == nil }

    public var canUndoLastSet: Bool { lastLoggedPosition != nil }

    // MARK: - Logging

    public mutating func adjustReps(by delta: Int) {
        guard !isPaused, let exercise = currentExerciseIndex, let set = currentSetIndex else { return }
        workout.exercises[exercise].sets[set].reps = max(0, workout.exercises[exercise].sets[set].reps + delta)
    }

    public mutating func adjustWeight(by delta: Double) {
        guard !isPaused, let exercise = currentExerciseIndex, let set = currentSetIndex,
            let weight = workout.exercises[exercise].sets[set].weight, delta.isFinite
        else { return }
        workout.exercises[exercise].sets[set].weight = max(0, weight + delta)
    }

    /// The displayed ID prevents a repeated tap on an old button from logging the next set.
    public mutating func completeSet(id: UUID, at date: Date = Date()) {
        guard !isPaused, let exercise = currentExerciseIndex, let set = currentSetIndex,
            workout.exercises[exercise].sets[set].id == id
        else { return }
        workout.exercises[exercise].sets[set].isCompleted = true
        workout.exercises[exercise].sets[set].timestamp = date
        lastLoggedPosition = (exercise, set)
        skipRest()
        if isFinished {
            pause(at: date)
        } else if restDuration > 0 {
            restStartedAtDuration = elapsedTime(at: date)
            restID = UUID()
        }
    }

    /// Reopens the last logged set with its edited values intact.
    public mutating func undoLastSet(at date: Date = Date()) {
        guard let position = lastLoggedPosition else { return }
        let wasFinished = isFinished
        workout.exercises[position.exercise].sets[position.set].isCompleted = false
        workout.exercises[position.exercise].sets[position.set].timestamp = nil
        lastLoggedPosition = nil
        skipRest()
        if wasFinished { resume(at: date) }
    }

    // MARK: - Rest

    /// Rest uses active workout time, so pausing also freezes the countdown.
    public func remainingRest(at date: Date = Date()) -> TimeInterval {
        guard let start = restStartedAtDuration else { return 0 }
        return max(0, restDuration - max(0, elapsedTime(at: date) - start))
    }

    public mutating func skipRest() {
        restStartedAtDuration = nil
        restID = nil
    }

    public mutating func setRestDuration(_ duration: TimeInterval) {
        guard duration.isFinite else { return }
        restDuration = max(0, duration)
        if restDuration == 0 { skipRest() }
    }

    // MARK: - Timing

    public func elapsedTime(at date: Date = Date()) -> TimeInterval {
        accumulatedDuration + (isPaused ? 0 : max(0, date.timeIntervalSince(runningSince)))
    }

    public mutating func pause(at date: Date = Date()) {
        guard !isPaused else { return }
        accumulatedDuration = elapsedTime(at: date)
        isPaused = true
    }

    public mutating func resume(at date: Date = Date()) {
        guard isPaused, !isFinished else { return }
        runningSince = date
        isPaused = false
    }

    public func completedWorkout() -> Workout? {
        guard isFinished, totalSetCount > 0 else { return nil }
        var result = workout
        result.isCompleted = true
        result.duration = accumulatedDuration
        return result
    }
}
