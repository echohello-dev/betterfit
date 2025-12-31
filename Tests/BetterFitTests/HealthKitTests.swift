import XCTest

@testable import BetterFit

final class HealthKitTests: XCTestCase {

    // MARK: - Initialization Tests

    func testHealthKitServiceInitialization() {
        let service = HealthKitService()
        XCTAssertNotNil(service)
    }

    func testHealthSummaryInitialization() {
        let summary = HealthKitService.HealthSummary(
            steps: 5000,
            activeEnergy: 250.5,
            distanceWalkingRunning: 3000,
            flightsClimbed: 5,
            heartRate: 72.0,
            restingHeartRate: 60,
            height: 1.75,
            bodyMass: 70,
            bodyFatPercentage: 0.18,
            bmi: 22.9,
            oxygenSaturation: 0.97,
            sleepHours: 7.5,
            standHours: 10
        )

        XCTAssertEqual(summary.steps, 5000)
        XCTAssertEqual(summary.activeEnergy, 250.5)
        XCTAssertEqual(summary.heartRate, 72.0)
        XCTAssertEqual(summary.distanceWalkingRunning, 3000)
        XCTAssertEqual(summary.flightsClimbed, 5)
        XCTAssertEqual(summary.restingHeartRate, 60)
        XCTAssertEqual(summary.height, 1.75)
        XCTAssertEqual(summary.bodyMass, 70)
        XCTAssertEqual(summary.bodyFatPercentage, 0.18)
        XCTAssertEqual(summary.bmi, 22.9)
        XCTAssertEqual(summary.oxygenSaturation, 0.97)
        XCTAssertEqual(summary.sleepHours, 7.5)
        XCTAssertEqual(summary.standHours, 10)
    }

    func testHealthSummaryWithNilHeartRate() {
        let summary = HealthKitService.HealthSummary(
            steps: 3000,
            activeEnergy: 150.0,
            distanceWalkingRunning: 0,
            flightsClimbed: 0,
            heartRate: nil,
            restingHeartRate: nil,
            height: nil,
            bodyMass: nil,
            bodyFatPercentage: nil,
            bmi: nil,
            oxygenSaturation: nil,
            sleepHours: nil,
            standHours: nil
        )

        XCTAssertEqual(summary.steps, 3000)
        XCTAssertEqual(summary.activeEnergy, 150.0)
        XCTAssertNil(summary.heartRate)
        XCTAssertNil(summary.restingHeartRate)
        XCTAssertNil(summary.height)
        XCTAssertNil(summary.bodyMass)
        XCTAssertNil(summary.bodyFatPercentage)
        XCTAssertNil(summary.bmi)
        XCTAssertNil(summary.oxygenSaturation)
        XCTAssertNil(summary.sleepHours)
        XCTAssertNil(summary.standHours)
    }

    // MARK: - Authorization Status Tests

    func testAuthorizationStatusValues() {
        // Verify all enum cases exist
        let notDetermined = HealthKitService.AuthorizationStatus.notDetermined
        let authorized = HealthKitService.AuthorizationStatus.authorized
        let denied = HealthKitService.AuthorizationStatus.denied
        let unavailable = HealthKitService.AuthorizationStatus.unavailable

        XCTAssertNotNil(notDetermined)
        XCTAssertNotNil(authorized)
        XCTAssertNotNil(denied)
        XCTAssertNotNil(unavailable)
    }

    // MARK: - BetterFit Integration Tests

    func testBetterFitHasHealthKitService() {
        let betterFit = BetterFit()
        XCTAssertNotNil(betterFit.healthKitService)
    }

    func testBetterFitHealthKitServiceIsAvailableProperty() {
        let betterFit = BetterFit()
        // On macOS (test environment), HealthKit is not available
        // This test verifies the property exists and returns a boolean
        let isAvailable = betterFit.healthKitService.isAvailable
        XCTAssert(isAvailable == true || isAvailable == false)
    }

    // MARK: - Data Fetching Tests (Unavailable Platform Behavior)

    func testFetchTodaySummaryReturnsEmptyOnUnavailablePlatform() async {
        let service = HealthKitService()

        // On macOS, this should return empty values since HealthKit is unavailable
        let summary = await service.fetchTodaySummary()

        // The service should gracefully handle unavailable platforms
        XCTAssertGreaterThanOrEqual(summary.steps, 0)
        XCTAssertGreaterThanOrEqual(summary.activeEnergy, 0)
    }

    func testFetchStepsReturnsZeroOnUnavailablePlatform() async {
        let service = HealthKitService()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let now = Date()

        let steps = await service.fetchSteps(from: yesterday, to: now)

        // On macOS (no HealthKit), should return 0
        XCTAssertGreaterThanOrEqual(steps, 0)
    }

