import Foundation
import Testing

import BetterFit

struct HealthRecordUnitValidationTests {

    // MARK: - Supported Units

    @Test(arguments: [
        ("ActiveEnergyBurned", "kcal", 4184.0),
        ("BasalEnergyBurned", "cal", 4184.0),
        ("ActiveEnergyBurned", "KJ", 1000.0),
        ("BasalEnergyBurned", "J", 1.0),
        ("DistanceWalkingRunning", "m", 4184.0),
        ("DistanceCycling", "KM", 4_184_000.0),
        ("DistanceWalkingRunning", "MI", 4184.0 * 1609.344),
        ("BodyMass", "kg", 4184.0),
        ("BodyMass", "G", 4.184),
        ("BodyMass", "LB", 4184.0 * 0.45359237)
    ])
    func supportedUnitsKeepExistingConversions(type: String, unit: String, expected: Double) throws {
        let record = HealthRecord(type: "HKQuantityTypeIdentifier" + type, unit: unit, value: 4184)
        let actual = try #require(record.valueKilocalories ?? record.valueMetres ?? record.valueKilograms)
        #expect(abs(actual - expected) < 0.000001)
    }

    @Test func omittedUnitsKeepCanonicalDefaults() throws {
        let records = try parseRecords(unit: nil, value: 42)
        #expect(records[0].valueKilocalories == 42)
        #expect(records[1].valueKilocalories == 42)
        #expect(records[2].valueMetres == 42)
        #expect(records[3].valueMetres == 42)
        #expect(records[4].valueKilograms == 42)
    }

    // MARK: - Unsupported Units

    @Test(arguments: ["unknown", "", "count"])
    func unsupportedUnitsPreserveRawRecordsWithoutNormalisedValues(unit: String) throws {
        let records = try parseRecords(unit: unit, value: 99)
        for record in records {
            #expect(record.value == 99)
            #expect(record.unit == unit)
            #expect(record.valueKilocalories == nil)
            #expect(record.valueMetres == nil)
            #expect(record.valueKilograms == nil)
        }
        let data = try JSONEncoder().encode(records)
        #expect(try JSONDecoder().decode([HealthRecord].self, from: data) == records)
    }

    @Test(arguments: ["unknown", "", "count"])
    func unsupportedUnitsStayMissingInDailySummariesAndExports(unit: String) throws {
        let summaries = HealthExport(records: try parseRecords(unit: unit, value: 99))
            .dailySummaries(calendar: utcCalendar)
        let day = try #require(summaries.first)
        #expect(day.activeEnergyKilocalories == nil)
        #expect(day.basalEnergyKilocalories == nil)
        #expect(day.distanceMetres == nil)
        #expect(day.bodyMassKilograms == nil)
        let row = try #require(summaries.csvString().split(separator: "\n").last)
        #expect(row == "2026-04-19T00:00:00Z,,,,,,,,")
        let json = try #require(JSONSerialization.jsonObject(with: summaries.jsonData()) as? [[String: Any]])
        #expect(json.first?.keys.sorted() == ["date"])
    }

    @Test(arguments: ["unknown", "", "count"])
    func unsupportedRecordsDoNotChangeValidTotalsOrReplaceLatestValidMass(unit: String) throws {
        let unsupported = try parseRecords(unit: unit, value: 99, hour: "09")
        let valid = try parseRecords(unit: nil, value: 42)
        for records in [valid + unsupported, unsupported + valid] {
            let day = try #require(HealthExport(records: records).dailySummaries(calendar: utcCalendar).first)
            #expect(day.activeEnergyKilocalories == 42)
            #expect(day.basalEnergyKilocalories == 42)
            #expect(day.distanceMetres == 84)
            #expect(day.bodyMassKilograms == 42)
            let expected = HealthExport(records: valid).dailySummaries(calendar: utcCalendar)
            #expect(try [day].jsonData() == expected.jsonData())
        }
    }

    @Test func measuredZeroRemainsZeroInSummariesAndExports() throws {
        let records = try parseRecords(unit: "unknown", value: 99) + parseRecords(unit: nil, value: 0)
        let summaries = HealthExport(records: records).dailySummaries(calendar: utcCalendar)
        let day = try #require(summaries.first)
        #expect(day.activeEnergyKilocalories == 0)
        #expect(day.basalEnergyKilocalories == 0)
        #expect(day.distanceMetres == 0)
        #expect(day.bodyMassKilograms == 0)
        let row = try #require(summaries.csvString().split(separator: "\n").last)
        #expect(row == "2026-04-19T00:00:00Z,,0,0,0,,,0,")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        #expect(try decoder.decode([DailyHealthSummary].self, from: summaries.jsonData()) == summaries)
    }

    // MARK: - Fixtures

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func parseRecords(unit: String?, value: Double, hour: String = "08") throws -> [HealthRecord] {
        let unitAttribute = unit.map { "unit=\"\($0)\"" } ?? ""
        let records = [
            "ActiveEnergyBurned", "BasalEnergyBurned", "DistanceWalkingRunning", "DistanceCycling", "BodyMass"
        ].map { type in
            """
            <Record type="HKQuantityTypeIdentifier\(type)" \(unitAttribute) value="\(value)"
              startDate="2026-04-19 \(hour):00:00 +0000"/>
            """
        }.joined(separator: "\n")
        return try HealthExportParser.parseRecords(xml: "<HealthData>\(records)</HealthData>")
    }
}
