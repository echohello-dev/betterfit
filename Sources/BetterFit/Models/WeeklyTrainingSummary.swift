import Foundation

// MARK: - WeeklyTrainingSummary

/// One calendar week of training, aggregated from parsed workouts.
///
/// Totals use the normalised values on `ParsedWorkout`, so energy is in
/// kilocalories and distance in metres regardless of the unit each workout
/// was exported with. Fields with no workouts carrying that metric stay nil
/// rather than reading as a measured zero.
public struct WeeklyTrainingSummary: Codable, Equatable, Sendable {
    /// Start of the week the summary covers, in the aggregating calendar.
    public var weekStart: Date
    public var workoutCount: Int
    public var totalDuration: TimeInterval?
    public var totalActiveEnergyKilocalories: Double?
    public var totalDistanceMetres: Double?
    /// Mean of the per-workout average heart rates, unweighted by duration.
    public var averageHeartRate: Double?
    /// Highest per-workout maximum heart rate in the week.
    public var maximumHeartRate: Double?
    /// Workout count per raw activity type, for example running or cycling.
    public var activityCounts: [String: Int]

    public init(
        weekStart: Date,
        workoutCount: Int = 0,
        totalDuration: TimeInterval? = nil,
        totalActiveEnergyKilocalories: Double? = nil,
        totalDistanceMetres: Double? = nil,
        averageHeartRate: Double? = nil,
        maximumHeartRate: Double? = nil,
        activityCounts: [String: Int] = [:]
    ) {
        self.weekStart = weekStart
        self.workoutCount = workoutCount
        self.totalDuration = totalDuration
        self.totalActiveEnergyKilocalories = totalActiveEnergyKilocalories
        self.totalDistanceMetres = totalDistanceMetres
        self.averageHeartRate = averageHeartRate
        self.maximumHeartRate = maximumHeartRate
        self.activityCounts = activityCounts
    }
}

// MARK: - Aggregation

extension HealthExport {

    /// Aggregate workouts into one summary per calendar week, sorted by week.
    ///
    /// Workouts are grouped by the week containing their `startDate` in
    /// `calendar`. Workouts without a start date cannot be placed in a week
    /// and are skipped.
    public func weeklyTrainingSummaries(calendar: Calendar = .current) -> [WeeklyTrainingSummary] {
        var weeks: [Date: WeekAccumulator] = [:]

        for workout in workouts {
            guard let startDate = workout.startDate else { continue }
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start else {
                continue
            }
            weeks[weekStart, default: WeekAccumulator()].add(workout)
        }

        return weeks.keys.sorted().map { week in
            // Force unwrap is safe: the key came from the dictionary.
            weeks[week]!.summary(weekStart: week)
        }
    }
}

// MARK: - Week Accumulator

private struct WeekAccumulator {
    private var workoutCount: Int = 0
    private var totalDuration: TimeInterval?
    private var totalEnergy: Double?
    private var totalDistance: Double?
    private var heartRateSum: Double = 0
    private var heartRateCount: Int = 0
    private var maximumHeartRate: Double?
    private var activityCounts: [String: Int] = [:]

    mutating func add(_ workout: ParsedWorkout) {
        workoutCount += 1
        activityCounts[workout.activityType, default: 0] += 1
        if let duration = workout.duration {
            totalDuration = (totalDuration ?? 0) + duration
        }
        if let energy = workout.activeEnergyKilocalories {
            totalEnergy = (totalEnergy ?? 0) + energy
        }
        if let distance = workout.distanceMetres {
            totalDistance = (totalDistance ?? 0) + distance
        }
        if let average = workout.averageHeartRate {
            heartRateSum += average
            heartRateCount += 1
        }
        if let maximum = workout.maximumHeartRate {
            maximumHeartRate = max(maximumHeartRate ?? maximum, maximum)
        }
    }

    func summary(weekStart: Date) -> WeeklyTrainingSummary {
        WeeklyTrainingSummary(
            weekStart: weekStart,
            workoutCount: workoutCount,
            totalDuration: totalDuration,
            totalActiveEnergyKilocalories: totalEnergy,
            totalDistanceMetres: totalDistance,
            averageHeartRate: heartRateCount > 0 ? heartRateSum / Double(heartRateCount) : nil,
            maximumHeartRate: maximumHeartRate,
            activityCounts: activityCounts
        )
    }
}
