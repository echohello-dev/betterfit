import Foundation

// MARK: - WorkoutStatistics

/// A single child `WorkoutStatistics` element nested under a `Workout`
/// in an Apple Health export.
///
/// HealthKit writes one of these per quantity type for the workout window,
/// for example active energy, distance, or heart rate. Fields that a given
/// type does not carry stay nil. A heart-rate statistic uses average,
/// minimum, and maximum. A distance or energy statistic uses sum.
public struct WorkoutStatistics: Codable, Equatable, Sendable {
    public var type: String
    public var startDate: Date?
    public var endDate: Date?
    public var sum: Double?
    public var average: Double?
    public var minimum: Double?
    public var maximum: Double?
    public var unit: String?

    public init(
        type: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        sum: Double? = nil,
        average: Double? = nil,
        minimum: Double? = nil,
        maximum: Double? = nil,
        unit: String? = nil
    ) {
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.sum = sum
        self.average = average
        self.minimum = minimum
        self.maximum = maximum
        self.unit = unit
    }

    // MARK: - Kind

    /// Coarse classification of the statistic type.
    public enum Kind: Equatable, Sendable {
        case activeEnergy
        case basalEnergy
        case distanceWalkingRunning
        case distanceCycling
        case heartRate
        case stepCount
        case other(String)
    }

    public var kind: Kind {
        switch type {
        case "HKQuantityTypeIdentifierActiveEnergyBurned":
            return .activeEnergy
        case "HKQuantityTypeIdentifierBasalEnergyBurned":
            return .basalEnergy
        case "HKQuantityTypeIdentifierDistanceWalkingRunning":
            return .distanceWalkingRunning
        case "HKQuantityTypeIdentifierDistanceCycling":
            return .distanceCycling
        case "HKQuantityTypeIdentifierHeartRate":
            return .heartRate
        case "HKQuantityTypeIdentifierStepCount":
            return .stepCount
        default:
            return .other(type)
        }
    }

    // MARK: - Normalised Values

    /// Sum expressed in kilocalories, or nil when this is not an energy
    /// statistic or the unit cannot be normalised.
    public var sumKilocalories: Double? {
        guard kind == .activeEnergy || kind == .basalEnergy, let sum else { return nil }
        switch unit?.lowercased() {
        case "kcal", "cal", nil:
            // Health export writes energy in kcal by default. Small "cal"
            // values in the wild are also kilocalories in this context.
            return sum
        case "kj":
            return sum / 4.184
        case "j":
            return sum / 4184
        default:
            return sum
        }
    }

    /// Sum expressed in metres, or nil when this is not a distance statistic.
    public var sumMetres: Double? {
        guard kind == .distanceWalkingRunning || kind == .distanceCycling, let sum else {
            return nil
        }
        switch unit?.lowercased() {
        case "km":
            return sum * 1000
        case "mi":
            return sum * 1609.344
        case "m", nil:
            return sum
        default:
            return sum
        }
    }
}

// MARK: - ParsedWorkout

/// A workout parsed from an Apple Health export, with its child statistics.
public struct ParsedWorkout: Codable, Equatable, Sendable {
    public var activityType: String
    public var sourceName: String?
    public var sourceVersion: String?
    public var creationDate: Date?
    public var startDate: Date?
    public var endDate: Date?
    /// Duration in seconds, normalised from the export duration and unit.
    public var duration: TimeInterval?
    /// Total energy burned in kilocalories as written on the workout element.
    public var totalEnergyBurned: Double?
    /// Total distance in metres as written on the workout element.
    public var totalDistance: Double?
    public var statistics: [WorkoutStatistics]

    public init(
        activityType: String,
        sourceName: String? = nil,
        sourceVersion: String? = nil,
        creationDate: Date? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        duration: TimeInterval? = nil,
        totalEnergyBurned: Double? = nil,
        totalDistance: Double? = nil,
        statistics: [WorkoutStatistics] = []
    ) {
        self.activityType = activityType
        self.sourceName = sourceName
        self.sourceVersion = sourceVersion
        self.creationDate = creationDate
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.totalEnergyBurned = totalEnergyBurned
        self.totalDistance = totalDistance
        self.statistics = statistics
    }

    // MARK: - Statistic Lookup

    public func statistic(for kind: WorkoutStatistics.Kind) -> WorkoutStatistics? {
        statistics.first { $0.kind == kind }
    }

    // MARK: - Per-Workout Summaries

    /// Active energy in kilocalories. Prefers the child statistic, then
    /// falls back to the total written on the workout element.
    public var activeEnergyKilocalories: Double? {
        statistic(for: .activeEnergy)?.sumKilocalories ?? totalEnergyBurned
    }

    /// Basal energy in kilocalories, when present.
    public var basalEnergyKilocalories: Double? {
        statistic(for: .basalEnergy)?.sumKilocalories
    }

    /// Distance in metres. Prefers the walking or running distance
    /// statistic, then cycling, then the workout total.
    public var distanceMetres: Double? {
        if let value = statistic(for: .distanceWalkingRunning)?.sumMetres { return value }
        if let value = statistic(for: .distanceCycling)?.sumMetres { return value }
        return totalDistance
    }

    /// Distance in kilometres, when a distance is available.
    public var distanceKilometres: Double? {
        distanceMetres.map { $0 / 1000 }
    }

    /// Average heart rate in beats per minute, when present.
    public var averageHeartRate: Double? {
        statistic(for: .heartRate)?.average
    }

    /// Minimum heart rate in beats per minute, when present.
    public var minimumHeartRate: Double? {
        statistic(for: .heartRate)?.minimum
    }

    /// Maximum heart rate in beats per minute, when present.
    public var maximumHeartRate: Double? {
        statistic(for: .heartRate)?.maximum
    }

    /// Step count summed over the workout, when present.
    public var stepCount: Double? {
        statistic(for: .stepCount)?.sum
    }
}
