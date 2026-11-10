import Foundation
import Testing

import BetterFit

struct SleepSummaryTests {

    // MARK: - Categories

    @Test(arguments: [
        "HKCategoryValueSleepAnalysisAsleep",
        "HKCategoryValueSleepAnalysisAsleepUnspecified",
        "HKCategoryValueSleepAnalysisAsleepCore",
        "HKCategoryValueSleepAnalysisAsleepDeep",
        "HKCategoryValueSleepAnalysisAsleepREM",
        "1", "3", "4", "5"
    ])
    func countsRecognisedAsleepCategoriesFromXML(_ category: String) throws {
        let xml = """
            <HealthData>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="\(category)"
                startDate="2026-04-19 01:00:00 +0000" endDate="2026-04-19 02:00:00 +0000"/>
            </HealthData>
            """
        let summaries = try HealthExportParser.parseExport(xml: xml).dailySummaries(calendar: utcCalendar)
        #expect(summaries.first?.sleepDuration == 3600)
    }

    @Test(arguments: [
        "HKCategoryValueSleepAnalysisInBed", "HKCategoryValueSleepAnalysisAwake",
        "HKCategoryValueSleepAnalysisAsleepFuture", "unknown", "",
        "0", "2", "6", "-1", "3.5", "nan", "inf"
    ])
    func excludesNonAsleepAndUnknownCategoriesFromXML(_ category: String) throws {
        let xml = """
            <HealthData>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="\(category)"
                startDate="2026-04-19 01:00:00 +0000" endDate="2026-04-19 02:00:00 +0000"/>
            </HealthData>
            """
        let summaries = try HealthExportParser.parseExport(xml: xml).dailySummaries(calendar: utcCalendar)
        let day = try #require(summaries.first)
        #expect(day.sleepDuration == nil)
    }

    // MARK: - Intervals

    @Test
    func mergesUnsortedOverlappingNestedAndDuplicateIntervals() {
        let records = [
            sleep(start: 4, end: 6), sleep(start: 1, end: 3),
            sleep(start: 2, end: 5), sleep(start: 2, end: 3),
            sleep(start: 1, end: 3)
        ]
        // The union is 01:00 to 06:00, regardless of order or source duplication.
        #expect(sleepDuration(records) == 18_000)
        #expect(sleepDuration(Array(records.reversed())) == 18_000)
    }

    @Test
    func preservesGapsBetweenSeparateSleepPeriods() {
        #expect(sleepDuration([
            sleep(start: 1, end: 2), sleep(start: 2, end: 3),
            sleep(start: 4, end: 5), sleep(start: 14, end: 14.5)
        ]) == 3.5 * 3600)
    }

    @Test
    func ignoresInvalidAndIncompleteIntervals() {
        let invalid = [
            sleep(start: 3, end: 2), sleep(start: 2, end: 2),
            sleep(start: nil, end: 2), sleep(start: 1, end: nil),
            sleep(start: 1, end: 2, category: nil)
        ]
        #expect(sleepDuration(invalid) == nil)
        #expect(sleepDuration(invalid + [sleep(start: 4, end: 5)]) == 3600)
        #expect(HealthExport(records: [sleep(start: nil, end: 2)])
            .dailySummaries(calendar: utcCalendar).isEmpty)
    }

    @Test
    func keepsStartDayAllocationInTheSuppliedCalendar() {
        var calendar = utcCalendar
        calendar.timeZone = TimeZone(secondsFromGMT: 10 * 3600)!
        let records = [sleep(start: 13, end: 15), sleep(start: 15, end: 16)]
        let summaries = HealthExport(records: records).dailySummaries(calendar: calendar)
        // 13:00 UTC is 23:00 local. The whole first interval stays on its start day.
        #expect(summaries.map(\.date) == [date(hour: -10), date(hour: 14)])
        #expect(summaries.map(\.sleepDuration) == [7200, 3600])
    }

    // MARK: - End to End

    @Test
    func exportsFourHoursAsleepFromMixedOverlappingXMLRecords() throws {
        let xml = """
            <HealthData locale="en_AU">
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="HKCategoryValueSleepAnalysisInBed"
                startDate="2026-04-19 00:00:00 +0000" endDate="2026-04-19 09:00:00 +0000"/>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="HKCategoryValueSleepAnalysisAwake"
                startDate="2026-04-19 02:00:00 +0000" endDate="2026-04-19 03:00:00 +0000"/>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="HKCategoryValueSleepAnalysisAsleepCore"
                startDate="2026-04-19 01:00:00 +0000" endDate="2026-04-19 02:00:00 +0000"/>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="HKCategoryValueSleepAnalysisAsleepDeep"
                startDate="2026-04-19 03:00:00 +0000" endDate="2026-04-19 05:00:00 +0000"/>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="HKCategoryValueSleepAnalysisAsleep"
                sourceName="Second device"
                startDate="2026-04-19 03:30:00 +0000" endDate="2026-04-19 04:30:00 +0000"/>
              <Record type="HKCategoryTypeIdentifierSleepAnalysis" value="5"
                startDate="2026-04-19 05:00:00 +0000" endDate="2026-04-19 06:00:00 +0000"/>
            </HealthData>
            """
        let summaries = try HealthExportParser.parseExport(xml: xml).dailySummaries(calendar: utcCalendar)
        #expect(summaries.count == 1)
        #expect(summaries.first?.sleepDuration == 14400)
        #expect(summaries.csvString().contains("2026-04-19T00:00:00Z,,,,,,,,14400\n"))

        let data = try summaries.jsonData()
        let json = try #require(String(data: data, encoding: .utf8))
        #expect(json.contains("\"sleepDuration\" : 14400"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        #expect(try decoder.decode([DailyHealthSummary].self, from: data) == summaries)
    }

    // MARK: - Fixtures

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(hour: Double) -> Date {
        Date(timeIntervalSince1970: hour * 3600)
    }

    private func sleep(
        start: Double?, end: Double?, category: String? = "HKCategoryValueSleepAnalysisAsleepCore"
    ) -> HealthRecord {
        HealthRecord(
            type: "HKCategoryTypeIdentifierSleepAnalysis",
            startDate: start.map { date(hour: $0) },
            endDate: end.map { date(hour: $0) },
            categoryValue: category
        )
    }

    private func sleepDuration(_ records: [HealthRecord]) -> TimeInterval? {
        HealthExport(records: records).dailySummaries(calendar: utcCalendar).first?.sleepDuration
    }
}
