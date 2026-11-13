import Foundation

// MARK: - WeeklyTrainingSummary Export

extension Array where Element == WeeklyTrainingSummary {

    /// CSV header shared by every exported file.
    public static var weeklyTrainingSummaryCSVHeader: String {
        "week_start,workout_count,duration_seconds,active_energy_kcal,distance_metres,"
            + "average_heart_rate,maximum_heart_rate,activity_counts"
    }

    /// Encode one row per week in array order, with ISO8601 dates and a final newline.
    /// Missing metrics are empty fields. Activity counts are a sorted JSON object
    /// inside a quoted CSV field, with embedded quotes escaped by doubling them.
    public func csvString() throws -> String {
        var lines = [Self.weeklyTrainingSummaryCSVHeader]
        let formatter = ISO8601DateFormatter()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        for summary in self {
            // JSONEncoder always produces valid UTF-8.
            let counts = String(data: try encoder.encode(summary.activityCounts), encoding: .utf8)!
            let countsField = "\"" + counts.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            lines.append([
                formatter.string(from: summary.weekStart),
                String(summary.workoutCount),
                Self.csvNumber(summary.totalDuration),
                Self.csvNumber(summary.totalActiveEnergyKilocalories),
                Self.csvNumber(summary.totalDistanceMetres),
                Self.csvNumber(summary.averageHeartRate),
                Self.csvNumber(summary.maximumHeartRate),
                countsField
            ].joined(separator: ","))
        }

        return lines.joined(separator: "\n") + "\n"
    }

    /// Encode pretty printed JSON with sorted keys and ISO8601 dates.
    /// Missing metrics are omitted, while measured zero remains zero.
    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    /// Write CSV to `url`, atomically creating or replacing the file.
    public func writeCSV(to url: URL) throws {
        try csvString().write(to: url, atomically: true, encoding: .utf8)
    }

    /// Write JSON to `url`, atomically creating or replacing the file.
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
