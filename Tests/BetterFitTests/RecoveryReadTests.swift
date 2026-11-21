import Foundation
import Testing

import BetterFit

struct RecoveryReadTests {

    // MARK: - Repeated Reads

    @Test(arguments: [RecoveryStatus.slightlyFatigued, .fatigued, .sore])
    func hourlyPollingMatchesElapsedRecovery(_ initialStatus: RecoveryStatus) {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let manager = BodyMapManager(
            recoveryMap: BodyMapRecovery(regions: [.legs: initialStatus], lastUpdated: start),
            now: { now }
        )
        let squat = exercise("Squat", muscles: [.quads, .glutes])
        let press = exercise("Press", muscles: [.chest])

        for hour in 0...72 {
            now = start.addingTimeInterval(Double(hour) * 3600)
            let expected = initialStatus.afterRecovery(hours: Double(hour))
            let snapshot = manager.getRecoveryMap()

            #expect(snapshot.regions[.legs] == expected)
            #expect(snapshot.lastUpdated == now)
            #expect(manager.getRecoveryStatus(for: .legs) == expected)
            #expect(manager.isReadyForTraining(region: .legs) ==
                (expected == .recovered || expected == .slightlyFatigued))
            #expect(manager.getRecommendedExercises(available: [squat, press]) ==
                (expected == .sore ? [press] : [squat, press]))
            #expect(manager.getOverallRecoveryPercentage() == score(expected))
        }
    }

    @Test
    func pollingPreservesDifferentRegionalStatuses() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let manager = BodyMapManager(
            recoveryMap: BodyMapRecovery(
                regions: [.chest: .slightlyFatigued, .legs: .sore], lastUpdated: start
            ),
            now: { now }
        )

        now = start.addingTimeInterval(24 * 3600)
        #expect(manager.getRecoveryStatus(for: .chest) == .recovered)
        #expect(manager.getRecoveryStatus(for: .legs) == .sore)

        now = start.addingTimeInterval(48 * 3600)
        #expect(manager.getRecoveryMap().regions == [.chest: .recovered, .legs: .fatigued])
        #expect(manager.getOverallRecoveryPercentage() == 75)

        now = start.addingTimeInterval(72 * 3600)
        #expect(manager.getRecoveryMap().regions == [.chest: .recovered, .legs: .recovered])
    }

    @Test
    func returnedSnapshotsDoNotChangeStoredRecovery() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let manager = BodyMapManager(
            recoveryMap: BodyMapRecovery(regions: [.legs: .sore], lastUpdated: start),
            now: { start }
        )
        var snapshot = manager.getRecoveryMap()
        snapshot.regions[.legs] = .recovered

        #expect(manager.getRecoveryStatus(for: .legs) == .sore)
        #expect(manager.getRecoveryStatus(for: .chest) == .recovered)
        #expect(manager.getRecommendedExercises(
            available: [exercise("Squat", muscles: [.quads])], avoidSoreRegions: false
        ).count == 1)
        #expect(BodyMapManager(now: { start }).getOverallRecoveryPercentage() == 100)
    }

    // MARK: - Baseline Changes

    @Test(arguments: [false, true])
    func recordingAfterRecoveryStartsNewBaseline(pollBeforeRecording: Bool) {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let manager = BodyMapManager(
            recoveryMap: BodyMapRecovery(regions: [.legs: .fatigued], lastUpdated: start),
            now: { now }
        )
        now = start.addingTimeInterval(48 * 3600)
        if pollBeforeRecording {
            #expect(manager.getRecoveryStatus(for: .legs) == .recovered)
        }

        manager.recordWorkout(Workout(
            name: "Leg day", exercises: [WorkoutExercise(exercise: exercise("Squat", muscles: [.quads]))]
        ))

        #expect(manager.getRecoveryMap().regions[.legs] == .fatigued)
        now = now.addingTimeInterval(24 * 3600)
        #expect(manager.getRecoveryStatus(for: .legs) == .slightlyFatigued)
        now = now.addingTimeInterval(24 * 3600)
        #expect(manager.getRecoveryStatus(for: .legs) == .recovered)
    }

    @Test
    func resetDiscardsBaseline() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let manager = BodyMapManager(
            recoveryMap: BodyMapRecovery(regions: [.legs: .sore], lastUpdated: start),
            now: { start }
        )

        manager.reset()

        #expect(manager.getRecoveryMap().regions.isEmpty)
        #expect(manager.getRecoveryMap().lastUpdated == start)
        #expect(manager.getRecoveryStatus(for: .legs) == .recovered)
        #expect(manager.getOverallRecoveryPercentage() == 100)
    }

    // MARK: - Fixtures

    private func exercise(_ name: String, muscles: [MuscleGroup]) -> Exercise {
        Exercise(name: name, equipmentRequired: .bodyweight, muscleGroups: muscles)
    }

    private func score(_ status: RecoveryStatus) -> Double {
        switch status {
        case .recovered: return 100
        case .slightlyFatigued: return 75
        case .fatigued: return 50
        case .sore: return 25
        }
    }
}
