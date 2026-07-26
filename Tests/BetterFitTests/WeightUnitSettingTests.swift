import XCTest
@testable import BetterFit

final class WeightUnitSettingTests: XCTestCase {
    func testStorageKeyIsStable() {
        XCTAssertEqual(
            WeightUnitSetting.storageKey,
            "betterfit.settings.weightUnit",
            "storage key must not change — users' stored preference depends on it"
        )
    }

    func testConvertSameUnitIsIdentity() {
        let lbs: Double = 180
        XCTAssertEqual(
            WeightUnitSetting.lbs.convert(lbs, from: .lbs),
            lbs,
            accuracy: 0.0001
        )
        let kg: Double = 100
        XCTAssertEqual(
            WeightUnitSetting.kg.convert(kg, from: .kg),
            kg,
            accuracy: 0.0001
        )
    }

    func testConvertLbsToKg() {
        let result = WeightUnitSetting.kg.convert(100, from: .lbs)
        XCTAssertEqual(result, 45.3592, accuracy: 0.001)
    }

    func testConvertKgToLbs() {
        let result = WeightUnitSetting.lbs.convert(100, from: .kg)
        XCTAssertEqual(result, 220.462, accuracy: 0.01)
    }

    func testFormatIncludesUnitSuffix() {
        XCTAssertEqual(WeightUnitSetting.lbs.format(180), "180 lbs")
        XCTAssertEqual(WeightUnitSetting.kg.format(80), "80 kg")
    }

    func testCasesAreUnique() {
        XCTAssertEqual(WeightUnitSetting.allCases.count, 2)
        XCTAssertNotEqual(WeightUnitSetting.lbs.rawValue, WeightUnitSetting.kg.rawValue)
    }
}
