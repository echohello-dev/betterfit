import Foundation
import Testing

import BetterFit

struct ParsedWorkoutExportTests {

    // MARK: - Fixtures

    private var workouts: [ParsedWorkout] {
        get throws {
            try HealthExportParser.parseWorkouts(xml: """
                <HealthData>
                  <Workout workoutActivityType="Running" sourceName="Watch, &quot;室&quot;"
                    startDate="2026-04-19 07:00:00 +1000" endDate="2026-04-19 07:30:00 +1000"
                    duration="30" durationUnit="min" totalEnergyBurned="999" totalEnergyBurnedUnit="kcal"
                    totalDistance="99" totalDistanceUnit="km">
                    <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="200" unit="kcal"/>
                    <WorkoutStatistics type="HKQuantityTypeIdentifierBasalEnergyBurned" sum="4184" unit="J"/>
                    <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="5" unit="km"/>
                    <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate"
                      average="150.5" minimum="100" maximum="180" unit="count/min"/>
                    <WorkoutStatistics type="HKQuantityTypeIdentifierStepCount" sum="6200" unit="count"/>
                  </Workout>
                  <Workout workoutActivityType="Cycling" duration="1" durationUnit="hr"
                    totalEnergyBurned="125" totalEnergyBurnedUnit="kcal"
                    totalDistance="2" totalDistanceUnit="km"/>
                  <Workout workoutActivityType="Yoga"/>
                </HealthData>
                """)
        }
    }

    private func objects(_ data: Data) throws -> [[String: Any]] {
        try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
    }

    // MARK: - Parsing Through Export

    @Test func csvExportsNormalisedStatisticsAndTopLevelFallback() throws {
        let expected = "activity_type,source_name,start_date,end_date,duration_seconds,active_energy_kcal,"
            + "basal_energy_kcal,distance_metres,average_heart_rate_bpm,minimum_heart_rate_bpm,"
            + "maximum_heart_rate_bpm,step_count\n"
            + #"Running,"Watch, ""室""",2026-04-18T21:00:00Z,2026-04-18T21:30:00Z,1800,200,1,5000,150.5,100,180,6200"#
            + "\nCycling,,,,3600,125,,2000,,,,\nYoga,,,,,,,,,,,\n"

        #expect(try workouts.csvString() == expected)
    }

    @Test func jsonExportsNormalisedSummariesAndOmitsMissingMetrics() throws {
        let parsed = try workouts
        let data = try parsed.jsonData()
        let rows = try objects(data)
        #expect(rows.count == 3)
        let running = rows[0]
        #expect(running["activityType"] as? String == "Running")
        #expect(running["sourceName"] as? String == "Watch, \"室\"")
        #expect(running["startDate"] as? String == "2026-04-18T21:00:00Z")
        #expect(running["endDate"] as? String == "2026-04-18T21:30:00Z")
        #expect(running["durationSeconds"] as? Double == 1800)
        #expect(running["activeEnergyKilocalories"] as? Double == 200)
        #expect(running["basalEnergyKilocalories"] as? Double == 1)
        #expect(running["distanceMetres"] as? Double == 5000)
        #expect(running["averageHeartRateBPM"] as? Double == 150.5)
        #expect(running["minimumHeartRateBPM"] as? Double == 100)
        #expect(running["maximumHeartRateBPM"] as? Double == 180)
        #expect(running["stepCount"] as? Double == 6200)
        #expect(running["statistics"] == nil)
        #expect(rows[1]["activeEnergyKilocalories"] as? Double == 125)
        #expect(rows[1]["distanceMetres"] as? Double == 2000)
        #expect(rows[2].count == 1)
        #expect(rows[2]["activityType"] as? String == "Yoga")
        #expect(try parsed.jsonData() == data)
    }

    // MARK: - Edge Cases

    @Test func missingMetricsStayDistinctFromMeasuredZero() throws {
        let parsed = [ParsedWorkout(activityType: "Missing"), ParsedWorkout(
            activityType: "Zero", duration: 0, totalEnergyBurned: 0, totalDistance: 0,
            statistics: [WorkoutStatistics(type: "HKQuantityTypeIdentifierStepCount", sum: 0)]
        )]
        let csv = parsed.csvString()
        #expect(csv.contains("Missing,,,,,,,,,,,\n"))
        #expect(csv.contains("Zero,,,,0,0,,0,,,,0\n"))
        let rows = try objects(parsed.jsonData())
        #expect(rows[0]["durationSeconds"] == nil)
        #expect(rows[1]["durationSeconds"] as? Double == 0)
        #expect(rows[1]["activeEnergyKilocalories"] as? Double == 0)
        #expect(rows[1]["distanceMetres"] as? Double == 0)
        #expect(rows[1]["stepCount"] as? Double == 0)
    }

    @Test func csvEscapesCommasQuotesAndLineBreaks() {
        let parsed = [ParsedWorkout(activityType: "Run, \"fast\"\r\n室", sourceName: "Watch\nPhone")]
        #expect(parsed.csvString().hasSuffix("\"Run, \"\"fast\"\"\r\n室\",\"Watch\nPhone\",,,,,,,,,,\n"))
    }

    @Test func emptyExportsHaveHeaderOrEmptyArray() throws {
        let parsed: [ParsedWorkout] = []
        #expect(parsed.csvString() == [ParsedWorkout].workoutSummaryCSVHeader + "\n")
        #expect(try objects(parsed.jsonData()).isEmpty)
    }

    @Test(arguments: [Double.infinity, -.infinity, .nan])
    func jsonRejectsNonFiniteMetrics(value: Double) {
        let parsed = [ParsedWorkout(activityType: "Run", duration: value)]
        #expect(throws: EncodingError.self) { try parsed.jsonData() }
    }

    // MARK: - File Writing

    @Test func writesAndReplacesCSVAndJSONFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let csvURL = directory.appendingPathComponent("workouts.csv")
        let jsonURL = directory.appendingPathComponent("workouts.json")
        try "old".write(to: csvURL, atomically: true, encoding: .utf8)
        try "old".write(to: jsonURL, atomically: true, encoding: .utf8)
        let parsed = try workouts
        try parsed.writeCSV(to: csvURL)
        try parsed.writeJSON(to: jsonURL)
        #expect(try String(contentsOf: csvURL, encoding: .utf8) == parsed.csvString())
        #expect(try Data(contentsOf: jsonURL) == parsed.jsonData())
    }

    @Test func fileWritingPropagatesMissingDirectoryErrors() {
        let missingDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let parsed = [ParsedWorkout(activityType: "Run")]
        #expect(throws: (any Error).self) {
            try parsed.writeCSV(to: missingDirectory.appendingPathComponent("workouts.csv"))
        }
        #expect(throws: (any Error).self) {
            try parsed.writeJSON(to: missingDirectory.appendingPathComponent("workouts.json"))
        }
    }
}
