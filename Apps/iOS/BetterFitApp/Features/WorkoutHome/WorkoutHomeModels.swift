import Foundation
import BetterFit

enum HeatmapRange: String {
    case week
    case month
    case year
    case custom
}

enum WorkoutCategory {
    case cardio
    case strength
    case lifting
}

struct WorkoutRangeStats {
    let totalWorkouts: Int
    let activeDays: Int
}

struct WorkoutCategorySplit {
    let cardioPercent: Int
    let strengthPercent: Int
    let liftingPercent: Int
}