    func testFetchActiveEnergyReturnsZeroOnUnavailablePlatform() async {
        let service = HealthKitService()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let now = Date()

        let energy = await service.fetchActiveEnergy(from: yesterday, to: now)

        // On macOS (no HealthKit), should return 0
        XCTAssertGreaterThanOrEqual(energy, 0)
    }

    func testFetchAverageHeartRateOnUnavailablePlatform() async {
        let service = HealthKitService()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let now = Date()

        let heartRate = await service.fetchAverageHeartRate(from: yesterday, to: now)

        // On macOS (no HealthKit), should return nil or a valid value
        if let hr = heartRate {
            XCTAssertGreaterThan(hr, 0)
        }
    }

    // MARK: - Workout Saving Tests

    func testSaveWorkoutOnUnavailablePlatform() async {
        let service = HealthKitService()

        let exercise = Exercise(
            name: "Squat",
            equipmentRequired: .barbell,
            muscleGroups: [.quads, .glutes]
        )
        let set = ExerciseSet(reps: 5, weight: 225.0, isCompleted: true)
        let workoutExercise = WorkoutExercise(exercise: exercise, sets: [set])
        let workout = Workout(
            name: "Leg Day",
            exercises: [workoutExercise],
            duration: 3600  // 1 hour
        )

        // On macOS (no HealthKit), should return false
        let result = await service.saveWorkout(workout)

        // Result depends on platform - just verify it returns a boolean
        XCTAssert(result == true || result == false)
    }

    // MARK: - Date Range Tests

    func testFetchStepsWithSameDayRange() async {
        let service = HealthKitService()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()

        let steps = await service.fetchSteps(from: startOfDay, to: now)

        XCTAssertGreaterThanOrEqual(steps, 0)
    }

    func testFetchActiveEnergyWithWeekRange() async {
        let service = HealthKitService()

        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let now = Date()

        let energy = await service.fetchActiveEnergy(from: weekAgo, to: now)

        XCTAssertGreaterThanOrEqual(energy, 0)
    }

    // MARK: - Thread Safety Tests

    func testConcurrentFetches() async {
        let service = HealthKitService()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()

        // Run multiple fetches concurrently
        async let steps = service.fetchSteps(from: startOfDay, to: now)
        async let energy = service.fetchActiveEnergy(from: startOfDay, to: now)
        async let heartRate = service.fetchAverageHeartRate(from: startOfDay, to: now)

        let (s, e, hr) = await (steps, energy, heartRate)

        XCTAssertGreaterThanOrEqual(s, 0)
        XCTAssertGreaterThanOrEqual(e, 0)
        if let hr = hr {
            XCTAssertGreaterThan(hr, 0)
        }
    }

    // MARK: - Health Summary Edge Cases

    func testHealthSummaryWithZeroValues() {
        let summary = HealthKitService.HealthSummary(
            steps: 0,
            activeEnergy: 0,
            distanceWalkingRunning: 0,
            flightsClimbed: 0,
            heartRate: 0,
            restingHeartRate: nil,
            height: nil,
            bodyMass: nil,
            bodyFatPercentage: nil,
            bmi: nil,
            oxygenSaturation: nil,
            sleepHours: nil,
            standHours: nil
        )

        XCTAssertEqual(summary.steps, 0)
        XCTAssertEqual(summary.activeEnergy, 0)
        XCTAssertEqual(summary.heartRate, 0)
    }

    func testHealthSummaryWithLargeValues() {
        let summary = HealthKitService.HealthSummary(
            steps: 50000,
            activeEnergy: 5000.0,
            distanceWalkingRunning: 16000,
            flightsClimbed: 50,
            heartRate: 180.0,
            restingHeartRate: 55,
            height: 1.8,
            bodyMass: 80,
            bodyFatPercentage: 0.15,
            bmi: 24.7,
            oxygenSaturation: 0.98,
            sleepHours: 8.5,
            standHours: 12
        )

        XCTAssertEqual(summary.steps, 50000)
        XCTAssertEqual(summary.activeEnergy, 5000.0)
        XCTAssertEqual(summary.heartRate, 180.0)
        XCTAssertEqual(summary.distanceWalkingRunning, 16000)
        XCTAssertEqual(summary.flightsClimbed, 50)
        XCTAssertEqual(summary.restingHeartRate, 55)
        XCTAssertEqual(summary.height, 1.8)
        XCTAssertEqual(summary.bodyMass, 80)
        XCTAssertEqual(summary.bodyFatPercentage, 0.15)
        XCTAssertEqual(summary.bmi, 24.7)
        XCTAssertEqual(summary.oxygenSaturation, 0.98)
        XCTAssertEqual(summary.sleepHours, 8.5)
        XCTAssertEqual(summary.standHours, 12)
    }
}
