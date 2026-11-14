import Foundation
import Testing
@testable import BetterFit

struct CatalogueWorkoutSwapTests {
    private let press = Exercise(
        name: "Barbell Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest, .triceps])
    private let row = Exercise(
        name: "Barbell Row", equipmentRequired: .barbell, muscleGroups: [.back, .biceps])
    private let dumbbellPress = Exercise(
        name: "Dumbbell Bench Press", equipmentRequired: .dumbbell,
        muscleGroups: [.chest, .triceps], imageURL: "dumbbell-press.png")

    // MARK: - Workout Suggestions

    @Test func suggestsOnlyEligibleEntriesInWorkoutAndCatalogueOrder() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell, .machine, .bodyweight])
        let machinePress = Exercise(
            name: "Machine Chest Press", equipmentRequired: .machine,
            muscleGroups: [.triceps, .chest], imageURL: "machine-press.png")
        let dumbbellRow = Exercise(
            name: "Dumbbell Row", equipmentRequired: .dumbbell,
            muscleGroups: [.back, .biceps], imageURL: "row.png")
        let plank = Exercise(name: "Plank", equipmentRequired: .bodyweight, muscleGroups: [.abs])
        let squat = Exercise(name: "Barbell Squat", equipmentRequired: .barbell, muscleGroups: [.quads])
        let bandPress = Exercise(
            name: "Band Press", equipmentRequired: .bands, muscleGroups: press.muscleGroups)
        let cableRow = Exercise(
            name: "Cable Row", equipmentRequired: .cable, muscleGroups: row.muscleGroups)
        let workout = Workout(name: "Full Body", exercises: [row, plank, squat, press].map {
            WorkoutExercise(exercise: $0)
        })
        let snapshot = workout
        let catalogue = [machinePress, bandPress, dumbbellRow, dumbbellPress, cableRow, machinePress]

        let suggestions = manager.suggestSwaps(for: workout, from: catalogue)

        #expect(suggestions.map(\.original) == [row, press])
        #expect(suggestions.map(\.alternatives) == [[dumbbellRow], [machinePress, dumbbellPress]])
        #expect(workout == snapshot)
        let first = try #require(suggestions.first)
        #expect(first.alternatives[0].imageURL == "row.png")
    }

    @Test func returnsNoSuggestionsForEmptyInputsOrNoEligibleMatches() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])
        let unrelated = Exercise(name: "Curl", equipmentRequired: .dumbbell, muscleGroups: [.biceps])

        #expect(manager.suggestSwaps(for: Workout(name: "Empty"), from: [dumbbellPress]).isEmpty)
        #expect(manager.suggestSwaps(for: workout, from: []).isEmpty)
        #expect(manager.suggestSwaps(for: workout, from: [unrelated]).isEmpty)
    }

    @Test func reflectsEquipmentAvailabilityChanges() {
        let manager = EquipmentSwapManager(availableEquipment: [.barbell, .dumbbell])
        let workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])

        #expect(manager.suggestSwaps(for: workout, from: [dumbbellPress]).isEmpty)
        manager.setAvailableEquipment([.dumbbell])
        #expect(manager.suggestSwaps(for: workout, from: [dumbbellPress]).map(\.original) == [press])
        manager.setAvailableEquipment([])
        #expect(manager.suggestSwaps(for: workout, from: [dumbbellPress]).isEmpty)
    }

    @Test func preservesRepeatedWorkoutEntries() {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let workout = Workout(name: "Repeated Press", exercises: [
            WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 8)], notes: "Warm up"),
            WorkoutExercise(exercise: row),
            WorkoutExercise(exercise: press, sets: [ExerciseSet(reps: 6)], notes: "Working sets")
        ])

        let suggestions = manager.suggestSwaps(for: workout, from: [dumbbellPress])

        #expect(suggestions.map(\.original) == [press, press])
        #expect(suggestions.map(\.alternatives) == [[dumbbellPress], [dumbbellPress]])
    }

    // MARK: - Compatibility and Application

    @Test func keepsGeneratedSuggestionsAvailableWithoutACatalogue() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let workout = Workout(name: "Push", exercises: [WorkoutExercise(exercise: press)])

        #expect(manager.suggestSwaps(for: workout, from: []).isEmpty)
        let generated = try #require(manager.suggestSwaps(for: workout).first)
        #expect(generated.original == press)
        #expect(generated.alternatives.map(\.equipmentRequired) == [.dumbbell])
        #expect(generated.alternatives.map(\.name) == ["Barbell Bench Press (dumbbell)"])
    }

    @Test func appliesSuggestedExerciseWithoutChangingWorkoutMetadata() throws {
        let manager = EquipmentSwapManager(availableEquipment: [.dumbbell])
        let timestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = WorkoutExercise(exercise: press, sets: [
            ExerciseSet(reps: 8, weight: 20, isCompleted: true, timestamp: timestamp, autoTracked: true),
            ExerciseSet(reps: 6, weight: 22)
        ], notes: "Controlled tempo")
        var workout = Workout(
            name: "Push", exercises: [entry, WorkoutExercise(exercise: row)],
            date: timestamp, duration: 600, templateId: UUID())
        let originalWorkout = workout
        let suggestion = try #require(manager.suggestSwaps(for: workout, from: [dumbbellPress]).first)
        let selected = try #require(suggestion.alternatives.first)

        #expect(workout == originalWorkout)
        #expect(manager.applySwap(
            workout: &workout, originalExerciseId: suggestion.original.id, newExercise: selected))
        var expectedWorkout = originalWorkout
        expectedWorkout.exercises[0].exercise = dumbbellPress
        #expect(workout == expectedWorkout)
    }
}
