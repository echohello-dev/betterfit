import Foundation
import Testing

@testable import BetterFit

struct HealthActivitySummaryTests {
    private let summaryXML = """
        <ActivitySummary dateComponents="2026-04-19"
          activeEnergyBurned="2092" activeEnergyBurnedGoal="2510.4" activeEnergyBurnedUnit="kJ"
          appleExerciseTime="42.5" appleExerciseTimeGoal="30"
          appleStandHours="13" appleStandHoursGoal="12"/>
        """

    @Test func parsesMixedExportWithoutDoubleCounting() throws {
        let xml = """
            <HealthData>
              <Record type="HKQuantityTypeIdentifierActiveEnergyBurned" value="100" unit="kcal"
                startDate="2026-04-19 07:00:00 +1000"/>
              <Workout workoutActivityType="HKWorkoutActivityTypeRunning" duration="30" durationUnit="min">
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate" average="140" unit="count/min"/>
              </Workout>
              \(summaryXML)
              <ActivitySummary dateComponents="2026-04-20" activeEnergyBurned="0"
                activeEnergyBurnedUnit="kcal"/>
            </HealthData>
            """
        let export = try HealthExportParser.parseExport(xml: xml)
        #expect(export.workouts.count == 1)
        #expect(export.workouts[0].averageHeartRate == 140)
        #expect(export.records.count == 1)
        #expect(export.dailySummaries().first?.activeEnergyKilocalories == 100)
        #expect(export.activitySummaries.count == 2)
        let summary = try #require(export.activitySummaries.first)
        #expect(summary.dateComponents == "2026-04-19")
        #expect(summary.activeEnergyBurned == 2092)
        #expect(summary.activeEnergyBurnedGoal == 2510.4)
        #expect(summary.activeEnergyBurnedUnit == "kJ")
        #expect(summary.activeEnergyKilocalories == 500)
        #expect(abs(try #require(summary.activeEnergyGoalKilocalories) - 600) < 0.0001)
        #expect(summary.appleExerciseTime == 42.5)
        #expect(summary.appleExerciseTimeGoal == 30)
        #expect(summary.appleStandHours == 13)
        #expect(summary.appleStandHoursGoal == 12)
        #expect(export.activitySummaries[1].dateComponents == "2026-04-20")
        #expect(export.activitySummaries[1].activeEnergyKilocalories == 0)
        #expect(try HealthExportParser.parseWorkouts(xml: xml).count == 1)
        #expect(try HealthExportParser.parseRecords(xml: xml).count == 1)
    }

    @Test func parsesDataAndRoundTripsJSON() throws {
        let xml = "<HealthData>\(summaryXML)</HealthData>"
        let export = try HealthExportParser.parseExport(data: Data(xml.utf8))
        #expect(try export == HealthExportParser.parseExport(xml: xml))
        let data = try JSONEncoder().encode(export)
        #expect(try JSONDecoder().decode(HealthExport.self, from: data) == export)
    }

    @Test func decodesExportsFromBeforeActivitySummaries() throws {
        let data = Data(#"{"workouts":[],"records":[]}"#.utf8)
        #expect(try JSONDecoder().decode(HealthExport.self, from: data) == HealthExport())
    }

    @Test func leavesMissingValuesNil() throws {
        let export = try HealthExportParser.parseExport(xml: "<HealthData><ActivitySummary/></HealthData>")
        #expect(export.activitySummaries == [HealthActivitySummary()])
        #expect(try HealthExportParser.parseExport(xml: "<HealthData/>").activitySummaries.isEmpty)
    }

    @Test(arguments: ["oops", "NaN", "inf", "-1", ""])
    func rejectsInvalidNumericValues(value: String) throws {
        let xml = """
            <HealthData><ActivitySummary dateComponents="2026-04-19"
              activeEnergyBurned="\(value)" activeEnergyBurnedGoal="\(value)"
              appleExerciseTime="\(value)" appleExerciseTimeGoal="\(value)"
              appleStandHours="\(value)" appleStandHoursGoal="\(value)"/>
            </HealthData>
            """
        let summaries = try HealthExportParser.parseExport(xml: xml).activitySummaries
        #expect(summaries == [HealthActivitySummary(dateComponents: "2026-04-19")])
    }

    @Test(arguments: ["kcal", "KCAL", "kJ", "J"])
    func normalisesSupportedEnergyUnits(unit: String) throws {
        let value: Double = switch unit.lowercased() {
        case "kj": 4.184
        case "j": 4184
        default: 1
        }
        let summary = HealthActivitySummary(
            activeEnergyBurned: value, activeEnergyBurnedGoal: value * 2, activeEnergyBurnedUnit: unit)
        #expect(abs(try #require(summary.activeEnergyKilocalories) - 1) < 0.0001)
        #expect(abs(try #require(summary.activeEnergyGoalKilocalories) - 2) < 0.0001)
    }

    @Test(arguments: [nil, "", "unknown"] as [String?])
    func preservesUnsupportedUnitsWithoutInventingKilocalories(unit: String?) {
        let summary = HealthActivitySummary(
            activeEnergyBurned: 100, activeEnergyBurnedGoal: 200, activeEnergyBurnedUnit: unit)
        #expect(summary.activeEnergyBurned == 100)
        #expect(summary.activeEnergyBurnedUnit == unit)
        #expect(summary.activeEnergyKilocalories == nil)
        #expect(summary.activeEnergyGoalKilocalories == nil)
    }

    @Test func rejectsMalformedXML() {
        #expect(throws: HealthExportParser.ParseError.self) {
            try HealthExportParser.parseExport(xml: "<HealthData><ActivitySummary")
        }
    }
}
