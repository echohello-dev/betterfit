import Foundation

// MARK: - HealthRecord

/// A single top-level `Record` element from an Apple Health export.
///
/// Workouts carry their own child statistics. Everything else HealthKit
/// tracks across the day, such as steps, heart rate samples, body mass,
/// and sleep, arrives as a flat `Record`. Quantity records carry a numeric
/// `value`. Category records, such as sleep analysis, carry a string value
/// instead, which is kept in `categoryValue`.
public struct HealthRecord: Codable, Equatable, Sendable {
    public var type: String
    public var sourceName: String?
    public var sourceVersion: String?
    public var unit: String?
    public var creationDate: Date?
    public var startDate: Date?
    public var endDate: Date?
    /// Numeric value for quantity records. Nil for category records.
    public var value: Double?
    /// Raw string value for category records. Nil for quantity records.
    public var categoryValue: String?

    public init(
        type: String,
        sourceName: String? = nil,
        sourceVersion: String? = nil,
        unit: String? = nil,
        creationDate: Date? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        value: Double? = nil,
        categoryValue: String? = nil
    ) {
        self.type = type
        self.sourceName = sourceName
        self.sourceVersion = sourceVersion
        self.unit = unit
        self.creationDate = creationDate
        self.startDate = startDate
        self.endDate = endDate
        self.value = value
        self.categoryValue = categoryValue
    }

    // MARK: - Kind

    /// Coarse classification of the record type.
    public enum Kind: Equatable, Sendable {
        case stepCount
        case heartRate
        case restingHeartRate
        case activeEnergy
        case basalEnergy
        case distanceWalkingRunning
        case distanceCycling
        case bodyMass
        case sleepAnalysis
        case other(String)
    }

    public var kind: Kind {
        switch type {
        case "HKQuantityTypeIdentifierStepCount":
            return .stepCount
        case "HKQuantityTypeIdentifierHeartRate":
            return .heartRate
        case "HKQuantityTypeIdentifierRestingHeartRate":
            return .restingHeartRate
        case "HKQuantityTypeIdentifierActiveEnergyBurned":
            return .activeEnergy
        case "HKQuantityTypeIdentifierBasalEnergyBurned":
            return .basalEnergy
        case "HKQuantityTypeIdentifierDistanceWalkingRunning":
            return .distanceWalkingRunning
        case "HKQuantityTypeIdentifierDistanceCycling":
            return .distanceCycling
        case "HKQuantityTypeIdentifierBodyMass":
            return .bodyMass
        case "HKCategoryTypeIdentifierSleepAnalysis":
            return .sleepAnalysis
        default:
            return .other(type)
        }
    }

    // MARK: - Normalised Values

    /// Value expressed in kilocalories, or nil when this is not an energy record.
    public var valueKilocalories: Double? {
        guard kind == .activeEnergy || kind == .basalEnergy, let value else { return nil }
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

    /// Value expressed in metres, or nil when this is not a distance record.
    public var valueMetres: Double? {
        guard kind == .distanceWalkingRunning || kind == .distanceCycling, let value else {
            return nil
        }
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

    /// Value expressed in kilograms, or nil when this is not a body mass record.
    public var valueKilograms: Double? {
        guard kind == .bodyMass, let value else { return nil }
        switch unit?.lowercased() {
        case "lb":
            return value * 0.45359237
        case "g":
            return value / 1000
        case "kg", nil:
            return value
        default:
            return value
        }
    }

    /// Time between the start and end dates, when both are present.
    /// Sleep records use this for time in each sleep stage.
    public var duration: TimeInterval? {
        guard let startDate, let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
}

// MARK: - HealthExport

/// A parsed Apple Health export, with workouts and top-level records.
public struct HealthExport: Codable, Equatable, Sendable {
    public var workouts: [ParsedWorkout]
    public var records: [HealthRecord]

    public init(workouts: [ParsedWorkout] = [], records: [HealthRecord] = []) {
        self.workouts = workouts
        self.records = records
    }

    // MARK: - Record Lookup

    public func records(of kind: HealthRecord.Kind) -> [HealthRecord] {
        records.filter { $0.kind == kind }
    }
}
