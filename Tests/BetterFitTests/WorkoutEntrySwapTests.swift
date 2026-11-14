import Foundation
import Testing
@testable import BetterFit

struct WorkoutEntrySwapTests {
    private let press = Exercise(
        name: "Barbell Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest, .triceps])
    private let dumbbellPress = Exercise(
        name: "Dumbbell Bench Press", equipmentRequired: .dumbbell,
        muscleGroups: [.chest, .triceps], imageURL: "dumbbell-press.png")

    // MARK: - Entry Selection

    @Test func replacesOnlySelectedRepeatedEntryAndPreservesWorkoutData() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let warmUp = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 12)], notes: "Warm up")
        let working = WorkoutExercise(exercise: press, sets: [
            ExerciseSet(reps: 8, weight: 20, isCompleted: true, timestamp: timestamp, autoTracked: true),
            ExerciseSet(reps: 6, weight: 22)
        ], notes: "Controlled tempo")
        var workout = Workout(
            name: "Push", exercises: [warmUp, working], date: timestamp,
            duration: 600, isCompleted: true, templateId: UUID())
        let snapshot = workout
        let replacement = try #require(manager.findAlternatives(for: working.exercise, from: [dumbbellPress]).first)

        #expect(manager.applySwap(workout: &workout, workoutExerciseId: working.id, newExercise: replacement))

        var expected = snapshot
        expected.exercises[1] = WorkoutExercise(
            id: working.id, exercise: dumbbellPress, sets: working.sets, notes: working.notes)
        #expect(workout == expected)
        #expect(snapshot.exercises == [warmUp, working])
    }

    @Test func selectsEntryByIdentityAfterReordering() {
        let manager = EquipmentSwapManager()
        let first = WorkoutExercise(exercise: press)
        let second = WorkoutExercise(exercise: press)
        var workout = Workout(name: "Push", exercises: [first, second])
        workout.exercises.reverse()

        #expect(manager.applySwap(workout: &workout, workoutExerciseId: first.id, newExercise: dumbbellPress))

        #expect(workout.exercises[0] == second)
        #expect(workout.exercises[1].id == first.id)
        #expect(workout.exercises[1].exercise == dumbbellPress)
    }

    @Test func keepsEntryAddressableAfterAReplacement() {
        let manager = EquipmentSwapManager()
        let entry = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 8)], notes: "Working sets")
        var workout = Workout(name: "Push", exercises: [entry])
        let snapshot = workout

        #expect(manager.applySwap(workout: &workout, workoutExerciseId: entry.id, newExercise: dumbbellPress))
        #expect(manager.applySwap(workout: &workout, workoutExerciseId: entry.id, newExercise: press))

        #expect(workout == snapshot)
    }

    // MARK: - Missing Entries and Compatibility

    @Test(arguments: [false, true])
    func leavesWorkoutUnchangedWhenEntryIsMissing(empty: Bool) {
        let manager = EquipmentSwapManager()
        var workout = Workout(name: "Push", exercises: empty ? [] : [WorkoutExercise(exercise: press)])
        let snapshot = workout

        #expect(!manager.applySwap(workout: &workout, workoutExerciseId: UUID(), newExercise: dumbbellPress))

        #expect(workout == snapshot)
    }

    @Test func doesNotUseExerciseDefinitionIdAsWorkoutEntryId() {
        let manager = EquipmentSwapManager()
        var workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])
        let snapshot = workout

        #expect(!manager.applySwap(workout: &workout, workoutExerciseId: press.id, newExercise: dumbbellPress))

        #expect(workout == snapshot)
    }

    @Test func legacyOverloadStillReplacesFirstMatchingExercise() {
        let manager = EquipmentSwapManager()
        let first = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 12)], notes: "Warm up")
        let second = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 6)], notes: "Working sets")
        var workout = Workout(name: "Push", exercises: [first, second])
        let snapshot = workout

        #expect(manager.applySwap(workout: &workout, originalExerciseId: press.id, newExercise: dumbbellPress))

        var expected = snapshot
        expected.exercises[0] = WorkoutExercise(
            id: first.id, exercise: dumbbellPress, sets: first.sets, notes: first.notes)
        #expect(workout == expected)
    }

    @Test func legacyOverloadLeavesWorkoutUnchangedWhenExerciseIsMissing() {
        let manager = EquipmentSwapManager()
        var workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])
        let snapshot = workout

        #expect(!manager.applySwap(workout: &workout, originalExerciseId: UUID(), newExercise: dumbbellPress))

        #expect(workout == snapshot)
    }
}
