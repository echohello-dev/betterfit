import Foundation
import Testing

import BetterFit

struct WorkoutRegionRecoveryTests {

    // MARK: - Recording

    @Test(arguments: [
        [.quads, .glutes],
        [.quads, .quads],
        [.hamstrings, .glutes, .calves]
    ] as [[MuscleGroup]])
    func compoundExerciseFatiguesRegionOnce(_ muscleGroups: [MuscleGroup]) {
        var recovery = BodyMapRecovery()

        recovery.recordWorkout(workout([muscleGroups]))

        #expect(recovery.regions == [.legs: .fatigued])
    }

    @Test
    func multipleExercisesFatigueEachTargetedRegionOnce() {
        var recovery = BodyMapRecovery(regions: [.chest: .slightlyFatigued])

        recovery.recordWorkout(workout([
            [.quads, .glutes], [.hamstrings, .calves],
            [.biceps, .triceps], [.forearms], [.back, .lats]
        ]))

        #expect(recovery.regions == [
            .legs: .fatigued, .arms: .fatigued, .back: .fatigued,
            .chest: .slightlyFatigued
        ])
    }

    @Test
    func separateWorkoutsStillEscalateFatigue() {
        var recovery = BodyMapRecovery()

        recovery.recordWorkout(workout([[.quads, .glutes]]))
        #expect(recovery.regions[.legs] == .fatigued)

        recovery.recordWorkout(workout([[.hamstrings, .calves]]))
        #expect(recovery.regions[.legs] == .sore)
    }

    @Test(arguments: [RecoveryStatus.slightlyFatigued, .fatigued, .sore])
    func existingFatigueStillEscalates(_ status: RecoveryStatus) {
        var recovery = BodyMapRecovery(regions: [.arms: status])

        recovery.recordWorkout(workout([[.biceps, .triceps], [.forearms]]))

        #expect(recovery.regions == [.arms: .sore])
    }

    @Test(arguments: [[], [[]]] as [[[MuscleGroup]]])
    func workoutsWithoutTargetMusclesLeaveRegionsUnchanged(_ groups: [[MuscleGroup]]) {
        let regions: [BodyRegion: RecoveryStatus] = [.chest: .fatigued, .legs: .sore]
        var recovery = BodyMapRecovery(regions: regions)

        recovery.recordWorkout(workout(groups))

        #expect(recovery.regions == regions)
    }

    // MARK: - Fixtures

    private func workout(_ groups: [[MuscleGroup]]) -> Workout {
        Workout(
            name: "Training session",
            exercises: groups.map { muscles in
                WorkoutExercise(exercise: Exercise(
                    name: "Exercise", equipmentRequired: .bodyweight, muscleGroups: muscles
                ))
            }
        )
    }
}
