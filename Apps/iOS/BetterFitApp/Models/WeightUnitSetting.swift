import Foundation

enum WeightUnitSetting: String, CaseIterable, Identifiable {
    case lbs = "lbs"
    case kg = "kg"
    var id: String { rawValue }
    static let storageKey = "betterfit.settings.weightUnit"

    func convert(_ weight: Double, from unit: WeightUnitSetting) -> Double {
        if self == unit {
            return weight
        }
        switch (unit, self) {
        case (.lbs, .kg): return weight * 0.453592
        case (.kg, .lbs): return weight / 0.453592
        default: return weight
        }
    }

    func format(_ weight: Double) -> String {
        "\(Int(weight)) \(self.rawValue)"
    }
}
