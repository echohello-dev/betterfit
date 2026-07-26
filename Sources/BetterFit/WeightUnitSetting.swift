import Foundation

public enum WeightUnitSetting: String, CaseIterable, Identifiable, Sendable {
    case lbs = "lbs"
    case kg = "kg"

    public var id: String { rawValue }

    public static let storageKey = "betterfit.settings.weightUnit"

    public func convert(_ weight: Double, from unit: WeightUnitSetting) -> Double {
        if self == unit {
            return weight
        }
        switch (unit, self) {
        case (.lbs, .kg): return weight * 0.453592
        case (.kg, .lbs): return weight / 0.453592
        default: return weight
        }
    }

    public func format(_ weight: Double) -> String {
        "\(Int(weight)) \(rawValue)"
    }
}
