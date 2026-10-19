import Foundation
import Testing
@testable import BetterFit

struct WorkoutTrackingSessionTests {
    private let start = Date(timeIntervalSince1970: 1_000)

    private func makeSession() -> WorkoutTrackingSession {
        let exercise = Exercise(name: "Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest])
        let curl = Exercise(name: "Curl", equipmentRequired: .dumbbell, muscleGroups: [.biceps])
        return WorkoutTrackingSession(
            workout: Workout(name: "Test", exercises: [
                WorkoutExercise(exercise: exercise, sets: [
                    ExerciseSet(reps: 8, weight: 60), ExerciseSet(reps: 6, weight: 65)
                ]),
                WorkoutExercise(exercise: curl, sets: [ExerciseSet(reps: 12, weight: nil)])
            ], date: .distantPast), startedAt: start)
    }

    @Test func logsValuesAndAdvancesAcrossExercises() throws {
        var session = makeSession()
        session.adjustReps(by: 1)
        session.adjustWeight(by: 5)
        let firstID = try #require(session.currentSet?.id)
        let loggedAt = start.addingTimeInterval(10)
        session.completeSet(id: firstID, at: loggedAt)
        let first = session.workout.exercises[0].sets[0]
        #expect(first.reps == 9)
        #expect(first.weight == 65)
        #expect(first.isCompleted)
        #expect(first.timestamp == loggedAt)
        #expect(session.currentSetIndex == 1)
        #expect(session.currentSet?.reps == 6)

        // A queued tap on the previous button must not complete the new set.
        session.completeSet(id: firstID, at: loggedAt)
        #expect(session.completedSetCount == 1)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(20))
        #expect(session.currentExerciseIndex == 1)
        #expect(session.currentSetIndex == 0)
        #expect(session.currentSet?.reps == 12)
        #expect(session.currentSet?.weight == nil)
        session.adjustWeight(by: 5)
        #expect(session.currentSet?.weight == nil)
        #expect(session.completedWorkout() == nil)

        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(30))
        #expect(session.isFinished)
        #expect(session.completedSetCount == 3)
        let workout = try #require(session.completedWorkout())
        #expect(workout.isCompleted)
        #expect(workout.date == start)
        #expect(workout.duration == 30)
        #expect(workout.exercises.allSatisfy { $0.sets.allSatisfy(\.isCompleted) })
        #expect(session.elapsedTime(at: start.addingTimeInterval(300)) == 30)
    }

    @Test func clampsValuesAndIgnoresLoggingWhilePaused() throws {
        var session = makeSession()
        session.adjustReps(by: -100)
        session.adjustWeight(by: -100)
        #expect(session.currentSet?.reps == 0)
        #expect(session.currentSet?.weight == 0)
        let id = try #require(session.currentSet?.id)
        session.pause(at: start.addingTimeInterval(10))
        session.adjustReps(by: 1)
        session.adjustWeight(by: 5)
        session.completeSet(id: id)
        #expect(session.currentSet?.reps == 0)
        #expect(session.currentSet?.weight == 0)
        #expect(session.completedSetCount == 0)
        session.resume(at: start.addingTimeInterval(20))
        session.completeSet(id: id, at: start.addingTimeInterval(25))
        #expect(session.completedSetCount == 1)
    }

    @Test func durationExcludesMultiplePausesAndStopsAfterLastSet() throws {
        var session = makeSession()
        session.pause(at: start.addingTimeInterval(10))
        session.pause(at: start.addingTimeInterval(15))
        #expect(session.elapsedTime(at: start.addingTimeInterval(25)) == 10)
        session.resume(at: start.addingTimeInterval(30))
        session.resume(at: start.addingTimeInterval(35))
        session.pause(at: start.addingTimeInterval(40))
        session.resume(at: start.addingTimeInterval(50))
        while let set = session.currentSet {
            session.completeSet(id: set.id, at: start.addingTimeInterval(60))
        }
        #expect(session.completedWorkout()?.duration == 30)
        session.resume(at: start.addingTimeInterval(100))
        #expect(session.elapsedTime(at: start.addingTimeInterval(200)) == 30)
    }

