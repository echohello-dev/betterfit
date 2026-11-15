import Foundation
import Testing
@testable import BetterFit

struct WorkoutSwapSuggestionTests {
    private let press = Exercise(
        name: "Barbell Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest, .triceps])
    private let dumbbellPress = Exercise(
        name: "Dumbbell Bench Press", equipmentRequired: .dumbbell,
        muscleGroups: [.chest, .triceps], imageURL: "dumbbell-press.png")

    // MARK: - Suggestions

    @Test func identifiesRepeatedEntriesWithoutChangingWorkout() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let warmUp = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 12)], notes: "Warm up")
        let working = WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 6)], notes: "Working sets")
        let workout = Workout(name: "Push", exercises: [warmUp, working])
        let snapshot = workout

        let suggestions = manager.suggestEntrySwaps(for: workout, from: [dumbbellPress])

        #expect(suggestions == [warmUp, working].map { entry in
            WorkoutSwapSuggestion(workoutExerciseId: entry.id, original: press, alternatives: [dumbbellPress])
        })
        #expect(workout == snapshot)
    }

    @Test func omitsIneligibleEntriesAndPreservesWorkoutAndCatalogueOrder() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell, .machine])
        let machinePress = Exercise(
            name: "Machine Press", equipmentRequired: .machine,
            muscleGroups: [.triceps, .chest], imageURL: "machine-press.png")
        let row = Exercise(name: "Barbell Row", equipmentRequired: .barbell, muscleGroups: [.back])
        let dumbbellRow = Exercise(name: "Dumbbell Row", equipmentRequired: .dumbbell, muscleGroups: [.back])
        let squat = Exercise(name: "Barbell Squat", equipmentRequired: .barbell, muscleGroups: [.quads])
        let entries = [row, dumbbellPress, squat, press].map { WorkoutExercise(exercise: $0) }
        let workout = Workout(name: "Full Body", exercises: entries)
        let catalogue = [machinePress, dumbbellRow, dumbbellPress, machinePress]

        let suggestions = manager.suggestEntrySwaps(for: workout, from: catalogue)

        #expect(suggestions.map(\.workoutExerciseId) == [entries[0].id, entries[3].id])
        #expect(suggestions.map(\.original) == [row, press])
        #expect(suggestions.map(\.alternatives) == [[dumbbellRow], [machinePress, dumbbellPress]])
    }

    @Test func returnsNoEntrySuggestionsForEmptyInputs() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])

        #expect(manager.suggestEntrySwaps(for: Workout(name: "Empty"), from: [dumbbellPress]).isEmpty)
        #expect(manager.suggestEntrySwaps(for: workout, from: []).isEmpty)
    }

    @Test func reflectsUpdatedEquipmentAvailability() {
        let manager = EquipmentSwapManager(availableEquipment: [.barbell, .dumbbell])
        let entry = WorkoutExercise(exercise: press)
        let workout = Workout(name: "Push", exercises: [entry])

        #expect(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).isEmpty)
        manager.setAvailableEquipment([.dumbbell])
        #expect(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).map(\.workoutExerciseId) == [entry.id])
        manager.setAvailableEquipment([])
        #expect(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).isEmpty)
    }

    // MARK: - Application and Compatibility

    @Test func appliesSecondRepeatedEntrySuggestionAndPreservesWorkoutData() throws {
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
        let suggestion = try #require(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).last)
        let selected = try #require(suggestion.alternatives.first)

        #expect(manager.applySwap(
            workout: &workout, workoutExerciseId: suggestion.workoutExerciseId, newExercise: selected))

        var expected = snapshot
        expected.exercises[1].exercise = dumbbellPress
        #expect(workout == expected)
    }

    @Test func suggestionStillTargetsSameEntryAfterReordering() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let first = WorkoutExercise(exercise: press)
        let second = WorkoutExercise(exercise: press)
        var workout = Workout(name: "Push", exercises: [first, second])
        let suggestion = try #require(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).last)
        let selected = try #require(suggestion.alternatives.first)
        workout.exercises.reverse()

        #expect(manager.applySwap(
            workout: &workout, workoutExerciseId: suggestion.workoutExerciseId, newExercise: selected))

        #expect(workout.exercises[0].id == second.id)
        #expect(workout.exercises[0].exercise == dumbbellPress)
        #expect(workout.exercises[1] == first)
        #expect(manager.suggestEntrySwaps(for: workout, from: [dumbbellPress]).map(\.workoutExerciseId) == [first.id])
    }

    @Test func tupleSuggestionsRemainCompatibleWithEntrySuggestions() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let workout = Workout(name: "Push", exercises: [
            WorkoutExercise(exercise: press), WorkoutExercise(exercise: press)
        ])

        let entries = manager.suggestEntrySwaps(for: workout, from: [dumbbellPress])
        let tuples = manager.suggestSwaps(for: workout, from: [dumbbellPress])

        #expect(tuples.map(\.original) == entries.map(\.original))
        #expect(tuples.map(\.alternatives) == entries.map(\.alternatives))
        #expect(!manager.suggestSwaps(for: workout).isEmpty)
    }
}
