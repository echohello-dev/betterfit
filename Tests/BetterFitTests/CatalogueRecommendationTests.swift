import Foundation
import Testing
import BetterFit

struct CatalogueRecommendationTests {
    private let press = Exercise(
        name: "Barbell Bench Press", equipmentRequired: .barbell, muscleGroups: [.chest, .triceps])
    private let dumbbellPress = Exercise(
        name: "Dumbbell Bench Press", equipmentRequired: .dumbbell,
        muscleGroups: [.chest, .triceps], imageURL: "dumbbell-press.png")

    // MARK: - Recommendation Flow

    @Test func swapsEveryRepeatedEntryAndPreservesTargetsAndStoredData() throws {
        let template = WorkoutTemplate(name: "Push", exercises: [
            TemplateExercise(exercise: press, targetSets: [TargetSet(reps: 12, weight: 20)]),
            TemplateExercise(exercise: dumbbellPress, targetSets: [TargetSet(reps: 8, weight: 16)]),
            TemplateExercise(exercise: press, targetSets: [
                TargetSet(reps: 6, weight: 40), TargetSet(reps: 5, weight: 42)
            ])
        ])
        let betterFit = try makeBetterFit(templates: [template])
        let plan = betterFit.planManager.getActivePlan()

        let workout = try #require(betterFit.getRecommendedWorkout(from: [dumbbellPress]))

        #expect(workout.name == template.name)
        #expect(workout.templateId == template.id)
        #expect(!workout.isCompleted)
        #expect(workout.exercises.map(\.exercise) == [dumbbellPress, dumbbellPress, dumbbellPress])
        #expect(Set(workout.exercises.map(\.id)).count == 3)
        #expect(workout.exercises.map { $0.sets.map(\.reps) } == [[12], [8], [6, 5]])
        #expect(workout.exercises.map { $0.sets.map(\.weight) } == [[20], [16], [40, 42]])
        #expect(workout.exercises.flatMap(\.sets).allSatisfy { !$0.isCompleted })
        #expect(betterFit.templateManager.getTemplate(id: template.id) == template)
        #expect(betterFit.planManager.getActivePlan() == plan)
        #expect(betterFit.getWorkoutHistory().isEmpty)
    }

    @Test func choosesFirstEligibleCatalogueExerciseAndReflectsAvailabilityChanges() throws {
        let template = WorkoutTemplate(name: "Push", exercises: [TemplateExercise(exercise: press)])
        let betterFit = try makeBetterFit(templates: [template])
        let machinePress = Exercise(
            name: "Machine Press", equipmentRequired: .machine,
            muscleGroups: [.triceps, .chest], imageURL: "machine-press.png")
        let curl = Exercise(name: "Curl", equipmentRequired: .dumbbell, muscleGroups: [.biceps])
        let catalogue = [curl, machinePress, dumbbellPress]

        let dumbbellWorkout = try #require(betterFit.getRecommendedWorkout(from: catalogue))
        #expect(dumbbellWorkout.exercises.map(\.exercise) == [dumbbellPress])

        betterFit.equipmentSwapManager.setAvailableEquipment([.machine, .dumbbell])
        let machineWorkout = try #require(betterFit.getRecommendedWorkout(from: catalogue))
        #expect(machineWorkout.exercises.map(\.exercise) == [machinePress])

        betterFit.equipmentSwapManager.setAvailableEquipment([.barbell, .machine, .dumbbell])
        let originalWorkout = try #require(betterFit.getRecommendedWorkout(from: catalogue))
        #expect(originalWorkout.exercises.map(\.exercise) == [press])
        #expect(originalWorkout.id != machineWorkout.id)
        #expect(originalWorkout.exercises[0].id != machineWorkout.exercises[0].id)
    }

    @Test(arguments: ["empty catalogue", "unrelated muscles", "unavailable equipment"])
    func leavesUnmatchedEntriesUnchanged(_ scenario: String) throws {
        let template = WorkoutTemplate(name: "Push", exercises: [TemplateExercise(exercise: press)])
        let betterFit = try makeBetterFit(templates: [template])
        let catalogue: [Exercise]
        switch scenario {
        case "unrelated muscles":
            catalogue = [Exercise(name: "Curl", equipmentRequired: .dumbbell, muscleGroups: [.biceps])]
        case "unavailable equipment":
            catalogue = [dumbbellPress]
            betterFit.equipmentSwapManager.setAvailableEquipment([])
        default:
            catalogue = []
        }

        let workout = try #require(betterFit.getRecommendedWorkout(from: catalogue))

        #expect(workout.exercises.map(\.exercise) == [press])
        #expect(workout.templateId == template.id)
    }

