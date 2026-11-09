import XCTest

@testable import BetterFit

final class WeeklyTrainingSummaryTests: XCTestCase {

    // MARK: - Fixtures

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string)!
    }

    private func workout(
        _ activityType: String,
        start: String? = nil,
        duration: TimeInterval? = nil,
        totalEnergyBurned: Double? = nil,
        totalDistance: Double? = nil,
        statistics: [WorkoutStatistics] = []
    ) -> ParsedWorkout {
        ParsedWorkout(
            activityType: activityType,
            startDate: start.map { date($0) },
            duration: duration,
            totalEnergyBurned: totalEnergyBurned,
            totalDistance: totalDistance,
            statistics: statistics
        )
    }

    private func export(_ workouts: [ParsedWorkout]) -> HealthExport {
        HealthExport(workouts: workouts, records: [])
    }

    // MARK: - Grouping

    func testGroupsWorkoutsByWeekAndSorts() {
        let summaries = export([
            workout("HKWorkoutActivityTypeRunning", start: "2026-04-22 07:00:00"),
            workout("HKWorkoutActivityTypeRunning", start: "2026-04-14 07:00:00"),
            workout("HKWorkoutActivityTypeCycling", start: "2026-04-15 07:00:00")
        ]).weeklyTrainingSummaries(calendar: utcCalendar)

        XCTAssertEqual(summaries.count, 2)
        XCTAssertEqual(summaries[0].weekStart, date("2026-04-13 00:00:00"))
        XCTAssertEqual(summaries[0].workoutCount, 2)
        XCTAssertEqual(summaries[1].weekStart, date("2026-04-20 00:00:00"))
        XCTAssertEqual(summaries[1].workoutCount, 1)
    }

    func testEmptyExportReturnsNoSummaries() {
        XCTAssertTrue(export([]).weeklyTrainingSummaries(calendar: utcCalendar).isEmpty)
    }

    func testWorkoutsWithoutStartDateAreSkipped() {
        let undated = workout("HKWorkoutActivityTypeRunning")
        XCTAssertTrue(export([undated]).weeklyTrainingSummaries(calendar: utcCalendar).isEmpty)
    }

    // MARK: - Totals

    func testSumsDurationEnergyAndDistanceWithNormalisation() throws {
        let run = workout(
            "HKWorkoutActivityTypeRunning", start: "2026-04-14 07:00:00", duration: 1800,
            statistics: [
                WorkoutStatistics(
                    type: "HKQuantityTypeIdentifierActiveEnergyBurned", sum: 418.4, unit: "kJ"),
                WorkoutStatistics(
                    type: "HKQuantityTypeIdentifierDistanceWalkingRunning", sum: 5, unit: "km")
            ])
        let ride = workout(
            "HKWorkoutActivityTypeCycling", start: "2026-04-15 07:00:00", duration: 3600,
            totalEnergyBurned: 500, totalDistance: 20000)

        let summaries = export([run, ride]).weeklyTrainingSummaries(calendar: utcCalendar)
        let week = try XCTUnwrap(summaries.first)
        XCTAssertEqual(week.workoutCount, 2)
        XCTAssertEqual(week.totalDuration ?? 0, 5400, accuracy: 0.001)
        // Run energy is 418.4 kJ, which is 100 kcal. Ride falls back to its total.
        XCTAssertEqual(week.totalActiveEnergyKilocalories ?? 0, 600, accuracy: 0.001)
        XCTAssertEqual(week.totalDistanceMetres ?? 0, 25000, accuracy: 0.001)
    }

    func testMissingMetricsStayNil() throws {
        let summaries = export([
            workout("HKWorkoutActivityTypeYoga", start: "2026-04-14 07:00:00")
        ]).weeklyTrainingSummaries(calendar: utcCalendar)

        let week = try XCTUnwrap(summaries.first)
        XCTAssertEqual(week.workoutCount, 1)
        XCTAssertNil(week.totalDuration)
        XCTAssertNil(week.totalActiveEnergyKilocalories)
        XCTAssertNil(week.totalDistanceMetres)
        XCTAssertNil(week.averageHeartRate)
        XCTAssertNil(week.maximumHeartRate)
    }

    // MARK: - Heart Rate and Activities

    func testAverageAndMaximumHeartRate() throws {
        func heartRateWorkout(_ start: String, average: Double, maximum: Double) -> ParsedWorkout {
            workout(
                "HKWorkoutActivityTypeRunning", start: start,
                statistics: [
                    WorkoutStatistics(
                        type: "HKQuantityTypeIdentifierHeartRate",
                        average: average, minimum: 90, maximum: maximum, unit: "count/min")
                ])
        }

        let summaries = export([
            heartRateWorkout("2026-04-14 07:00:00", average: 140, maximum: 170),
            heartRateWorkout("2026-04-15 07:00:00", average: 160, maximum: 185),
            workout("HKWorkoutActivityTypeYoga", start: "2026-04-16 07:00:00")
        ]).weeklyTrainingSummaries(calendar: utcCalendar)

        let week = try XCTUnwrap(summaries.first)
        XCTAssertEqual(week.averageHeartRate ?? 0, 150, accuracy: 0.001)
        XCTAssertEqual(week.maximumHeartRate ?? 0, 185, accuracy: 0.001)
    }

    func testActivityCounts() throws {
        let summaries = export([
            workout("HKWorkoutActivityTypeRunning", start: "2026-04-14 07:00:00"),
            workout("HKWorkoutActivityTypeRunning", start: "2026-04-15 07:00:00"),
            workout("HKWorkoutActivityTypeCycling", start: "2026-04-16 07:00:00")
        ]).weeklyTrainingSummaries(calendar: utcCalendar)

        let week = try XCTUnwrap(summaries.first)
        XCTAssertEqual(week.activityCounts["HKWorkoutActivityTypeRunning"], 2)
        XCTAssertEqual(week.activityCounts["HKWorkoutActivityTypeCycling"], 1)
    }

    // MARK: - End to End

    func testWeeklySummariesFromParsedExport() throws {
        let xml = """
            <HealthData locale="en_AU">
              <Workout workoutActivityType="HKWorkoutActivityTypeRunning"
                duration="30" durationUnit="min"
                totalDistance="5" totalDistanceUnit="km"
                totalEnergyBurned="300" totalEnergyBurnedUnit="kcal"
                startDate="2026-04-19 07:00:00 +0000"
                endDate="2026-04-19 07:30:00 +0000">
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate"
                  average="155" minimum="105" maximum="178" unit="count/min"
                  startDate="2026-04-19 07:00:00 +0000"
                  endDate="2026-04-19 07:30:00 +0000"/>
              </Workout>
            </HealthData>
            """
        let parsed = try HealthExportParser.parseExport(xml: xml)
        let summaries = parsed.weeklyTrainingSummaries(calendar: utcCalendar)

        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(summaries[0].weekStart, date("2026-04-13 00:00:00"))
        XCTAssertEqual(summaries[0].workoutCount, 1)
        XCTAssertEqual(summaries[0].totalActiveEnergyKilocalories ?? 0, 300, accuracy: 0.001)
        XCTAssertEqual(summaries[0].averageHeartRate ?? 0, 155, accuracy: 0.001)
    }

    func testCodableRoundTrip() throws {
        let summaries = export([
            workout("HKWorkoutActivityTypeRunning", start: "2026-04-14 07:00:00", duration: 60)
        ]).weeklyTrainingSummaries(calendar: utcCalendar)
        let data = try JSONEncoder().encode(summaries)
        let decoded = try JSONDecoder().decode([WeeklyTrainingSummary].self, from: data)
        XCTAssertEqual(decoded, summaries)
    }
}
