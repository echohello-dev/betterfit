import Foundation

// MARK: - HealthExportParser

/// Parses workouts and their child `WorkoutStatistics` from an Apple Health
/// export (`export.xml`).
///
/// The parser is Foundation only and runs on any platform, so export files
/// can be processed off device and in unit tests. It reads `Workout`
/// elements and the `WorkoutStatistics` nested inside them. Top-level
/// `Record` elements are out of scope for this slice and are skipped.
///
/// Example shape:
///
///     <Workout workoutActivityType="HKWorkoutActivityTypeRunning"
///              duration="30" durationUnit="min"
///              totalDistance="5" totalDistanceUnit="km"
///              totalEnergyBurned="300" totalEnergyBurnedUnit="kcal"
///              startDate="2026-04-19 07:00:00 +1000"
///              endDate="2026-04-19 07:30:00 +1000">
///       <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate"
///                          average="150" minimum="110" maximum="175"
///                          unit="count/min" ... />
///     </Workout>
public enum HealthExportParser {

    public enum ParseError: Error, Equatable {
        case malformedXML(String)
    }

    // MARK: - Public API

    /// Parse workouts from export XML data.
    public static func parseWorkouts(data: Data) throws -> [ParsedWorkout] {
        let delegate = Delegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false

        guard parser.parse() else {
            let message = parser.parserError?.localizedDescription ?? "unknown XML error"
            throw ParseError.malformedXML(message)
        }
        if let error = delegate.parseError {
            throw error
        }
        return delegate.workouts
    }

    /// Parse workouts from an export XML string.
    public static func parseWorkouts(xml: String) throws -> [ParsedWorkout] {
        guard let data = xml.data(using: .utf8) else {
            throw ParseError.malformedXML("input is not valid UTF-8")
        }
        return try parseWorkouts(data: data)
    }

    // MARK: - Date Parsing

    static func parseHealthDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }
        return healthDateFormatter.date(from: value)
            ?? healthDateFormatterNoOffset.date(from: value)
    }

    private static let healthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()

    private static let healthDateFormatterNoOffset: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    // MARK: - Value Normalisation

    static func normaliseDuration(value: Double?, unit: String?) -> TimeInterval? {
        guard let value else { return nil }
        switch unit?.lowercased() {
        case "min":
            return value * 60
        case "hr", "h":
            return value * 3600
        case "s", "sec", nil:
            return value
        default:
            return value
        }
    }

    static func normaliseDistanceToMetres(value: Double?, unit: String?) -> Double? {
        guard let value else { return nil }
        switch unit?.lowercased() {
        case "km":
            return value * 1000
        case "mi":
            return value * 1609.344
        case "m", nil:
            return value
        default:
            return value
        }
    }

    static func normaliseEnergyToKilocalories(value: Double?, unit: String?) -> Double? {
        guard let value else { return nil }
        switch unit?.lowercased() {
        case "kj":
            return value / 4.184
        case "j":
            return value / 4184
        case "kcal", "cal", nil:
            return value
        default:
            return value
        }
    }
}

// MARK: - XML Delegate

private final class Delegate: NSObject, XMLParserDelegate {
    private(set) var workouts: [ParsedWorkout] = []
    private(set) var parseError: HealthExportParser.ParseError?
    private var current: ParsedWorkout?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        switch elementName {
        case "Workout":
            current = Self.makeWorkout(attributes: attributeDict)
        case "WorkoutStatistics":
            guard current != nil else { return }
            let stat = Self.makeStatistic(attributes: attributeDict)
            current?.statistics.append(stat)
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "Workout", let workout = current {
            workouts.append(workout)
            current = nil
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = .malformedXML(parseError.localizedDescription)
    }

    // MARK: - Element Builders

    private static func makeWorkout(attributes: [String: String]) -> ParsedWorkout {
        let duration = HealthExportParser.normaliseDuration(
            value: attributes["duration"].flatMap(Double.init),
            unit: attributes["durationUnit"]
        )
        let totalDistance = HealthExportParser.normaliseDistanceToMetres(
            value: attributes["totalDistance"].flatMap(Double.init),
            unit: attributes["totalDistanceUnit"]
        )
        let totalEnergy = HealthExportParser.normaliseEnergyToKilocalories(
            value: attributes["totalEnergyBurned"].flatMap(Double.init),
            unit: attributes["totalEnergyBurnedUnit"]
        )
        return ParsedWorkout(
            activityType: attributes["workoutActivityType"] ?? "",
            sourceName: attributes["sourceName"],
            sourceVersion: attributes["sourceVersion"],
            creationDate: HealthExportParser.parseHealthDate(attributes["creationDate"]),
            startDate: HealthExportParser.parseHealthDate(attributes["startDate"]),
            endDate: HealthExportParser.parseHealthDate(attributes["endDate"]),
            duration: duration,
            totalEnergyBurned: totalEnergy,
            totalDistance: totalDistance
        )
    }

    private static func makeStatistic(attributes: [String: String]) -> WorkoutStatistics {
        WorkoutStatistics(
            type: attributes["type"] ?? "",
            startDate: HealthExportParser.parseHealthDate(attributes["startDate"]),
            endDate: HealthExportParser.parseHealthDate(attributes["endDate"]),
            sum: attributes["sum"].flatMap(Double.init),
            average: attributes["average"].flatMap(Double.init),
            minimum: attributes["minimum"].flatMap(Double.init),
            maximum: attributes["maximum"].flatMap(Double.init),
            unit: attributes["unit"]
        )
    }
}
