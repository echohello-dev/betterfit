import Foundation
import Testing

import BetterFit

struct WorkoutDurationUnitTests {

    // MARK: - Parsing

    @Test(arguments: [
        (nil, 30), ("s", 30), ("S", 30), ("sec", 30), ("SEC", 30),
        ("min", 1800), ("MIN", 1800), ("h", 108000), ("H", 108000), ("hr", 108000), ("HR", 108000)
    ] as [(String?, Double)])
    func supportedAndOmittedUnitsNormaliseToSeconds(unit: String?, seconds: Double) throws {
        let workout = try parse(unit: unit)
        #expect(workout.duration == seconds)
    }

    @Test(arguments: ["", "unknown", "day", "ms", "count", "kcal"])
    func unsupportedUnitsKeepWorkoutAndOtherMetrics(unit: String) throws {
        let workout = try parse(unit: unit)
        #expect(workout.duration == nil)
        #expect(workout.activityType == "Running")
        #expect(workout.sourceName == "Watch")
        #expect(workout.startDate != nil)
        #expect(workout.endDate != nil)
        #expect(workout.activeEnergyKilocalories == 100)
        #expect(workout.distanceMetres == 2000)
        #expect(workout.averageHeartRate == 140)
        let data = try JSONEncoder().encode(workout)
        #expect(try JSONDecoder().decode(ParsedWorkout.self, from: data) == workout)
    }

    // MARK: - Analytics and Exports

    @Test(arguments: [nil, "sec", "min", "hr"] as [String?])
    func measuredZeroRemainsZeroInSummariesAndExports(unit: String?) throws {
        let workout = try parse(unit: unit, duration: "0")
        #expect(workout.duration == 0)
        let weeks = HealthExport(workouts: [workout]).weeklyTrainingSummaries(calendar: calendar)
        #expect(weeks.first?.totalDuration == 0)
        #expect(try jsonObject([workout].jsonData())["durationSeconds"] as? Double == 0)
        #expect(try jsonObject(weeks.jsonData())["totalDuration"] as? Double == 0)
        #expect(csvFields([workout].csvString())[4] == "0")
        #expect(try csvFields(weeks.csvString())[2] == "0")
    }

    @Test
    func unsupportedDurationStaysMissingInSummariesAndExports() throws {
        let workout = try parse(unit: "day")
        let weeks = HealthExport(workouts: [workout]).weeklyTrainingSummaries(calendar: calendar)
        #expect(weeks.first?.workoutCount == 1)
        #expect(weeks.first?.totalDuration == nil)
        #expect(try jsonObject([workout].jsonData())["durationSeconds"] == nil)
        #expect(try jsonObject(weeks.jsonData())["totalDuration"] == nil)
        #expect(csvFields([workout].csvString())[4].isEmpty)
        #expect(try csvFields(weeks.csvString())[2].isEmpty)
    }

    @Test
    func unsupportedDurationDoesNotContaminateMixedWeeklyTotals() throws {
        let invalid = try parse(unit: "day")
        let valid = try parse(unit: "min")
        for workouts in [[invalid, valid], [valid, invalid]] {
            let weeks = HealthExport(workouts: workouts).weeklyTrainingSummaries(calendar: calendar)
            let week = try #require(weeks.first)
            #expect(week.workoutCount == 2)
            #expect(week.totalDuration == 1800)
            #expect(week.totalActiveEnergyKilocalories == 200)
            #expect(try jsonObject(weeks.jsonData())["totalDuration"] as? Double == 1800)
            #expect(try csvFields(weeks.csvString())[2] == "1800")
        }
    }

    // MARK: - Fixtures

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func parse(unit: String?, duration: String = "30") throws -> ParsedWorkout {
        let unitAttribute = unit.map { "durationUnit=\"\($0)\"" } ?? ""
        return try #require(HealthExportParser.parseWorkouts(xml: """
            <HealthData>
              <Workout workoutActivityType="Running" sourceName="Watch" duration="\(duration)" \(unitAttribute)
                startDate="2026-04-19 07:00:00 +0000" endDate="2026-04-19 07:30:00 +0000"
                totalEnergyBurned="100" totalEnergyBurnedUnit="kcal" totalDistance="2" totalDistanceUnit="km">
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate" average="140" unit="count/min"/>
              </Workout>
            </HealthData>
            """).first)
    }

    private func jsonObject(_ data: Data) throws -> [String: Any] {
        let objects = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        return try #require(objects.first)
    }

    private func csvFields(_ csv: String) -> [Substring] {
        csv.split(separator: "\n")[1].split(separator: ",", omittingEmptySubsequences: false)
    }
}
