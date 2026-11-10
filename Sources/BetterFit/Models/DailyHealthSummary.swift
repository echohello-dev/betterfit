import Foundation

// MARK: - DailyHealthSummary

/// One calendar day of health data, aggregated from top-level records.
///
/// Totals use the normalised values on `HealthRecord`, so energy is in
/// kilocalories, distance in metres, and body mass in kilograms regardless
/// of the unit each record was exported with. Fields with no records that
/// day stay nil rather than reading as a measured zero.
public struct DailyHealthSummary: Codable, Equatable, Sendable {
    /// Start of the day the summary covers, in the aggregating calendar.
    public var date: Date
    public var stepCount: Double?
    public var activeEnergyKilocalories: Double?
    public var basalEnergyKilocalories: Double?
    public var distanceMetres: Double?
    /// Mean of the day heart rate samples.
    public var averageHeartRate: Double?
    /// Most recent resting heart rate sample of the day.
    public var restingHeartRate: Double?
    /// Most recent body mass sample of the day, in kilograms.
    public var bodyMassKilograms: Double?
    /// Time asleep in recognised sleep-analysis records starting that day.
    /// Overlapping intervals count once. Awake, in-bed, unknown categories,
    /// and intervals without a positive duration are excluded.
    /// Nil when no valid asleep interval is present.
    public var sleepDuration: TimeInterval?

    public init(
        date: Date,
        stepCount: Double? = nil,
        activeEnergyKilocalories: Double? = nil,
        basalEnergyKilocalories: Double? = nil,
        distanceMetres: Double? = nil,
        averageHeartRate: Double? = nil,
        restingHeartRate: Double? = nil,
        bodyMassKilograms: Double? = nil,
        sleepDuration: TimeInterval? = nil
    ) {
        self.date = date
        self.stepCount = stepCount
        self.activeEnergyKilocalories = activeEnergyKilocalories
        self.basalEnergyKilocalories = basalEnergyKilocalories
        self.distanceMetres = distanceMetres
        self.averageHeartRate = averageHeartRate
        self.restingHeartRate = restingHeartRate
        self.bodyMassKilograms = bodyMassKilograms
        self.sleepDuration = sleepDuration
    }
}

// MARK: - Aggregation

extension HealthExport {

    /// Aggregate records into one summary per calendar day, sorted by day.
    ///
    /// Records are grouped by the start of the day of their `startDate` in
    /// `calendar`. Records without a start date cannot be placed on a day
    /// and are skipped.
    public func dailySummaries(calendar: Calendar = .current) -> [DailyHealthSummary] {
        var days: [Date: DayAccumulator] = [:]

        for record in records {
            guard let startDate = record.startDate else { continue }
            let day = calendar.startOfDay(for: startDate)
            days[day, default: DayAccumulator()].add(record)
        }

        return days.keys.sorted().map { day in
            // Force unwrap is safe: the key came from the dictionary.
            days[day]!.summary(date: day)
        }
    }
}

// MARK: - Day Accumulator

private struct DayAccumulator {
    private var stepCount: Double?
    private var activeEnergy: Double?
    private var basalEnergy: Double?
    private var distance: Double?
    private var heartRateSum: Double = 0
    private var heartRateCount: Int = 0
    private var resting: (date: Date, value: Double)?
    private var bodyMass: (date: Date, value: Double)?
    private var sleepIntervals: [DateInterval] = []

    mutating func add(_ record: HealthRecord) {
        addTotal(record)
        addSample(record)
    }

    private mutating func addTotal(_ record: HealthRecord) {
        switch record.kind {
        case .stepCount:
            if let value = record.value { stepCount = (stepCount ?? 0) + value }
        case .activeEnergy:
            if let value = record.valueKilocalories {
                activeEnergy = (activeEnergy ?? 0) + value
            }
        case .basalEnergy:
            if let value = record.valueKilocalories {
                basalEnergy = (basalEnergy ?? 0) + value
            }
        case .distanceWalkingRunning, .distanceCycling:
            if let value = record.valueMetres { distance = (distance ?? 0) + value }
        default:
            break
        }
    }

    private mutating func addSample(_ record: HealthRecord) {
        switch record.kind {
        case .heartRate:
            if let value = record.value {
                heartRateSum += value
                heartRateCount += 1
            }
        case .restingHeartRate:
            resting = latest(resting, record: record, value: record.value)
        case .bodyMass:
            bodyMass = latest(bodyMass, record: record, value: record.valueKilograms)
        case .sleepAnalysis:
            if record.isAsleep, let start = record.startDate, let end = record.endDate, end > start {
                sleepIntervals.append(DateInterval(start: start, end: end))
            }
        default:
            break
        }
    }

    private func latest(
        _ current: (date: Date, value: Double)?,
        record: HealthRecord,
        value: Double?
    ) -> (date: Date, value: Double)? {
        guard let value, let date = record.startDate else { return current }
        guard let current else { return (date, value) }
        return date >= current.date ? (date, value) : current
    }

    func summary(date: Date) -> DailyHealthSummary {
        DailyHealthSummary(
            date: date,
            stepCount: stepCount,
            activeEnergyKilocalories: activeEnergy,
            basalEnergyKilocalories: basalEnergy,
            distanceMetres: distance,
            averageHeartRate: heartRateCount > 0 ? heartRateSum / Double(heartRateCount) : nil,
            restingHeartRate: resting?.value,
            bodyMassKilograms: bodyMass?.value,
            sleepDuration: sleepDuration
        )
    }

    // MARK: - Sleep

    private var sleepDuration: TimeInterval? {
        let intervals = sleepIntervals.sorted { $0.start < $1.start }
        guard var current = intervals.first else { return nil }
        var total: TimeInterval = 0
        for interval in intervals.dropFirst() {
            if interval.start <= current.end {
                current.end = max(current.end, interval.end)
            } else {
                total += current.duration
                current = interval
            }
        }
        return total + current.duration
    }
}

// MARK: - Sleep Categories

private extension HealthRecord {
    var isAsleep: Bool {
        switch categoryValue {
        case "HKCategoryValueSleepAnalysisAsleep",
             "HKCategoryValueSleepAnalysisAsleepUnspecified",
             "HKCategoryValueSleepAnalysisAsleepCore",
             "HKCategoryValueSleepAnalysisAsleepDeep",
             "HKCategoryValueSleepAnalysisAsleepREM":
            return true
        case nil:
            // HealthKit raw values for unspecified, core, deep, and REM sleep.
            return value == 1 || value == 3 || value == 4 || value == 5
        default:
            return false
        }
    }
}
