import Foundation
import Testing

import BetterFit

struct WorkoutNumberValidationTests {

    // MARK: - Invalid Measurements

    @Test(arguments: ["-1", "NaN", "nan", "inf", "-inf", "Infinity", "1e999", "", "invalid"])
    func invalidMeasurementsStayMissing(value: String) throws {
        let export = try parse(value: value)
        let workout = try #require(export.workouts.first)

        #expect(workout.duration == nil)
        #expect(workout.totalEnergyBurned == nil)
        #expect(workout.totalDistance == nil)
        #expect(workout.statistics.count == 6)
        for statistic in workout.statistics {
            #expect(statistic.sum == nil)
            #expect(statistic.average == nil)
            #expect(statistic.minimum == nil)
            #expect(statistic.maximum == nil)
        }
        #expect(workout.activeEnergyKilocalories == nil)
        #expect(workout.basalEnergyKilocalories == nil)
        #expect(workout.distanceMetres == nil)
        #expect(workout.averageHeartRate == nil)
        #expect(workout.minimumHeartRate == nil)
        #expect(workout.maximumHeartRate == nil)
        #expect(workout.stepCount == nil)

        let summaries = export.weeklyTrainingSummaries(calendar: utcCalendar)
        let week = try #require(summaries.first)
        #expect(week.workoutCount == 1)
        #expect(week.totalDuration == nil)
        #expect(week.totalActiveEnergyKilocalories == nil)
        #expect(week.totalDistanceMetres == nil)
        #expect(week.averageHeartRate == nil)
        #expect(week.maximumHeartRate == nil)
        let row = try #require(summaries.csvString().split(separator: "\n").last)
        #expect(row == #"2026-04-13T00:00:00Z,1,,,,,,"{""Running"":1}""#)
        #expect(try decoder.decode([WeeklyTrainingSummary].self, from: summaries.jsonData()) == summaries)
        let data = try JSONEncoder().encode(workout)
        #expect(try JSONDecoder().decode(ParsedWorkout.self, from: data) == workout)
    }

    @Test
    func invalidChildValuesFallBackToValidWorkoutTotals() throws {
        let xml = """
            <HealthData>
              <Workout workoutActivityType="Running" duration="30" durationUnit="min"
                totalEnergyBurned="125" totalEnergyBurnedUnit="kcal"
                totalDistance="5" totalDistanceUnit="km">
                <WorkoutStatistics type="HKQuantityTypeIdentifierActiveEnergyBurned" sum="NaN" unit="kcal"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierDistanceWalkingRunning" sum="-1" unit="km"/>
                <WorkoutStatistics type="HKQuantityTypeIdentifierHeartRate"
                  average="140" minimum="NaN" maximum="180" unit="count/min"/>
              </Workout>
            </HealthData>
            """
        let workout = try #require(HealthExportParser.parseWorkouts(xml: xml).first)

        #expect(workout.duration == 1800)
        #expect(workout.activeEnergyKilocalories == 125)
        #expect(workout.distanceMetres == 5000)
        #expect(workout.averageHeartRate == 140)
        #expect(workout.minimumHeartRate == nil)
        #expect(workout.maximumHeartRate == 180)
    }

    @Test
    func invalidWorkoutsDoNotContaminateValidWeeklyMetrics() throws {
        let invalid = try parse(value: "NaN").workouts
        let valid = try parse(value: "2").workouts
        for workouts in [valid + invalid, invalid + valid] {
            let summaries = HealthExport(workouts: workouts).weeklyTrainingSummaries(calendar: utcCalendar)
            let week = try #require(summaries.first)

            #expect(week.workoutCount == 2)
            #expect(week.totalDuration == 120)
            #expect(week.totalActiveEnergyKilocalories == 2)
            #expect(week.totalDistanceMetres == 2000)
            #expect(week.averageHeartRate == 2)
            #expect(week.maximumHeartRate == 2)
            #expect(try decoder.decode([WeeklyTrainingSummary].self, from: summaries.jsonData()) == summaries)
        }
    }

    // MARK: - Valid Measurements

    @Test(arguments: ["0", "2", "2.5", "2e2"])
    func validMeasurementsKeepConversionsAndMetadata(value: String) throws {
        let workout = try #require(parse(value: value).workouts.first)
        let number = try #require(Double(value))

        #expect(workout.duration == number * 60)
        #expect(workout.totalEnergyBurned == number)
        #expect(workout.totalDistance == number * 1000)
        #expect(workout.activeEnergyKilocalories == number)
        #expect(workout.basalEnergyKilocalories == number)
        #expect(workout.distanceMetres == number * 1000)
        #expect(workout.averageHeartRate == number)
        #expect(workout.minimumHeartRate == number)
        #expect(workout.maximumHeartRate == number)
        #expect(workout.stepCount == number)
        #expect(workout.activityType == "Running")
        #expect(workout.sourceName == "Watch")
        for statistic in workout.statistics {
            #expect(statistic.startDate == workout.startDate)
            #expect(statistic.endDate == workout.endDate)
            #expect(statistic.sum == number)
            #expect(statistic.average == number)
            #expect(statistic.minimum == number)
            #expect(statistic.maximum == number)
        }
        #expect(workout.statistic(for: .heartRate)?.unit == "count/min")
    }

    // MARK: - Fixtures

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func parse(value: String) throws -> HealthExport {
        let statistics = [
            ("ActiveEnergyBurned", "kcal"), ("BasalEnergyBurned", "kcal"),
            ("DistanceWalkingRunning", "km"), ("DistanceCycling", "km"),
            ("HeartRate", "count/min"), ("StepCount", "count")
        ].map { type, unit in
            """
            <WorkoutStatistics type="HKQuantityTypeIdentifier\(type)" unit="\(unit)"
              startDate="2026-04-19 07:00:00 +0000" endDate="2026-04-19 07:30:00 +0000"
              sum="\(value)" average="\(value)" minimum="\(value)" maximum="\(value)"/>
            """
        }.joined(separator: "\n")
        return try HealthExportParser.parseExport(xml: """
            <HealthData>
              <Workout workoutActivityType="Running" sourceName="Watch" duration="\(value)" durationUnit="min"
                totalEnergyBurned="\(value)" totalEnergyBurnedUnit="kcal"
                totalDistance="\(value)" totalDistanceUnit="km"
                startDate="2026-04-19 07:00:00 +0000" endDate="2026-04-19 07:30:00 +0000">
                \(statistics)
              </Workout>
            </HealthData>
            """)
    }
}
