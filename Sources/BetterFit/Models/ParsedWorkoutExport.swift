import Foundation

// MARK: - ParsedWorkout Export

extension Array where Element == ParsedWorkout {

    /// CSV columns with explicit units for normalised workout measurements.
    public static var workoutSummaryCSVHeader: String {
        "activity_type,source_name,start_date,end_date,duration_seconds,active_energy_kcal,"
            + "basal_energy_kcal,distance_metres,average_heart_rate_bpm,minimum_heart_rate_bpm,"
            + "maximum_heart_rate_bpm,step_count"
    }

    /// Export one summary per workout in array order, including undated workouts.
    /// Dates use UTC ISO8601. Missing values are blank, measured zero stays zero,
    /// and text containing commas, quotes or line breaks is quoted and escaped.
    /// The output ends with a newline, including for an empty array.
    public func csvString() -> String {
        let formatter = ISO8601DateFormatter()
        let rows = map { WorkoutExportRow($0).csvFields(formatter: formatter).joined(separator: ",") }
        return ([Self.workoutSummaryCSVHeader] + rows).joined(separator: "\n") + "\n"
    }

    /// Export normalised summaries as pretty printed JSON with sorted keys and
    /// UTC ISO8601 dates. Missing metrics are omitted. Raw child statistics are
    /// excluded; encode `ParsedWorkout` directly to retain the original data.
    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(map(WorkoutExportRow.init))
    }

    /// Atomically create or replace a CSV file.
    public func writeCSV(to url: URL) throws {
        try csvString().write(to: url, atomically: true, encoding: .utf8)
    }

    /// Atomically create or replace a JSON file.
    public func writeJSON(to url: URL) throws {
        try jsonData().write(to: url, options: .atomic)
    }
}

// MARK: - Export Row

private struct WorkoutExportRow: Encodable {
    let activityType: String
    let sourceName: String?
    let startDate: Date?
    let endDate: Date?
    let durationSeconds: Double?
    let activeEnergyKilocalories: Double?
    let basalEnergyKilocalories: Double?
    let distanceMetres: Double?
    let averageHeartRateBPM: Double?
    let minimumHeartRateBPM: Double?
    let maximumHeartRateBPM: Double?
    let stepCount: Double?

    init(_ workout: ParsedWorkout) {
        activityType = workout.activityType
        sourceName = workout.sourceName
        startDate = workout.startDate
        endDate = workout.endDate
        durationSeconds = workout.duration
        activeEnergyKilocalories = workout.activeEnergyKilocalories
        basalEnergyKilocalories = workout.basalEnergyKilocalories
        distanceMetres = workout.distanceMetres
        averageHeartRateBPM = workout.averageHeartRate
        minimumHeartRateBPM = workout.minimumHeartRate
        maximumHeartRateBPM = workout.maximumHeartRate
        stepCount = workout.stepCount
    }

    func csvFields(formatter: ISO8601DateFormatter) -> [String] {
        let metadata = [
            Self.csvText(activityType),
            Self.csvText(sourceName ?? ""),
            startDate.map { formatter.string(from: $0) } ?? "",
            endDate.map { formatter.string(from: $0) } ?? ""
        ]
        let metrics = [
            durationSeconds, activeEnergyKilocalories, basalEnergyKilocalories,
            distanceMetres, averageHeartRateBPM, minimumHeartRateBPM,
            maximumHeartRateBPM, stepCount
        ].map(Self.csvNumber)
        return metadata + metrics
    }

    private static func csvText(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\r") || value.contains("\n") else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    private static func csvNumber(_ value: Double?) -> String {
        guard let value else { return "" }
        if value == value.rounded(), abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(value)
    }
}
