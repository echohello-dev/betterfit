import XCTest

@testable import BetterFit

final class DailyHealthSummaryTests: XCTestCase {

    // MARK: - Fixtures

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string)!
    }

    private func record(
        _ type: String,
        unit: String? = nil,
        start: String,
        end: String? = nil,
        value: Double? = nil,
        categoryValue: String? = nil
    ) -> HealthRecord {
        HealthRecord(
            type: type,
            unit: unit,
            startDate: date(start),
            endDate: date(end ?? start),
            value: value,
            categoryValue: categoryValue
        )
    }

    private func export(_ records: [HealthRecord]) -> HealthExport {
        HealthExport(workouts: [], records: records)
    }

    // MARK: - Grouping

    func testGroupsRecordsByDayAndSorts() {
        let summaries = export([
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-20 09:00:00", value: 100),
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-19 09:00:00", value: 200)
        ]).dailySummaries(calendar: utcCalendar)

        XCTAssertEqual(summaries.count, 2)
        XCTAssertEqual(summaries[0].date, date("2026-04-19 00:00:00"))
        XCTAssertEqual(summaries[0].stepCount ?? 0, 200, accuracy: 0.001)
        XCTAssertEqual(summaries[1].stepCount ?? 0, 100, accuracy: 0.001)
    }

    func testEmptyExportReturnsNoSummaries() {
        XCTAssertTrue(export([]).dailySummaries(calendar: utcCalendar).isEmpty)
    }

    func testRecordsWithoutStartDateAreSkipped() {
        let undated = HealthRecord(type: "HKQuantityTypeIdentifierStepCount", unit: "count", value: 500)
        XCTAssertTrue(export([undated]).dailySummaries(calendar: utcCalendar).isEmpty)
    }

    // MARK: - Totals

    func testSumsStepsEnergyAndDistanceWithNormalisation() throws {
        let summaries = export([
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-19 08:00:00", value: 4000),
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-19 12:00:00", value: 4421),
            record(
                "HKQuantityTypeIdentifierActiveEnergyBurned", unit: "kJ",
                start: "2026-04-19 08:00:00", value: 2092),
            record(
                "HKQuantityTypeIdentifierBasalEnergyBurned", unit: "kcal",
                start: "2026-04-19 08:00:00", value: 1600),
            record(
                "HKQuantityTypeIdentifierDistanceWalkingRunning", unit: "km",
                start: "2026-04-19 08:00:00", value: 2),
            record(
                "HKQuantityTypeIdentifierDistanceCycling", unit: "m",
                start: "2026-04-19 09:00:00", value: 500)
        ]).dailySummaries(calendar: utcCalendar)

        let day = try XCTUnwrap(summaries.first)
        XCTAssertEqual(day.stepCount ?? 0, 8421, accuracy: 0.001)
        // 2092 kJ is 500 kcal
        XCTAssertEqual(day.activeEnergyKilocalories ?? 0, 500, accuracy: 0.001)
        XCTAssertEqual(day.basalEnergyKilocalories ?? 0, 1600, accuracy: 0.001)
        XCTAssertEqual(day.distanceMetres ?? 0, 2500, accuracy: 0.001)
    }

    func testMissingKindsStayNil() throws {
        let summaries = export([
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-19 08:00:00", value: 10)
        ]).dailySummaries(calendar: utcCalendar)

        let day = try XCTUnwrap(summaries.first)
        XCTAssertNil(day.activeEnergyKilocalories)
        XCTAssertNil(day.averageHeartRate)
        XCTAssertNil(day.sleepDuration)
        XCTAssertNil(day.bodyMassKilograms)
    }

    // MARK: - Heart Rate and Body Mass

    func testAverageHeartRateAndLatestRestingAndMass() throws {
        let summaries = export([
            record("HKQuantityTypeIdentifierHeartRate", unit: "count/min", start: "2026-04-19 07:00:00", value: 100),
            record("HKQuantityTypeIdentifierHeartRate", unit: "count/min", start: "2026-04-19 08:00:00", value: 140),
            record(
                "HKQuantityTypeIdentifierRestingHeartRate", unit: "count/min",
                start: "2026-04-19 06:00:00", value: 62),
            record(
                "HKQuantityTypeIdentifierRestingHeartRate", unit: "count/min",
                start: "2026-04-19 22:00:00", value: 58),
            record("HKQuantityTypeIdentifierBodyMass", unit: "kg", start: "2026-04-19 06:00:00", value: 82),
            record("HKQuantityTypeIdentifierBodyMass", unit: "lb", start: "2026-04-19 21:00:00", value: 180)
        ]).dailySummaries(calendar: utcCalendar)

        let day = try XCTUnwrap(summaries.first)
        XCTAssertEqual(day.averageHeartRate ?? 0, 120, accuracy: 0.001)
        XCTAssertEqual(day.restingHeartRate ?? 0, 58, accuracy: 0.001)
        // 180 lb is 81.6466 kg, and it is the later sample
        XCTAssertEqual(day.bodyMassKilograms ?? 0, 81.6466, accuracy: 0.001)
    }

    // MARK: - Sleep

    func testSleepDurationSumsStagesStartingThatDay() throws {
        let summaries = export([
            record(
                "HKCategoryTypeIdentifierSleepAnalysis", start: "2026-04-19 01:00:00",
                end: "2026-04-19 04:00:00", categoryValue: "HKCategoryValueSleepAnalysisAsleepCore"),
            record(
                "HKCategoryTypeIdentifierSleepAnalysis", start: "2026-04-19 04:00:00",
                end: "2026-04-19 06:00:00", categoryValue: "HKCategoryValueSleepAnalysisAsleepDeep")
        ]).dailySummaries(calendar: utcCalendar)

        let day = try XCTUnwrap(summaries.first)
        // 3 hours plus 2 hours
        XCTAssertEqual(day.sleepDuration ?? 0, 18000, accuracy: 0.001)
    }

    // MARK: - End to End

    func testDailySummariesFromParsedExport() throws {
        let xml = """
            <HealthData locale="en_AU">
              <Record type="HKQuantityTypeIdentifierStepCount" sourceName="iPhone"
                unit="count" value="8421"
                startDate="2026-04-19 00:00:00 +0000" endDate="2026-04-19 23:59:59 +0000"/>
              <Record type="HKQuantityTypeIdentifierStepCount" sourceName="iPhone"
                unit="count" value="1000"
                startDate="2026-04-20 00:00:00 +0000" endDate="2026-04-20 23:59:59 +0000"/>
            </HealthData>
            """
        let parsed = try HealthExportParser.parseExport(xml: xml)
        let summaries = parsed.dailySummaries(calendar: utcCalendar)
        XCTAssertEqual(summaries.count, 2)
        XCTAssertEqual(summaries[0].stepCount ?? 0, 8421, accuracy: 0.001)
        XCTAssertEqual(summaries[1].stepCount ?? 0, 1000, accuracy: 0.001)
    }

    func testCodableRoundTrip() throws {
        let summaries = export([
            record("HKQuantityTypeIdentifierStepCount", unit: "count", start: "2026-04-19 08:00:00", value: 10)
        ]).dailySummaries(calendar: utcCalendar)
        let data = try JSONEncoder().encode(summaries)
        let decoded = try JSONDecoder().decode([DailyHealthSummary].self, from: data)
        XCTAssertEqual(decoded, summaries)
    }
}
