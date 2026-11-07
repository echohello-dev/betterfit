import XCTest

@testable import BetterFit

final class WorkoutStatisticsTests: XCTestCase {

    // MARK: - Fixtures

    private let sampleXML = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<HealthData locale=\"en_AU\">",
        "  <ExportDate value=\"2026-04-19 12:00:00 +1000\"/>",
        "  <Record type=\"HKQuantityTypeIdentifierStepCount\"",
        "    sourceName=\"iPhone\" value=\"8000\" unit=\"count\"",
        "    startDate=\"2026-04-19 00:00:00 +1000\"",
        "    endDate=\"2026-04-19 23:59:59 +1000\"/>",
        "  <Workout",
        "    workoutActivityType=\"HKWorkoutActivityTypeTraditionalStrengthTraining\"",
        "    duration=\"62.5\" durationUnit=\"min\"",
        "    totalDistance=\"0\" totalDistanceUnit=\"km\"",
        "    totalEnergyBurned=\"320.5\" totalEnergyBurnedUnit=\"kcal\"",
        "    sourceName=\"Apple Watch\" sourceVersion=\"10.0\"",
        "    creationDate=\"2026-04-19 08:00:00 +1000\"",
        "    startDate=\"2026-04-19 07:00:00 +1000\"",
        "    endDate=\"2026-04-19 08:02:30 +1000\">",
        "    <MetadataEntry key=\"HKIndoorWorkout\" value=\"0\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierActiveEnergyBurned\"",
        "      startDate=\"2026-04-19 07:00:00 +1000\"",
        "      endDate=\"2026-04-19 08:02:30 +1000\" sum=\"320.5\" unit=\"kcal\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierBasalEnergyBurned\"",
        "      startDate=\"2026-04-19 07:00:00 +1000\"",
        "      endDate=\"2026-04-19 08:02:30 +1000\" sum=\"82.1\" unit=\"kcal\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierHeartRate\"",
        "      startDate=\"2026-04-19 07:00:00 +1000\"",
        "      endDate=\"2026-04-19 08:02:30 +1000\"",
        "      average=\"142\" minimum=\"98\" maximum=\"168\" unit=\"count/min\"/>",
        "  </Workout>",
        "  <Workout",
        "    workoutActivityType=\"HKWorkoutActivityTypeRunning\"",
        "    duration=\"30\" durationUnit=\"min\"",
        "    totalDistance=\"5\" totalDistanceUnit=\"km\"",
        "    totalEnergyBurned=\"300\" totalEnergyBurnedUnit=\"kcal\"",
        "    sourceName=\"Apple Watch\"",
        "    creationDate=\"2026-04-18 07:35:00 +1000\"",
        "    startDate=\"2026-04-18 07:00:00 +1000\"",
        "    endDate=\"2026-04-18 07:30:00 +1000\">",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierActiveEnergyBurned\"",
        "      startDate=\"2026-04-18 07:00:00 +1000\"",
        "      endDate=\"2026-04-18 07:30:00 +1000\" sum=\"295\" unit=\"kcal\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierDistanceWalkingRunning\"",
        "      startDate=\"2026-04-18 07:00:00 +1000\"",
        "      endDate=\"2026-04-18 07:30:00 +1000\" sum=\"5.02\" unit=\"km\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierHeartRate\"",
        "      startDate=\"2026-04-18 07:00:00 +1000\"",
        "      endDate=\"2026-04-18 07:30:00 +1000\"",
        "      average=\"155\" minimum=\"105\" maximum=\"178\" unit=\"count/min\"/>",
        "    <WorkoutStatistics",
        "      type=\"HKQuantityTypeIdentifierStepCount\"",
        "      startDate=\"2026-04-18 07:00:00 +1000\"",
        "      endDate=\"2026-04-18 07:30:00 +1000\" sum=\"6200\" unit=\"count\"/>",
        "  </Workout>",
        "</HealthData>"
    ].joined(separator: "\n")

    // MARK: - Parsing

    func testParsesWorkoutsAndSkipsRecords() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        XCTAssertEqual(workouts.count, 2)
        XCTAssertEqual(workouts[0].activityType, "HKWorkoutActivityTypeTraditionalStrengthTraining")
        XCTAssertEqual(workouts[1].activityType, "HKWorkoutActivityTypeRunning")
    }

    func testParsesWorkoutMetadataAndDuration() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let strength = workouts[0]
        XCTAssertEqual(strength.sourceName, "Apple Watch")
        XCTAssertEqual(strength.sourceVersion, "10.0")
        // 62.5 min normalised to seconds
        XCTAssertEqual(strength.duration ?? 0, 3750, accuracy: 0.001)
        XCTAssertNotNil(strength.startDate)
        XCTAssertNotNil(strength.endDate)
        XCTAssertNotNil(strength.creationDate)
    }

    func testParsesChildStatisticsCountAndTypes() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        XCTAssertEqual(workouts[0].statistics.count, 3)
        XCTAssertEqual(workouts[1].statistics.count, 4)
        XCTAssertEqual(workouts[0].statistics.map(\.kind), [.activeEnergy, .basalEnergy, .heartRate])
    }

    // MARK: - Per-Workout Summaries

    func testEnergySummariesFromStatistics() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let strength = workouts[0]
        XCTAssertEqual(strength.activeEnergyKilocalories ?? 0, 320.5, accuracy: 0.001)
        XCTAssertEqual(strength.basalEnergyKilocalories ?? 0, 82.1, accuracy: 0.001)
    }

    func testHeartRateSummary() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let run = workouts[1]
        XCTAssertEqual(run.averageHeartRate ?? 0, 155, accuracy: 0.001)
        XCTAssertEqual(run.minimumHeartRate ?? 0, 105, accuracy: 0.001)
        XCTAssertEqual(run.maximumHeartRate ?? 0, 178, accuracy: 0.001)
    }

    func testDistanceSummaryPrefersStatisticOverTotal() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let run = workouts[1]
        // Statistic is 5.02 km, workout total is 5 km. Statistic wins.
        XCTAssertEqual(run.distanceMetres ?? 0, 5020, accuracy: 0.001)
        XCTAssertEqual(run.distanceKilometres ?? 0, 5.02, accuracy: 0.001)
    }

    func testStepCountSummary() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        XCTAssertEqual(workouts[1].stepCount ?? 0, 6200, accuracy: 0.001)
        XCTAssertNil(workouts[0].stepCount)
    }

    func testFallsBackToWorkoutTotalsWhenStatisticsAbsent() throws {
        let xml = """
            <HealthData>
              <Workout workoutActivityType="HKWorkoutActivityTypeCycling"
                duration="3600" durationUnit="sec"
                totalDistance="20000" totalDistanceUnit="m"
                totalEnergyBurned="500" totalEnergyBurnedUnit="kcal"
                startDate="2026-04-19 07:00:00 +1000"
                endDate="2026-04-19 08:00:00 +1000"/>
            </HealthData>
            """
        let workouts = try HealthExportParser.parseWorkouts(xml: xml)
        XCTAssertEqual(workouts.count, 1)
        XCTAssertEqual(workouts[0].activeEnergyKilocalories ?? 0, 500, accuracy: 0.001)
        XCTAssertEqual(workouts[0].distanceMetres ?? 0, 20000, accuracy: 0.001)
        XCTAssertNil(workouts[0].averageHeartRate)
    }

    // MARK: - Edge Cases

    func testWorkoutWithoutStatisticsHasNilSummaries() throws {
        let xml = """
            <HealthData>
              <Workout workoutActivityType="HKWorkoutActivityTypeYoga"
                duration="45" durationUnit="min"
                startDate="2026-04-19 07:00:00 +1000"
                endDate="2026-04-19 07:45:00 +1000"/>
            </HealthData>
            """
        let workouts = try HealthExportParser.parseWorkouts(xml: xml)
        XCTAssertEqual(workouts.count, 1)
        XCTAssertTrue(workouts[0].statistics.isEmpty)
        XCTAssertNil(workouts[0].activeEnergyKilocalories)
        XCTAssertNil(workouts[0].distanceMetres)
        XCTAssertNil(workouts[0].averageHeartRate)
        XCTAssertEqual(workouts[0].duration ?? 0, 2700, accuracy: 0.001)
    }

    func testPreservesUnknownStatisticType() throws {
        let xml = """
            <HealthData>
              <Workout workoutActivityType="HKWorkoutActivityTypeRunning"
                duration="10" durationUnit="min"
                startDate="2026-04-19 07:00:00 +1000"
                endDate="2026-04-19 07:10:00 +1000">
                <WorkoutStatistics type="HKQuantityTypeIdentifierVO2Max"
                  sum="42" unit="mL/min/kg"
                  startDate="2026-04-19 07:00:00 +1000"
                  endDate="2026-04-19 07:10:00 +1000"/>
              </Workout>
            </HealthData>
            """
        let workouts = try HealthExportParser.parseWorkouts(xml: xml)
        XCTAssertEqual(workouts[0].statistics.count, 1)
        XCTAssertEqual(workouts[0].statistics[0].kind, .other("HKQuantityTypeIdentifierVO2Max"))
        XCTAssertEqual(workouts[0].statistics[0].sum ?? 0, 42, accuracy: 0.001)
    }

    func testEmptyExportReturnsNoWorkouts() throws {
        let xml = "<HealthData locale=\"en_AU\"></HealthData>"
        XCTAssertEqual(try HealthExportParser.parseWorkouts(xml: xml).count, 0)
    }

    func testMalformedXMLThrows() {
        let broken = "<HealthData><Workout"
        XCTAssertThrowsError(try HealthExportParser.parseWorkouts(xml: broken)) { error in
            guard case HealthExportParser.ParseError.malformedXML = error else {
                return XCTFail("expected malformedXML, got \(error)")
            }
        }
    }

    func testHeartRateStatisticKeepsUnitAndDates() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let heartRate = workouts[0].statistic(for: .heartRate)
        XCTAssertEqual(heartRate?.unit, "count/min")
        XCTAssertNotNil(heartRate?.startDate)
        XCTAssertNotNil(heartRate?.endDate)
    }

    // MARK: - Statistic Normalisation

    func testDistanceNormalisationFromMilesAndKilojoules() {
        let distance = WorkoutStatistics(
            type: "HKQuantityTypeIdentifierDistanceWalkingRunning", sum: 1, unit: "mi")
        XCTAssertEqual(distance.sumMetres ?? 0, 1609.344, accuracy: 0.001)

        let energy = WorkoutStatistics(
            type: "HKQuantityTypeIdentifierActiveEnergyBurned", sum: 418.4, unit: "kJ")
        XCTAssertEqual(energy.sumKilocalories ?? 0, 100, accuracy: 0.001)
    }

    func testCodableRoundTrip() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        let data = try JSONEncoder().encode(workouts)
        let decoded = try JSONDecoder().decode([ParsedWorkout].self, from: data)
        XCTAssertEqual(decoded, workouts)
    }
}
