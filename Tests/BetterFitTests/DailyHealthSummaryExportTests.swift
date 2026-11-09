import XCTest

@testable import BetterFit

final class DailyHealthSummaryExportTests: XCTestCase {

    // MARK: - Fixtures

    private func date(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)!
    }

    private var sample: [DailyHealthSummary] {
        [
            DailyHealthSummary(
                date: date("2026-04-19T00:00:00Z"),
                stepCount: 8000,
                activeEnergyKilocalories: 450.5,
                basalEnergyKilocalories: 1600,
                distanceMetres: 5200,
                averageHeartRate: 82.5,
                restingHeartRate: 58,
                bodyMassKilograms: 72.5,
                sleepDuration: 25200
            ),
            DailyHealthSummary(date: date("2026-04-20T00:00:00Z"), stepCount: 1200)
        ]
    }

    // MARK: - CSV

    func testCSVHeaderAndRows() {
        let csv = sample.csvString()
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: false)
        XCTAssertEqual(
            String(lines[0]),
            "date,step_count,active_energy_kcal,basal_energy_kcal,distance_metres,"
                + "average_heart_rate,resting_heart_rate,body_mass_kg,sleep_duration_seconds"
        )
        XCTAssertEqual(
            String(lines[1]),
            "2026-04-19T00:00:00Z,8000,450.5,1600,5200,82.5,58,72.5,25200"
        )
        XCTAssertTrue(csv.hasSuffix("\n"))
    }

    func testCSVEmptyFieldsForMissingValues() {
        let csv = sample.csvString()
        let lines = csv.split(separator: "\n")
        XCTAssertEqual(String(lines[2]), "2026-04-20T00:00:00Z,1200,,,,,,,")
    }

    func testCSVEmptyArrayIsHeaderOnly() {
        XCTAssertEqual(
            [DailyHealthSummary]().csvString(),
            [DailyHealthSummary].dailyHealthSummaryCSVHeader + "\n"
        )
    }

    func testCSVPreservesArrayOrder() {
        let csv = Array(sample.reversed()).csvString()
        let lines = csv.split(separator: "\n")
        XCTAssertTrue(String(lines[1]).hasPrefix("2026-04-20"))
        XCTAssertTrue(String(lines[2]).hasPrefix("2026-04-19"))
    }

    // MARK: - JSON

    func testJSONRoundTrip() throws {
        let data = try sample.jsonData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([DailyHealthSummary].self, from: data)
        XCTAssertEqual(decoded, sample)
    }

    func testJSONUsesISO8601DatesAndSortedKeys() throws {
        let json = String(data: try sample.jsonData(), encoding: .utf8)!
        XCTAssertTrue(json.contains("\"2026-04-19T00:00:00Z\""))
        // Sorted keys put activeEnergyKilocalories before date in each object.
        let firstActive = json.range(of: "activeEnergyKilocalories")!.lowerBound
        let firstDate = json.range(of: "\"date\"")!.lowerBound
        XCTAssertTrue(firstActive < firstDate)
    }

    func testJSONEmptyArray() throws {
        let data = try [DailyHealthSummary]().jsonData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        XCTAssertEqual(try decoder.decode([DailyHealthSummary].self, from: data), [])
    }

    // MARK: - File Writing

    func testWriteCSVAndJSONToDisk() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let csvURL = dir.appendingPathComponent("daily.csv")
        try sample.writeCSV(to: csvURL)
        XCTAssertEqual(try String(contentsOf: csvURL, encoding: .utf8), sample.csvString())

        let jsonURL = dir.appendingPathComponent("daily.json")
        try sample.writeJSON(to: jsonURL)
        XCTAssertEqual(try Data(contentsOf: jsonURL), try sample.jsonData())
    }

    // MARK: - End to End

    func testExportFromParsedExport() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <HealthData locale="en_AU">
              <Record type="HKQuantityTypeIdentifierStepCount" unit="count" \
            value="3000" startDate="2026-04-19 08:00:00 +0000" endDate="2026-04-19 09:00:00 +0000"/>
            </HealthData>
            """
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let summaries = try HealthExportParser.parseExport(xml: xml)
            .dailySummaries(calendar: calendar)
        XCTAssertEqual(summaries.count, 1)
        XCTAssertTrue(summaries.csvString().contains("2026-04-19T00:00:00Z,3000"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(
            [DailyHealthSummary].self,
            from: summaries.jsonData()
        )
        XCTAssertEqual(decoded, summaries)
    }
}
