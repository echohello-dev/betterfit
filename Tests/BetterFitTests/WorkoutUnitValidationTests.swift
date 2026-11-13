import Foundation
import XCTest

import BetterFit

final class WorkoutUnitValidationTests: XCTestCase {

    // MARK: - Supported Units

    func testSupportedEnergyUnitsAndOmittedUnitKeepExistingConversions() throws {
        let cases: [(String?, Double)] = [
            ("kcal", 4184), ("cal", 4184), (nil, 4184), ("KJ", 1000), ("J", 1)
        ]
        for (unit, expected) in cases {
            for type in ["ActiveEnergyBurned", "BasalEnergyBurned"] {
                let statistic = WorkoutStatistics(
                    type: "HKQuantityTypeIdentifier" + type, sum: 4184, unit: unit
                )
                XCTAssertEqual(try XCTUnwrap(statistic.sumKilocalories), expected, accuracy: 0.000001)
            }
            let workout = try parseWorkout(energyUnit: unit, distanceUnit: "m")
            XCTAssertEqual(try XCTUnwrap(workout.totalEnergyBurned), expected, accuracy: 0.000001)
        }
    }

    func testSupportedDistanceUnitsAndOmittedUnitKeepExistingConversions() throws {
        let cases: [(String?, Double)] = [("m", 1), (nil, 1), ("KM", 1000), ("MI", 1609.344)]
        for (unit, expected) in cases {
            for type in ["DistanceWalkingRunning", "DistanceCycling"] {
                let statistic = WorkoutStatistics(
                    type: "HKQuantityTypeIdentifier" + type, sum: 1, unit: unit
                )
                XCTAssertEqual(try XCTUnwrap(statistic.sumMetres), expected, accuracy: 0.000001)
            }
            let workout = try parseWorkout(energyUnit: "kcal", distanceUnit: unit)
            XCTAssertEqual(try XCTUnwrap(workout.totalDistance), expected, accuracy: 0.000001)
        }
    }

    // MARK: - Unsupported Units

    func testUnsupportedStatisticUnitsPreserveRawValuesButHaveNoNormalisedValue() throws {
        for unit in ["unknown", "", "count"] {
            let statistics = ["ActiveEnergyBurned", "BasalEnergyBurned", "DistanceWalkingRunning", "DistanceCycling"]
                .map { WorkoutStatistics(type: "HKQuantityTypeIdentifier" + $0, sum: 42, unit: unit) }

            for statistic in statistics {
                XCTAssertNil(statistic.sumKilocalories)
                XCTAssertNil(statistic.sumMetres)
                XCTAssertEqual(statistic.sum, 42)
                XCTAssertEqual(statistic.unit, unit)
            }

            let data = try JSONEncoder().encode(statistics)
            XCTAssertEqual(try JSONDecoder().decode([WorkoutStatistics].self, from: data), statistics)
        }
    }

    func testUnsupportedChildUnitsFallBackToRecognisedWorkoutTotals() throws {
        let workout = try parseWorkout(energyUnit: "kcal", distanceUnit: "km", statistics: """
            <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="99" unit="unknown"/>
            <WorkoutStatistics type="HKQuantityTypeIdentifierBasalEnergyBurned" sum="20" unit="unknown"/>
            <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="99" unit="unknown"/>
            """)

        XCTAssertEqual(workout.activeEnergyKilocalories, 4184)
        XCTAssertEqual(workout.distanceMetres, 1000)
        XCTAssertNil(workout.basalEnergyKilocalories)
        XCTAssertEqual(workout.statistics[0].sum, 99)
        XCTAssertEqual(workout.statistics[0].unit, "unknown")
    }

    func testUnsupportedWalkingDistanceFallsBackToRecognisedCyclingStatistic() throws {
        let workout = try parseWorkout(energyUnit: "kcal", distanceUnit: "m", statistics: """
            <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="99" unit="unknown"/>
            <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceCycling" sum="2" unit="km"/>
            """)

        XCTAssertEqual(workout.distanceMetres, 2000)
    }

    func testRecognisedChildStatisticsSurviveUnsupportedWorkoutTotalUnits() throws {
        let workout = try parseWorkout(energyUnit: "unknown", distanceUnit: "unknown", statistics: """
            <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="418.4" unit="kJ"/>
            <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="5" unit="km"/>
            """)

        XCTAssertNil(workout.totalEnergyBurned)
        XCTAssertNil(workout.totalDistance)
        XCTAssertEqual(try XCTUnwrap(workout.activeEnergyKilocalories), 100, accuracy: 0.000001)
        XCTAssertEqual(workout.distanceMetres, 5000)
    }

    // MARK: - Weekly Analytics

    func testUnsupportedUnitsDoNotContaminateWeeklyTotals() throws {
        for unit in ["unknown", "", "count"] {
            let unsupported = try parseWorkout(energyUnit: unit, distanceUnit: unit, statistics: """
                <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="99" unit="\(unit)"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="99" unit="\(unit)"/>
                """)
            let missing = try XCTUnwrap(HealthExport(workouts: [unsupported]).weeklyTrainingSummaries().first)
            XCTAssertEqual(missing.workoutCount, 1)
            XCTAssertNil(missing.totalActiveEnergyKilocalories)
            XCTAssertNil(missing.totalDistanceMetres)

            let recognised = try parseWorkout(energyUnit: "kcal", distanceUnit: "km")
            let mixed = try XCTUnwrap(
                HealthExport(workouts: [unsupported, recognised]).weeklyTrainingSummaries().first
            )
            XCTAssertEqual(mixed.workoutCount, 2)
            XCTAssertEqual(mixed.totalActiveEnergyKilocalories, 4184)
            XCTAssertEqual(mixed.totalDistanceMetres, 1000)

            let zero = ParsedWorkout(
                activityType: "Running", startDate: unsupported.startDate, totalEnergyBurned: 0, totalDistance: 0
            )
            let measuredZero = try XCTUnwrap(
                HealthExport(workouts: [unsupported, zero]).weeklyTrainingSummaries().first
            )
            XCTAssertEqual(measuredZero.totalActiveEnergyKilocalories, 0)
            XCTAssertEqual(measuredZero.totalDistanceMetres, 0)
        }
    }

    // MARK: - Fixtures

    private func parseWorkout(
        energyUnit: String?, distanceUnit: String?, statistics: String = ""
    ) throws -> ParsedWorkout {
        let energyAttribute = energyUnit.map { "totalEnergyBurnedUnit=\"\($0)\"" } ?? ""
        let distanceAttribute = distanceUnit.map { "totalDistanceUnit=\"\($0)\"" } ?? ""
        let xml = """
            <HealthData>
              <Workout workoutActivityType="Running" startDate="2026-04-19 07:00:00 +1000"
                totalEnergyBurned="4184" \(energyAttribute) totalDistance="1" \(distanceAttribute)>
                \(statistics)
              </Workout>
            </HealthData>
            """
        return try XCTUnwrap(HealthExportParser.parseWorkouts(xml: xml).first)
    }
}
