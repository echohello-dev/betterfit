import Foundation
import Testing

import BetterFit

struct HealthActivitySummaryExportTests {

    // MARK: - Fixtures

    private var sample: [HealthActivitySummary] {
        [HealthActivitySummary(
            dateComponents: "2026-04-19",
            activeEnergyBurned: 2092,
            activeEnergyBurnedGoal: 2510.4,
            activeEnergyBurnedUnit: "kJ",
            appleExerciseTime: 42.5,
            appleExerciseTimeGoal: 30,
            appleStandHours: 13,
            appleStandHoursGoal: 12
        )]
    }

    // MARK: - CSV

    @Test func csvUsesExplicitUnitsAndPreservesCalendarDay() throws {
        let rows = sample.csvString().split(separator: "\n")
        #expect(rows[0] == "date,active_energy_kcal,active_energy_goal_kcal,exercise_minutes,"
            + "exercise_goal_minutes,stand_hours,stand_goal_hours")
        let fields = rows[1].split(separator: ",")
        #expect(fields[0] == "2026-04-19")
        #expect(try #require(Double(fields[1])) == 500)
        #expect(abs(try #require(Double(fields[2])) - 600) < 0.000001)
        #expect(Array(fields.suffix(4)) == ["42.5", "30", "13", "12"])
        #expect(sample.csvString().hasSuffix("\n"))
    }

    @Test func csvDistinguishesMissingValuesFromMeasuredZero() {
        let summaries = [
            HealthActivitySummary(),
            HealthActivitySummary(
                dateComponents: "2026-04-19", activeEnergyBurned: 0, activeEnergyBurnedGoal: 0,
                activeEnergyBurnedUnit: "kcal", appleExerciseTime: 0, appleExerciseTimeGoal: 0,
                appleStandHours: 0, appleStandHoursGoal: 0
            )
        ]
        let rows = summaries.csvString().split(separator: "\n")
        #expect(rows[1] == ",,,,,,")
        #expect(rows[2] == "2026-04-19,0,0,0,0,0,0")
    }

    @Test(arguments: [nil, "", "unknown"] as [String?])
    func csvLeavesUnsupportedEnergyEmpty(unit: String?) {
        let summaries = [HealthActivitySummary(
            dateComponents: "2026-04-19", activeEnergyBurned: 100, activeEnergyBurnedGoal: 200,
            activeEnergyBurnedUnit: unit, appleExerciseTime: 30
        )]
        #expect(summaries.csvString().split(separator: "\n")[1] == "2026-04-19,,,30,,,")
    }

    @Test func csvPreservesArrayOrderAndDuplicateDays() {
        let summaries = [
            HealthActivitySummary(dateComponents: "2026-04-20"),
            sample[0], sample[0]
        ]
        let rows = summaries.csvString().split(separator: "\n")
        #expect(rows.count == 4)
        #expect(rows[1] == "2026-04-20,,,,,,")
        #expect(rows[2].hasPrefix("2026-04-19,"))
        #expect(rows[2] == rows[3])
    }

    @Test(arguments: [",", "\"", "\r", "\n", "\r\n"])
    func csvEscapesTextContainingDelimiters(delimiter: String) {
        let text = "day\(delimiter)室"
        let summaries = [HealthActivitySummary(dateComponents: text)]
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        #expect(summaries.csvString() == [HealthActivitySummary].healthActivitySummaryCSVHeader
            + "\n\"\(escaped)\",,,,,,\n")
    }

    @Test func emptyExportsContainHeaderOrEmptyJSONArray() throws {
        let summaries: [HealthActivitySummary] = []
        #expect(summaries.csvString() == [HealthActivitySummary].healthActivitySummaryCSVHeader + "\n")
        #expect(try JSONDecoder().decode([HealthActivitySummary].self, from: summaries.jsonData()) == [])
    }

    // MARK: - JSON

    @Test func jsonRoundTripPreservesRawEnergyUnitsMissingValuesAndOrder() throws {
        let summaries = sample + [
            HealthActivitySummary(dateComponents: "2026-04-20", appleExerciseTime: 0),
            HealthActivitySummary(activeEnergyBurned: 100, activeEnergyBurnedUnit: "unknown")
        ]
        let data = try summaries.jsonData()
        #expect(try JSONDecoder().decode([HealthActivitySummary].self, from: data) == summaries)
        let objects = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        #expect(objects[0]["activeEnergyBurned"] as? Double == 2092)
        #expect(objects[0]["activeEnergyBurnedUnit"] as? String == "kJ")
        #expect(objects[0]["dateComponents"] as? String == "2026-04-19")
        #expect(objects[1]["activeEnergyBurned"] == nil)
        #expect(objects[1]["appleExerciseTime"] as? Double == 0)
    }

    @Test(arguments: [Double.nan, .infinity, -.infinity])
    func jsonRejectsNonFiniteValues(value: Double) {
        let summaries = [HealthActivitySummary(activeEnergyBurned: value)]
        #expect(throws: EncodingError.self) { try summaries.jsonData() }
    }

    // MARK: - Files

    @Test func writesAndReplacesCSVAndJSONFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let csvURL = directory.appendingPathComponent("activity.csv")
        let jsonURL = directory.appendingPathComponent("activity.json")
        try "old contents".write(to: csvURL, atomically: true, encoding: .utf8)
        try "old contents".write(to: jsonURL, atomically: true, encoding: .utf8)

        try sample.writeCSV(to: csvURL)
        try sample.writeJSON(to: jsonURL)

        #expect(try String(contentsOf: csvURL, encoding: .utf8) == sample.csvString())
        #expect(try JSONDecoder().decode([HealthActivitySummary].self, from: Data(contentsOf: jsonURL)) == sample)
    }

    @Test func fileWritingPropagatesErrors() {
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        #expect(throws: (any Error).self) { try sample.writeCSV(to: missing.appendingPathComponent("activity.csv")) }
        #expect(throws: (any Error).self) { try sample.writeJSON(to: missing.appendingPathComponent("activity.json")) }
    }

    // MARK: - XML to Export

    @Test func exportsParsedActivityRingsWithoutAddingRecordOrWorkoutEnergy() throws {
        let xml = """
            <HealthData locale="en_AU">
              <Record type="HKQuantityTypeIdentifierActiveEnergyBurned" value="100" unit="kcal"
                startDate="2026-04-19 07:00:00 +1000"/>
              <Workout workoutActivityType="Running" totalEnergyBurned="200" totalEnergyBurnedUnit="kcal"/>
              <ActivitySummary dateComponents="2026-04-19" activeEnergyBurned="2092"
                activeEnergyBurnedGoal="4184" activeEnergyBurnedUnit="kJ" appleExerciseTime="42.5"
                appleExerciseTimeGoal="30" appleStandHours="13" appleStandHoursGoal="12"/>
              <ActivitySummary dateComponents="2026-04-20" activeEnergyBurned="0" activeEnergyBurnedUnit="kcal"/>
              <ActivitySummary dateComponents="2026-04-21"/>
            </HealthData>
            """
        let export = try HealthExportParser.parseExport(xml: xml)
        let summaries = export.activitySummaries
        let rows = summaries.csvString().split(separator: "\n")
        #expect(rows.count == 4)
        #expect(rows[1] == "2026-04-19,500,1000,42.5,30,13,12")
        #expect(rows[2] == "2026-04-20,0,,,,,")
        #expect(rows[3] == "2026-04-21,,,,,,")
        #expect(export.dailySummaries().first?.activeEnergyKilocalories == 100)
        #expect(export.workouts.first?.activeEnergyKilocalories == 200)
        #expect(try JSONDecoder().decode([HealthActivitySummary].self, from: summaries.jsonData()) == summaries)
    }
}
