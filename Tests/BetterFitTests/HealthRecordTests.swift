import XCTest

@testable import BetterFit

final class HealthRecordTests: XCTestCase {

    // MARK: - Fixtures

    private let sampleXML = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<HealthData locale=\"en_AU\">",
        "  <Record type=\"HKQuantityTypeIdentifierStepCount\"",
        "    sourceName=\"iPhone\" sourceVersion=\"17.0\" unit=\"count\"",
        "    creationDate=\"2026-04-19 23:59:59 +1000\"",
        "    startDate=\"2026-04-19 00:00:00 +1000\"",
        "    endDate=\"2026-04-19 23:59:59 +1000\" value=\"8421\"/>",
        "  <Record type=\"HKQuantityTypeIdentifierHeartRate\"",
        "    sourceName=\"Apple Watch\" unit=\"count/min\"",
        "    startDate=\"2026-04-19 07:10:00 +1000\"",
        "    endDate=\"2026-04-19 07:10:00 +1000\" value=\"142\"/>",
        "  <Record type=\"HKQuantityTypeIdentifierBodyMass\"",
        "    sourceName=\"iPhone\" unit=\"kg\"",
        "    startDate=\"2026-04-19 06:00:00 +1000\"",
        "    endDate=\"2026-04-19 06:00:00 +1000\" value=\"81.5\"/>",
        "  <Record type=\"HKQuantityTypeIdentifierActiveEnergyBurned\"",
        "    sourceName=\"Apple Watch\" unit=\"kJ\"",
        "    startDate=\"2026-04-19 07:00:00 +1000\"",
        "    endDate=\"2026-04-19 08:00:00 +1000\" value=\"2092\"/>",
        "  <Record type=\"HKQuantityTypeIdentifierDistanceWalkingRunning\"",
        "    sourceName=\"iPhone\" unit=\"mi\"",
        "    startDate=\"2026-04-19 00:00:00 +1000\"",
        "    endDate=\"2026-04-19 23:59:59 +1000\" value=\"1\"/>",
        "  <Record type=\"HKCategoryTypeIdentifierSleepAnalysis\"",
        "    sourceName=\"Apple Watch\"",
        "    startDate=\"2026-04-18 23:00:00 +1000\"",
        "    endDate=\"2026-04-19 06:30:00 +1000\"",
        "    value=\"HKCategoryValueSleepAnalysisAsleepCore\"/>",
        "  <Workout workoutActivityType=\"HKWorkoutActivityTypeRunning\"",
        "    duration=\"30\" durationUnit=\"min\"",
        "    startDate=\"2026-04-19 07:00:00 +1000\"",
        "    endDate=\"2026-04-19 07:30:00 +1000\"/>",
        "</HealthData>"
    ].joined(separator: "\n")

    // MARK: - Parsing

    func testParsesTopLevelRecords() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        XCTAssertEqual(records.count, 6)
        XCTAssertEqual(records[0].kind, .stepCount)
        XCTAssertEqual(records[0].value ?? 0, 8421, accuracy: 0.001)
        XCTAssertEqual(records[0].sourceName, "iPhone")
        XCTAssertEqual(records[0].sourceVersion, "17.0")
        XCTAssertEqual(records[0].unit, "count")
        XCTAssertNotNil(records[0].startDate)
        XCTAssertNotNil(records[0].creationDate)
    }

    func testQuantityRecordHasNoCategoryValue() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        XCTAssertNil(records[0].categoryValue)
    }

    func testSleepRecordKeepsCategoryValueAndDuration() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        let sleep = try XCTUnwrap(records.first { $0.kind == .sleepAnalysis })
        XCTAssertNil(sleep.value)
        XCTAssertEqual(sleep.categoryValue, "HKCategoryValueSleepAnalysisAsleepCore")
        // 23:00 to 06:30 is 7.5 hours
        XCTAssertEqual(sleep.duration ?? 0, 27000, accuracy: 0.001)
    }

    func testParseExportReturnsWorkoutsAndRecordsTogether() throws {
        let export = try HealthExportParser.parseExport(xml: sampleXML)
        XCTAssertEqual(export.workouts.count, 1)
        XCTAssertEqual(export.workouts[0].activityType, "HKWorkoutActivityTypeRunning")
        XCTAssertEqual(export.records.count, 6)
        XCTAssertEqual(export.records(of: .heartRate).count, 1)
        XCTAssertEqual(export.records(of: .stepCount).first?.value ?? 0, 8421, accuracy: 0.001)
    }

    func testParseWorkoutsStillSkipsRecordsAsWorkouts() throws {
        let workouts = try HealthExportParser.parseWorkouts(xml: sampleXML)
        XCTAssertEqual(workouts.count, 1)
    }

    // MARK: - Normalised Values

    func testEnergyNormalisationFromKilojoules() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        let energy = try XCTUnwrap(records.first { $0.kind == .activeEnergy })
        // 2092 kJ is 500 kcal
        XCTAssertEqual(energy.valueKilocalories ?? 0, 500, accuracy: 0.001)
    }

    func testDistanceNormalisationFromMiles() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        let distance = try XCTUnwrap(records.first { $0.kind == .distanceWalkingRunning })
        XCTAssertEqual(distance.valueMetres ?? 0, 1609.344, accuracy: 0.001)
    }

    func testBodyMassInKilogramsAndPounds() throws {
        let records = try HealthExportParser.parseRecords(xml: sampleXML)
        let mass = try XCTUnwrap(records.first { $0.kind == .bodyMass })
        XCTAssertEqual(mass.valueKilograms ?? 0, 81.5, accuracy: 0.001)

        let pounds = HealthRecord(
            type: "HKQuantityTypeIdentifierBodyMass", unit: "lb", value: 100)
        XCTAssertEqual(pounds.valueKilograms ?? 0, 45.359237, accuracy: 0.001)
    }

    func testNormalisedValuesNilForWrongKind() {
        let steps = HealthRecord(
            type: "HKQuantityTypeIdentifierStepCount", unit: "count", value: 100)
        XCTAssertNil(steps.valueKilocalories)
        XCTAssertNil(steps.valueMetres)
        XCTAssertNil(steps.valueKilograms)
    }

    // MARK: - Edge Cases

    func testPreservesUnknownRecordType() throws {
        let xml = """
            <HealthData>
              <Record type="HKQuantityTypeIdentifierVO2Max" sourceName="Apple Watch"
                unit="mL/min/kg" value="42"
                startDate="2026-04-19 07:00:00 +1000"
                endDate="2026-04-19 07:00:00 +1000"/>
            </HealthData>
            """
        let records = try HealthExportParser.parseRecords(xml: xml)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].kind, .other("HKQuantityTypeIdentifierVO2Max"))
        XCTAssertEqual(records[0].value ?? 0, 42, accuracy: 0.001)
    }

    func testEmptyExportReturnsNoRecords() throws {
        let xml = "<HealthData locale=\"en_AU\"></HealthData>"
        XCTAssertEqual(try HealthExportParser.parseRecords(xml: xml).count, 0)
        let export = try HealthExportParser.parseExport(xml: xml)
        XCTAssertTrue(export.workouts.isEmpty)
        XCTAssertTrue(export.records.isEmpty)
    }

    func testMalformedXMLThrowsForRecords() {
        let broken = "<HealthData><Record"
        XCTAssertThrowsError(try HealthExportParser.parseRecords(xml: broken)) { error in
            guard case HealthExportParser.ParseError.malformedXML = error else {
                return XCTFail("expected malformedXML, got \(error)")
            }
        }
    }

    func testRecordsFromDataAPI() throws {
        let data = Data(sampleXML.utf8)
        XCTAssertEqual(try HealthExportParser.parseRecords(data: data).count, 6)
        XCTAssertEqual(try HealthExportParser.parseExport(data: data).records.count, 6)
    }

    func testCodableRoundTrip() throws {
        let export = try HealthExportParser.parseExport(xml: sampleXML)
        let data = try JSONEncoder().encode(export)
        let decoded = try JSONDecoder().decode(HealthExport.self, from: data)
        XCTAssertEqual(decoded, export)
    }
}
