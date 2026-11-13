import Foundation

// MARK: - HealthActivitySummary Export

extension Array where Element == HealthActivitySummary {

    /// CSV columns, with energy in kilocalories and exercise time in minutes.
    public static var healthActivitySummaryCSVHeader: String {
        "date,active_energy_kcal,active_energy_goal_kcal,exercise_minutes,"
            + "exercise_goal_minutes,stand_hours,stand_goal_hours"
    }

    /// Encode one row per activity summary in array order, with a final newline.
    ///
    /// The exported day string is preserved without time zone conversion.
    /// Missing values and energy with unsupported units are empty fields;
    /// measured zero remains zero. Text containing CSV delimiters is quoted.
    public func csvString() -> String {
        var lines = [Self.healthActivitySummaryCSVHeader]
        for summary in self {
            lines.append([
                Self.csvText(summary.dateComponents ?? ""),
                Self.csvNumber(summary.activeEnergyKilocalories),
                Self.csvNumber(summary.activeEnergyGoalKilocalories),
                Self.csvNumber(summary.appleExerciseTime),
                Self.csvNumber(summary.appleExerciseTimeGoal),
                Self.csvNumber(summary.appleStandHours),
                Self.csvNumber(summary.appleStandHoursGoal)
            ].joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Encode pretty printed JSON with sorted keys, retaining raw energy and
    /// its unit for a lossless Codable round trip. Missing fields are omitted.
    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
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

    private static func csvText(_ value: String) -> String {
        guard value.rangeOfCharacter(from: CharacterSet(charactersIn: ",\"\r\n")) != nil else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
