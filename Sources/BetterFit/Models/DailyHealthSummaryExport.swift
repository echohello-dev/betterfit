import Foundation

// MARK: - DailyHealthSummary Export

extension Array where Element == DailyHealthSummary {

    /// CSV header shared by every exported file.
    public static var dailyHealthSummaryCSVHeader: String {
        "date,step_count,active_energy_kcal,basal_energy_kcal,distance_metres,"
            + "average_heart_rate,resting_heart_rate,body_mass_kg,sleep_duration_seconds"
    }

    /// Encode the summaries as CSV, one row per day in array order.
    ///
    /// Dates use ISO8601. Missing values are empty fields so a nil never
    /// reads as a measured zero. Rows end with a newline, including the last.
    public func csvString() -> String {
        var lines: [String] = [Self.dailyHealthSummaryCSVHeader]
        let formatter = ISO8601DateFormatter()
        for summary in self {
            lines.append(
                [
                    formatter.string(from: summary.date),
                    Self.csvNumber(summary.stepCount),
                    Self.csvNumber(summary.activeEnergyKilocalories),
                    Self.csvNumber(summary.basalEnergyKilocalories),
                    Self.csvNumber(summary.distanceMetres),
                    Self.csvNumber(summary.averageHeartRate),
                    Self.csvNumber(summary.restingHeartRate),
                    Self.csvNumber(summary.bodyMassKilograms),
                    Self.csvNumber(summary.sleepDuration)
                ].joined(separator: ",")
            )
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Encode the summaries as pretty printed JSON with sorted keys and
    /// ISO8601 dates. Decoding the result gives back the same summaries.
    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    /// Write the CSV form to `url`, creating or replacing the file.
    public func writeCSV(to url: URL) throws {
        try csvString().write(to: url, atomically: true, encoding: .utf8)
    }

    /// Write the JSON form to `url`, creating or replacing the file.
    public func writeJSON(to url: URL) throws {
        try jsonData().write(to: url, options: .atomic)
    }

    private static func csvNumber(_ value: Double?) -> String {
        guard let value else { return "" }
        if value == value.rounded(), abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(value)
    }
}
