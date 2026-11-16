import Foundation
import Testing

import BetterFit

struct WorkoutSummaryUnitTests {

    // MARK: - Supported Units

    @Test(arguments: [nil, "count/min", "COUNT/MIN"] as [String?])
    func heartRateUsesCanonicalOrOmittedUnit(unit: String?) throws {
        let workout = try parse(heartUnit: unit, stepUnit: "count")
        #expect(workout.averageHeartRate == 140)
        #expect(workout.minimumHeartRate == 100)
        #expect(workout.maximumHeartRate == 180)
    }

    @Test(arguments: [nil, "count", "COUNT"] as [String?])
    func stepsUseCanonicalOrOmittedUnit(unit: String?) throws {
        #expect(try parse(heartUnit: "count/min", stepUnit: unit).stepCount == 500)
    }

    // MARK: - Unsupported Units

    @Test(arguments: ["", "unknown", "kcal", "count", "count/s"])
    func unsupportedHeartRateUnitsPreserveRawStatistics(unit: String) throws {
        let workout = try parse(heartUnit: unit, stepUnit: "count")
        #expect(workout.averageHeartRate == nil)
        #expect(workout.minimumHeartRate == nil)
        #expect(workout.maximumHeartRate == nil)
        #expect(workout.stepCount == 500)
        let raw = try #require(workout.statistic(for: .heartRate))
        #expect(raw.average == 140)
        #expect(raw.minimum == 100)
        #expect(raw.maximum == 180)
        #expect(raw.unit == unit)
        let data = try JSONEncoder().encode(workout)
        #expect(try JSONDecoder().decode(ParsedWorkout.self, from: data) == workout)
    }

    @Test(arguments: ["", "unknown", "kcal", "count/min"])
    func unsupportedStepUnitsDoNotHideValidHeartRate(unit: String) throws {
        let workout = try parse(heartUnit: "count/min", stepUnit: unit)
        #expect(workout.stepCount == nil)
        #expect(workout.averageHeartRate == 140)
        #expect(workout.statistic(for: .stepCount)?.sum == 500)
        #expect(workout.statistic(for: .stepCount)?.unit == unit)
    }

    @Test
    func unsupportedUnitsStayMissingInAnalyticsAndExports() throws {
        let workout = try parse(heartUnit: "unknown", stepUnit: "unknown")
        let week = try #require(HealthExport(workouts: [workout]).weeklyTrainingSummaries().first)
        #expect(week.workoutCount == 1)
        #expect(week.averageHeartRate == nil)
        #expect(week.maximumHeartRate == nil)
        let row = try #require([workout].csvString().split(separator: "\n").last)
        #expect(row == "Running,,2026-04-19T07:00:00Z,,,,,,,,,")
        let json = try #require(JSONSerialization.jsonObject(with: [workout].jsonData()) as? [[String: Any]])
        #expect(json.first?.keys.sorted() == ["activityType", "startDate"])
    }

    @Test
    func unsupportedUnitsDoNotContaminateValidWeeklyHeartRate() throws {
        let invalid = try parse(heartUnit: "count/s", stepUnit: "unknown")
        let valid = try parse(heartUnit: "count/min", stepUnit: "count")
        for workouts in [[invalid, valid], [valid, invalid]] {
            let week = try #require(HealthExport(workouts: workouts).weeklyTrainingSummaries().first)
            #expect(week.workoutCount == 2)
            #expect(week.averageHeartRate == 140)
            #expect(week.maximumHeartRate == 180)
        }
    }

    @Test
    func measuredZeroRemainsZero() {
        let workout = ParsedWorkout(activityType: "Running", statistics: [
            WorkoutStatistics(type: "HKQuantityTypeIdentifierHeartRate", average: 0, minimum: 0, maximum: 0,
                              unit: "count/min"),
            WorkoutStatistics(type: "HKQuantityTypeIdentifierStepCount", sum: 0, unit: "count")
        ])
        #expect(workout.averageHeartRate == 0)
        #expect(workout.minimumHeartRate == 0)
        #expect(workout.maximumHeartRate == 0)
        #expect(workout.stepCount == 0)
    }

    // MARK: - Fixtures

    private func parse(heartUnit: String?, stepUnit: String?) throws -> ParsedWorkout {
        let heartAttribute = heartUnit.map { "unit=\"\($0)\"" } ?? ""
        let stepAttribute = stepUnit.map { "unit=\"\($0)\"" } ?? ""
        return try #require(HealthExportParser.parseWorkouts(xml: """
            <HealthData>
              <Workout workoutActivityType="Running" startDate="2026-04-19 07:00:00 +0000">
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate" \(heartAttribute)
                  average="140" minimum="100" maximum="180"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierStepCount" \(stepAttribute) sum="500"/>
              </Workout>
            </HealthData>
            """).first)
    }
}