    @Test func usesFirstTemplateInCurrentWeek() throws {
        let first = WorkoutTemplate(name: "Previous week")
        let current = WorkoutTemplate(name: "Current week", exercises: [TemplateExercise(exercise: press)])
        let later = WorkoutTemplate(name: "Later session")
        let betterFit = try makeBetterFit(templates: [first, current, later])
        let plan = TrainingPlan(name: "Two weeks", weeks: [
            TrainingWeek(weekNumber: 1, workouts: [first.id]),
            TrainingWeek(weekNumber: 2, workouts: [current.id, later.id])
        ], currentWeek: 1, goal: .strength)
        betterFit.planManager.addPlan(plan)
        betterFit.planManager.setActivePlan(plan.id)

        let workout = try #require(betterFit.getRecommendedWorkout(from: [dumbbellPress]))

        #expect(workout.templateId == current.id)
        #expect(workout.name == current.name)
        #expect(workout.exercises.map(\.exercise) == [dumbbellPress])
    }

    // MARK: - Missing Plans and Compatibility

    @Test(arguments: ["no active plan", "no weeks", "past last week", "empty week", "missing template"])
    func returnsNilWithoutScheduledTemplate(_ scenario: String) throws {
        let template = WorkoutTemplate(name: "Push", exercises: [TemplateExercise(exercise: press)])
        let betterFit = try makeBetterFit(templates: [template])
        var plan = TrainingPlan(name: "Unavailable session", goal: .strength)
        switch scenario {
        case "no active plan":
            let active = try #require(betterFit.planManager.getActivePlan())
            betterFit.planManager.removePlan(active.id)
        case "no weeks":
            break
        case "past last week":
            plan.weeks = [TrainingWeek(weekNumber: 1, workouts: [template.id])]
            plan.currentWeek = 1
        case "empty week":
            plan.weeks = [TrainingWeek(weekNumber: 1)]
        default:
            plan.weeks = [TrainingWeek(weekNumber: 1, workouts: [UUID(), template.id])]
        }
        if scenario != "no active plan" {
            betterFit.planManager.addPlan(plan)
            betterFit.planManager.setActivePlan(plan.id)
        }

        #expect(betterFit.getRecommendedWorkout(from: [dumbbellPress]) == nil)
        #expect(betterFit.getRecommendedWorkout() == nil)
    }

    @Test func emptyTemplateStillProducesAnEmptyWorkout() throws {
        let template = WorkoutTemplate(name: "Rest")
        let betterFit = try makeBetterFit(templates: [template])

        let workout = try #require(betterFit.getRecommendedWorkout(from: [dumbbellPress]))

        #expect(workout.templateId == template.id)
        #expect(workout.exercises.isEmpty)
    }

    @Test func noArgumentAPIStillUsesGeneratedAlternatives() throws {
        let template = WorkoutTemplate(name: "Push", exercises: [TemplateExercise(exercise: press)])
        let betterFit = try makeBetterFit(templates: [template])

        let workout = try #require(betterFit.getRecommendedWorkout())

        #expect(workout.templateId == template.id)
        #expect(workout.exercises.map(\.exercise.name) == ["Barbell Bench Press (dumbbell)"])
        #expect(workout.exercises.map(\.exercise.equipmentRequired) == [.dumbbell])
    }

    // MARK: - Fixtures

    private func makeBetterFit(templates: [WorkoutTemplate]) throws -> BetterFit {
        let defaults = try #require(UserDefaults(suiteName: "CatalogueRecommendationTests.\(UUID())"))
        let betterFit = BetterFit(persistenceService: LocalPersistenceService(userDefaults: defaults))
        for template in templates {
            betterFit.templateManager.addTemplate(template)
        }
        let plan = TrainingPlan(name: "Training", weeks: [
            TrainingWeek(weekNumber: 1, workouts: templates.map(\.id))
        ], goal: .strength)
        betterFit.planManager.addPlan(plan)
        betterFit.planManager.setActivePlan(plan.id)
        betterFit.equipmentSwapManager.setAvailableEquipment([.dumbbell])
        return betterFit
    }
}