    @Test func skipsEmptyExercisesAndCompletedSets() throws {
        let template = makeSession().workout
        var workout = template
        workout.exercises[0].sets = []
        workout.exercises[1].sets.insert(ExerciseSet(reps: 1, isCompleted: true), at: 0)
        var session = WorkoutTrackingSession(workout: workout, startedAt: start)
        #expect(session.currentExerciseIndex == 1)
        #expect(session.currentSetIndex == 1)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(5))
        #expect(session.isFinished)
        #expect(session.completedWorkout()?.duration == 5)
    }

    @Test func emptyWorkoutCannotBeSaved() {
        var session = WorkoutTrackingSession(workout: Workout(name: "Empty"), startedAt: start)
        #expect(session.isFinished)
        #expect(session.completedWorkout() == nil)
        session.adjustReps(by: 1)
        session.adjustWeight(by: 5)
        session.completeSet(id: UUID())
        #expect(session.totalSetCount == 0)
    }

    @Test func restStartsAutomaticallyAndFreezesWhilePaused() throws {
        var session = makeSession()
        #expect(session.remainingRest(at: start) == 0)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(10))
        #expect(session.restID != nil)
        #expect(session.remainingRest(at: start.addingTimeInterval(20)) == 50)
        session.pause(at: start.addingTimeInterval(30))
        #expect(session.remainingRest(at: start.addingTimeInterval(100)) == 40)
        session.resume(at: start.addingTimeInterval(110))
        #expect(session.remainingRest(at: start.addingTimeInterval(120)) == 30)
        #expect(session.remainingRest(at: start.addingTimeInterval(200)) == 0)
    }

    @Test func loggingNextSetDoesNotRequireSkippingRest() throws {
        var session = makeSession()
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(10))
        let firstRestID = session.restID
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(15))
        #expect(session.completedSetCount == 2)
        #expect(session.restID != firstRestID)
        #expect(session.remainingRest(at: start.addingTimeInterval(15)) == 60)
        session.skipRest()
        #expect(session.restID == nil)
        #expect(session.remainingRest(at: start.addingTimeInterval(15)) == 0)
        #expect(session.completedSetCount == 2)
    }

    @Test func restCanBeConfiguredOrDisabledAndNeverStartsAfterFinalSet() throws {
        var session = makeSession()
        session.setRestDuration(90)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(10))
        #expect(session.remainingRest(at: start.addingTimeInterval(20)) == 80)
        session.setRestDuration(0)
        #expect(session.restID == nil)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(20))
        #expect(session.restID == nil)
        session.setRestDuration(60)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(30))
        #expect(session.isFinished)
        #expect(session.restID == nil)
    }

    @Test func undoReopensEditedSetAndCancelsRest() throws {
        var session = makeSession()
        #expect(!session.canUndoLastSet)
        session.adjustReps(by: 2)
        let firstID = try #require(session.currentSet?.id)
        session.completeSet(id: firstID, at: start.addingTimeInterval(10))
        #expect(session.canUndoLastSet)
        session.undoLastSet(at: start.addingTimeInterval(20))
        #expect(session.currentSet?.id == firstID)
        #expect(session.currentSet?.reps == 10)
        #expect(session.currentSet?.timestamp == nil)
        #expect(session.completedSetCount == 0)
        #expect(!session.canUndoLastSet)
        #expect(session.restID == nil)
    }

    @Test func undoFinalSetResumesTimingWithoutCountingTimeOnSummary() throws {
        var session = makeSession()
        while let set = session.currentSet {
            session.completeSet(id: set.id, at: start.addingTimeInterval(30))
        }
        #expect(session.isPaused)
        session.undoLastSet(at: start.addingTimeInterval(100))
        #expect(!session.isPaused)
        #expect(!session.isFinished)
        #expect(session.completedWorkout() == nil)
        session.completeSet(id: try #require(session.currentSet?.id), at: start.addingTimeInterval(110))
        #expect(session.completedWorkout()?.duration == 40)
        #expect(session.restID == nil)
    }
}
