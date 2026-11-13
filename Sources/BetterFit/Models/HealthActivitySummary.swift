import Foundation

/// A daily `ActivitySummary` element from an Apple Health export.
///
/// These are Apple's activity ring totals, kept separate from record-derived
/// daily summaries so the same energy is not counted twice.
public struct HealthActivitySummary: Codable, Equatable, Sendable {
    /// Exported calendar day (`yyyy-MM-dd`), without a time zone or time of day.
    public var dateComponents: String?
    public var activeEnergyBurned: Double?
    public var activeEnergyBurnedGoal: Double?
    /// Exported unit shared by active energy and its goal.
    public var activeEnergyBurnedUnit: String?
    /// Exercise time in minutes, as exported by Apple Health.
    public var appleExerciseTime: Double?
    /// Exercise goal in minutes.
    public var appleExerciseTimeGoal: Double?
    public var appleStandHours: Double?
    public var appleStandHoursGoal: Double?

    public init(
        dateComponents: String? = nil,
        activeEnergyBurned: Double? = nil,
        activeEnergyBurnedGoal: Double? = nil,
        activeEnergyBurnedUnit: String? = nil,
        appleExerciseTime: Double? = nil,
        appleExerciseTimeGoal: Double? = nil,
        appleStandHours: Double? = nil,
        appleStandHoursGoal: Double? = nil
    ) {
        self.dateComponents = dateComponents
        self.activeEnergyBurned = activeEnergyBurned
        self.activeEnergyBurnedGoal = activeEnergyBurnedGoal
        self.activeEnergyBurnedUnit = activeEnergyBurnedUnit
        self.appleExerciseTime = appleExerciseTime
        self.appleExerciseTimeGoal = appleExerciseTimeGoal
        self.appleStandHours = appleStandHours
        self.appleStandHoursGoal = appleStandHoursGoal
    }

    // MARK: - Normalised Energy

    /// Energy in kilocalories. Nil for missing or unsupported units.
    public var activeEnergyKilocalories: Double? {
        kilocalories(activeEnergyBurned)
    }

    /// Energy goal in kilocalories. Nil for missing or unsupported units.
    public var activeEnergyGoalKilocalories: Double? {
        kilocalories(activeEnergyBurnedGoal)
    }

    private func kilocalories(_ value: Double?) -> Double? {
        guard let value else { return nil }
        switch activeEnergyBurnedUnit?.lowercased() {
        case "kcal": return value
        case "kj": return value / 4.184
        case "j": return value / 4184
        default: return nil
        }
    }
}
