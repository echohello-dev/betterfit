import XCTest
@testable import BetterFit

final class AppearancePreferenceTests: XCTestCase {
    func testAllCases() {
        XCTAssertEqual(AppearancePreference.allCases, [.system, .light, .dark])
    }

    func testDefaultPreference() {
        XCTAssertEqual(AppearancePreference.defaultPreference, .dark)
    }

    func testStorageKey() {
        XCTAssertEqual(AppearancePreference.storageKey, "betterfit.appearancePreference")
    }

    func testFromStorageWithValidRawValue() {
        XCTAssertEqual(AppearancePreference.fromStorage("system"), .system)
        XCTAssertEqual(AppearancePreference.fromStorage("light"), .light)
        XCTAssertEqual(AppearancePreference.fromStorage("dark"), .dark)
    }

    func testFromStorageWithNilReturnsDefault() {
        XCTAssertEqual(AppearancePreference.fromStorage(nil), .dark)
    }

    func testFromStorageWithInvalidRawValueReturnsDefault() {
        XCTAssertEqual(AppearancePreference.fromStorage("invalid"), .dark)
        XCTAssertEqual(AppearancePreference.fromStorage(""), .dark)
    }

    func testRoundTripping() {
        for pref in AppearancePreference.allCases {
            let stored = pref.rawValue
            let restored = AppearancePreference.fromStorage(stored)
            XCTAssertEqual(restored, pref)
        }
    }

    func testIdentifiable() {
        for pref in AppearancePreference.allCases {
            XCTAssertEqual(pref.id, pref.rawValue)
        }
    }

    func testSendableConformance() {
        // Compile-time check: Sendable types can be passed across concurrency boundaries
        let preferences: [AppearancePreference] = [.system, .light, .dark]
        XCTAssertEqual(preferences.count, 3)
    }
}

final class AccentSurfaceOpacityTests: XCTestCase {
    // MARK: Dark mode (pass-through)

    func testDarkModePassesOpacityThrough() {
        XCTAssertEqual(accentSurfaceOpacity(0.15, isDark: true), 0.15)
        XCTAssertEqual(accentSurfaceOpacity(0.3, isDark: true), 0.3)
        XCTAssertEqual(accentSurfaceOpacity(0.5, isDark: true), 0.5)
        XCTAssertEqual(accentSurfaceOpacity(1.0, isDark: true), 1.0)
        XCTAssertEqual(accentSurfaceOpacity(0.0, isDark: true), 0.0)
    }

    // MARK: Light mode (boosted)

    func testLightModeSmallOpacityIsBoosted() {
        let result = accentSurfaceOpacity(0.15, isDark: false)
        // 0.15 * 1.8 + 0.08 = 0.35
        XCTAssertEqual(result, 0.35, accuracy: 0.001)
    }

    func testLightModeMediumOpacityIsBoosted() {
        let result = accentSurfaceOpacity(0.3, isDark: false)
        // 0.3 * 1.8 + 0.08 = 0.62
        XCTAssertEqual(result, 0.62, accuracy: 0.001)
    }

    func testLightModeHighOpacityIsClampedTo085() {
        let result = accentSurfaceOpacity(0.5, isDark: false)
        // 0.5 * 1.8 + 0.08 = 0.98 → min(0.85, 0.98) = 0.85
        XCTAssertEqual(result, 0.85, accuracy: 0.001)
    }

    func testLightModeVeryHighOpacityIsClampedTo085() {
        let result = accentSurfaceOpacity(1.0, isDark: false)
        // 1.0 * 1.8 + 0.08 = 1.88 → min(0.85, 1.88) = 0.85
        XCTAssertEqual(result, 0.85, accuracy: 0.001)
    }

    func testLightModeZeroOpacity() {
        let result = accentSurfaceOpacity(0.0, isDark: false)
        // 0.0 * 1.8 + 0.08 = 0.08
        XCTAssertEqual(result, 0.08, accuracy: 0.001)
    }

    func testLightModeBoundaryAtClampThreshold() {
        // (~0.428 * 1.8 + 0.08 ≈ 0.85) -> should not clamp
        let result = accentSurfaceOpacity(0.427, isDark: false)
        XCTAssertEqual(result, 0.427 * 1.8 + 0.08, accuracy: 0.001)
        XCTAssertTrue(result <= 0.85)

        let clamped = accentSurfaceOpacity(0.428, isDark: false)
        XCTAssertEqual(clamped, 0.85, accuracy: 0.001)
    }
}
