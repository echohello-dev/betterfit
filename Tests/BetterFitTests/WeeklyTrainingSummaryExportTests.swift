import XCTest

import BetterFit

final class WeeklyTrainingSummaryExportTests: XCTestCase {

    // MARK: - Fixtures

    private let weekStart = Date(timeIntervalSince1970: 1776038400) // 13 April 2026, UTC

    private var sample: [WeeklyTrainingSummary] {
        [WeeklyTrainingSummary(
            weekStart: weekStart,
            workoutCount: 3,
            totalDuration: 5400,
            totalActiveEnergyKilocalories: 650.5,
            totalDistanceMetres: 12000,
            averageHeartRate: 145.5,
            maximumHeartRate: 180,
            activityCounts: ["Running": 2, "Cycling": 1]
        )]
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    // MARK: - CSV

    func testCSVHeaderUnitsAndSortedActivityCounts() throws {
        let expected = "week_start,workout_count,duration_seconds,active_energy_kcal,distance_metres,"
            + "average_heart_rate,maximum_heart_rate,activity_counts\n"
            + #"2026-04-13T00:00:00Z,3,5400,650.5,12000,145.5,180,"{""Cycling"":1,""Running"":2}""# + "\n"

        XCTAssertEqual(try sample.csvString(), expected)
    }

    func testCSVDistinguishesMissingMetricsFromMeasuredZero() throws {
        let summaries = [
            WeeklyTrainingSummary(weekStart: weekStart),
            WeeklyTrainingSummary(
                weekStart: weekStart, totalDuration: 0, totalActiveEnergyKilocalories: 0,
                totalDistanceMetres: 0, averageHeartRate: 0, maximumHeartRate: 0
            )
        ]
        let rows = try summaries.csvString().split(separator: "\n")

        XCTAssertEqual(rows[1], #"2026-04-13T00:00:00Z,0,,,,,,"{}""#)
        XCTAssertEqual(rows[2], #"2026-04-13T00:00:00Z,0,0,0,0,0,0,"{}""#)
    }

    func testCSVEmptyArrayIsHeaderOnly() throws {
        XCTAssertEqual(
            try [WeeklyTrainingSummary]().csvString(),
            [WeeklyTrainingSummary].weeklyTrainingSummaryCSVHeader + "\n"
        )
    }

    func testCSVPreservesArrayOrder() throws {
        let summaries = [
            WeeklyTrainingSummary(weekStart: weekStart.addingTimeInterval(7 * 86400)),
            sample[0]
        ]
        let rows = try summaries.csvString().split(separator: "\n")

        XCTAssertTrue(rows[1].hasPrefix("2026-04-20T00:00:00Z,"))
        XCTAssertTrue(rows[2].hasPrefix("2026-04-13T00:00:00Z,"))
    }

    func testCSVQuotesActivityNamesContainingCSVDelimitersAndUnicode() throws {
        let summary = WeeklyTrainingSummary(
            weekStart: weekStart, workoutCount: 2,
            activityCounts: ["Run, \"fast\"\n室": 2]
        )
        let rows = try [summary].csvString().split(separator: "\n")

        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[1], #"2026-04-13T00:00:00Z,2,,,,,,"{""Run, \""fast\""\n室"":2}""#)
    }

    // MARK: - JSON

    func testJSONRoundTripPreservesOrderActivityNamesAndMissingMetrics() throws {
        let summaries = sample + [WeeklyTrainingSummary(
            weekStart: weekStart.addingTimeInterval(7 * 86400),
            totalDuration: 0, activityCounts: ["Run, \"fast\"\n室": 2]
        )]
        let data = try summaries.jsonData()
        let decoded = try decoder.decode([WeeklyTrainingSummary].self, from: data)
        XCTAssertEqual(decoded, summaries)

        let objects = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        XCTAssertEqual(objects[0]["weekStart"] as? String, "2026-04-13T00:00:00Z")
        XCTAssertEqual(objects[1]["totalDuration"] as? Double, 0)
        XCTAssertNil(objects[1]["averageHeartRate"])
        XCTAssertNil(objects[1]["totalActiveEnergyKilocalories"])
    }

    func testJSONEmptyArray() throws {
        let data = try [WeeklyTrainingSummary]().jsonData()
        XCTAssertEqual(try decoder.decode([WeeklyTrainingSummary].self, from: data), [])
    }

    func testJSONRejectsNonFiniteMetrics() {
        let summaries = [WeeklyTrainingSummary(weekStart: weekStart, totalDuration: .infinity)]
        XCTAssertThrowsError(try summaries.jsonData())
    }

    // MARK: - File Writing

    func testWritesAndReplacesCSVAndJSONFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let csvURL = directory.appendingPathComponent("weekly.csv")
        let jsonURL = directory.appendingPathComponent("weekly.json")
        try "old contents".write(to: csvURL, atomically: true, encoding: .utf8)
        try "old contents".write(to: jsonURL, atomically: true, encoding: .utf8)

        try sample.writeCSV(to: csvURL)
        try sample.writeJSON(to: jsonURL)

        XCTAssertEqual(try String(contentsOf: csvURL, encoding: .utf8), try sample.csvString())
        XCTAssertEqual(try decoder.decode([WeeklyTrainingSummary].self, from: Data(contentsOf: jsonURL)), sample)
    }

    func testFileWritingPropagatesErrors() {
        let missingDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertThrowsError(try sample.writeCSV(to: missingDirectory.appendingPathComponent("weekly.csv")))
        XCTAssertThrowsError(try sample.writeJSON(to: missingDirectory.appendingPathComponent("weekly.json")))
    }

    // MARK: - End to End

    func testExportsParsedWorkoutsWithNormalisedStatisticsAndCalendarWeeks() throws {
        let xml = """
            <HealthData locale="en_AU">
              <Workout workoutActivityType="Running" duration="30" durationUnit="min"
                startDate="2026-04-20 00:30:00 +1000">
                <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="418.4" unit="kJ"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="5" unit="km"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate"
                  average="150" maximum="180" unit="count/min"/>
              </Workout>
              <Workout workoutActivityType="Yoga" startDate="2026-04-20 12:00:00 +1000"/>
            </HealthData>
            """
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        let summaries = try HealthExportParser.parseExport(xml: xml).weeklyTrainingSummaries(calendar: calendar)

        let rows = try summaries.csvString().split(separator: "\n")
        XCTAssertEqual(rows.count, 3)
        let run = rows[1].split(separator: ",", maxSplits: 7).map(String.init)
        XCTAssertEqual(Array(run.prefix(3)), ["2026-04-13T00:00:00Z", "1", "1800"])
        // Unit conversion can produce a floating point rounding remainder.
        XCTAssertEqual(try XCTUnwrap(Double(run[3])), 100, accuracy: 0.000001)
        XCTAssertEqual(Array(run.suffix(4)), ["5000", "150", "180", #""{""Running"":1}""#])
        XCTAssertEqual(
            rows[2],
            #"2026-04-20T00:00:00Z,1,,,,,,"{""Yoga"":1}""#
        )
        XCTAssertEqual(try decoder.decode([WeeklyTrainingSummary].self, from: summaries.jsonData()), summaries)
    }
}
