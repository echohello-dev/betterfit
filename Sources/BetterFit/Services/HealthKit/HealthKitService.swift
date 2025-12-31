import Foundation

#if os(iOS) || os(watchOS)
    import HealthKit
#endif

/// HealthKit integration service for reading and writing workout data
///
/// Provides async/await APIs for:
/// - Authorization
/// - Reading step count, active energy, heart rate
/// - Saving completed workouts
///
/// Note: HealthKit is only available on iOS and watchOS, not macOS.
public final class HealthKitService: Sendable {

    // MARK: - Types

    /// Health data summary for a given period
    public struct HealthSummary: Sendable {
        // Activity metrics
        public let steps: Double
        public let activeEnergy: Double  // kilocalories
        public let distanceWalkingRunning: Double  // meters
        public let flightsClimbed: Double

        // Heart metrics
        public let heartRate: Double?  // bpm (average)
        public let restingHeartRate: Double?  // bpm

        // Body metrics
        public let height: Double?  // meters
        public let bodyMass: Double?  // kg
        public let bodyFatPercentage: Double?  // 0-1
        public let bmi: Double?  // calculated from height and mass

        // Other metrics
        public let oxygenSaturation: Double?  // 0-1 (percentage)
        public let sleepHours: Double?  // hours
        public let standHours: Int?  // count of hours standing

        public init(
            steps: Double,
            activeEnergy: Double,
            distanceWalkingRunning: Double,
            flightsClimbed: Double,
            heartRate: Double?,
            restingHeartRate: Double?,
            height: Double?,
            bodyMass: Double?,
            bodyFatPercentage: Double?,
            bmi: Double?,
            oxygenSaturation: Double?,
            sleepHours: Double?,
            standHours: Int?
        ) {
            self.steps = steps
            self.activeEnergy = activeEnergy
            self.distanceWalkingRunning = distanceWalkingRunning
            self.flightsClimbed = flightsClimbed
            self.heartRate = heartRate
            self.restingHeartRate = restingHeartRate
            self.height = height
            self.bodyMass = bodyMass
            self.bodyFatPercentage = bodyFatPercentage
            self.bmi = bmi
            self.oxygenSaturation = oxygenSaturation
            self.sleepHours = sleepHours
            self.standHours = standHours
        }
    }

    /// Authorization status
    public enum AuthorizationStatus: Sendable {
        case notDetermined
        case authorized
        case denied
        case unavailable
    }

    // MARK: - Properties

    #if os(iOS) || os(watchOS)
        private let healthStore: HKHealthStore?

        /// Types we want to read from HealthKit
        private var readTypes: Set<HKObjectType> {
            var types: Set<HKObjectType> = []

            // Activity types
            if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
                types.insert(stepCount)
            }
            if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                types.insert(activeEnergy)
            }
            if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                types.insert(distance)
            }
            if let flights = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) {
                types.insert(flights)
            }

            // Heart types
            if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
                types.insert(heartRate)
            }
            if let restingHeartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
            {
                types.insert(restingHeartRate)
            }

            // Body metrics
            if let height = HKQuantityType.quantityType(forIdentifier: .height) {
                types.insert(height)
            }
            if let bodyMass = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
                types.insert(bodyMass)
            }
            if let bodyFat = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage) {
                types.insert(bodyFat)
            }
            if let bmi = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) {
                types.insert(bmi)
            }

            // Other metrics
            if let oxygen = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) {
                types.insert(oxygen)
            }
            if let sleep = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
                types.insert(sleep)
            }
            if let standHour = HKCategoryType.categoryType(forIdentifier: .appleStandHour) {
                types.insert(standHour)
            }

            types.insert(HKObjectType.workoutType())
            return types
        }

        /// Types we want to write to HealthKit
        private var writeTypes: Set<HKSampleType> {
            var types: Set<HKSampleType> = []
            if let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                types.insert(activeEnergy)
            }
            types.insert(HKObjectType.workoutType())
            return types
        }
    #endif

    // MARK: - Initialization

    public init() {
        #if os(iOS) || os(watchOS)
            if HKHealthStore.isHealthDataAvailable() {
                self.healthStore = HKHealthStore()
            } else {
                self.healthStore = nil
            }
        #endif
    }

    // MARK: - Authorization

    /// Check if HealthKit is available on this device
    public var isAvailable: Bool {
        #if os(iOS) || os(watchOS)
            return HKHealthStore.isHealthDataAvailable() && healthStore != nil
        #else
            return false
        #endif
    }

    /// Request authorization to read/write health data
    /// - Returns: Authorization status after request
    @MainActor
    public func requestAuthorization() async -> AuthorizationStatus {
        #if os(iOS) || os(watchOS)
            guard let healthStore else {
                return .unavailable
            }

            do {
                try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
                // HealthKit doesn't tell us the actual status for read permissions (privacy)
                // We assume authorized if no error was thrown
                return .authorized
            } catch {
                print("HealthKit authorization failed: \(error.localizedDescription)")
                return .denied
            }
        #else
            return .unavailable
        #endif
    }

    // MARK: - Reading Data

    /// Fetch today's health summary
    /// - Returns: Health summary with steps, active energy, and average heart rate
    public func fetchTodaySummary() async -> HealthSummary {
        #if os(iOS) || os(watchOS)
            guard healthStore != nil else {
                return HealthSummary(
                    steps: 0,
                    activeEnergy: 0,
                    distanceWalkingRunning: 0,
                    flightsClimbed: 0,
                    heartRate: nil,
                    restingHeartRate: nil,
                    height: nil,
                    bodyMass: nil,
                    bodyFatPercentage: nil,
                    bmi: nil,
                    oxygenSaturation: nil,
                    sleepHours: nil,
                    standHours: nil
                )
            }

            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)

            async let steps = fetchSteps(from: startOfDay, to: now)
            async let energy = fetchActiveEnergy(from: startOfDay, to: now)
            async let heartRate = fetchAverageHeartRate(from: startOfDay, to: now)

            return await HealthSummary(
                steps: steps,
                activeEnergy: energy,
                distanceWalkingRunning: 0,
                flightsClimbed: 0,
                heartRate: heartRate,
                restingHeartRate: nil,
                height: nil,
                bodyMass: nil,
                bodyFatPercentage: nil,
                bmi: nil,
                oxygenSaturation: nil,
                sleepHours: nil,
                standHours: nil
            )
        #else
            return HealthSummary(
                steps: 0,
                activeEnergy: 0,
                distanceWalkingRunning: 0,
                flightsClimbed: 0,
                heartRate: nil,
                restingHeartRate: nil,
                height: nil,
                bodyMass: nil,
                bodyFatPercentage: nil,
                bmi: nil,
                oxygenSaturation: nil,
                sleepHours: nil,
                standHours: nil
            )
        #endif
    }

    /// Fetch step count for a date range
    /// - Parameters:
    ///   - startDate: Start of the period
    ///   - endDate: End of the period
    /// - Returns: Total steps in the period
    public func fetchSteps(from startDate: Date, to endDate: Date) async -> Double {
        #if os(iOS) || os(watchOS)
            guard let healthStore,
                let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
            else {
                return 0
            }

            return await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForSamples(
                    withStart: startDate,
                    end: endDate,
                    options: .strictStartDate
                )

                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, error in
                    if let error {
                        print("Failed to fetch steps: \(error.localizedDescription)")
                        continuation.resume(returning: 0)
                        return
                    }

                    let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    continuation.resume(returning: steps)
                }

                healthStore.execute(query)
            }
        #else
            return 0
        #endif
    }

    /// Fetch active energy burned for a date range
    /// - Parameters:
    ///   - startDate: Start of the period
    ///   - endDate: End of the period
    /// - Returns: Total active energy in kilocalories
    public func fetchActiveEnergy(from startDate: Date, to endDate: Date) async -> Double {
        #if os(iOS) || os(watchOS)
            guard let healthStore,
                let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
            else {
                return 0
            }

            return await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForSamples(
                    withStart: startDate,
                    end: endDate,
                    options: .strictStartDate
                )

                let query = HKStatisticsQuery(
                    quantityType: energyType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, error in
                    if let error {
                        print("Failed to fetch active energy: \(error.localizedDescription)")
                        continuation.resume(returning: 0)
                        return
                    }

                    let energy = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    continuation.resume(returning: energy)
                }

                healthStore.execute(query)
            }
        #else
            return 0
        #endif
    }

    /// Fetch average heart rate for a date range
    /// - Parameters:
    ///   - startDate: Start of the period
    ///   - endDate: End of the period
    /// - Returns: Average heart rate in BPM, or nil if no data
    public func fetchAverageHeartRate(from startDate: Date, to endDate: Date) async -> Double? {
        #if os(iOS) || os(watchOS)
            guard let healthStore,
                let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)
            else {
                return nil
            }

            return await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForSamples(
                    withStart: startDate,
                    end: endDate,
                    options: .strictStartDate
                )

                let query = HKStatisticsQuery(
                    quantityType: heartRateType,
                    quantitySamplePredicate: predicate,
                    options: .discreteAverage
                ) { _, result, error in
                    if let error {
                        print("Failed to fetch heart rate: \(error.localizedDescription)")
                        continuation.resume(returning: nil)
                        return
                    }

                    let bpm = result?.averageQuantity()?.doubleValue(
                        for: HKUnit.count().unitDivided(by: .minute())
                    )
                    continuation.resume(returning: bpm)
                }

                healthStore.execute(query)
            }
        #else
            return nil
        #endif
    }

    // MARK: - Writing Data

    /// Save a completed workout to HealthKit
    /// - Parameters:
    ///   - workout: The BetterFit workout to save
    /// - Returns: True if saved successfully
    public func saveWorkout(_ workout: Workout) async -> Bool {
        #if os(iOS) || os(watchOS)
            guard let healthStore else {
                return false
            }

            // Use traditional strength training for all BetterFit workouts
            let activityType = HKWorkoutActivityType.traditionalStrengthTraining
            let duration = workout.duration ?? 0

            let endDate = workout.date
            let startDate = endDate.addingTimeInterval(-duration)

            // Build metadata
            var metadata: [String: Any] = [
                "BetterFitWorkoutId": workout.id.uuidString,
                "BetterFitWorkoutName": workout.name,
            ]

            if #available(iOS 16.0, watchOS 9.0, *) {
                metadata[HKMetadataKeyWorkoutBrandName] = "BetterFit"
            }

            // Create HealthKit workout using HKWorkoutBuilder
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = activityType

            let builder = HKWorkoutBuilder(
                healthStore: healthStore, configuration: configuration, device: nil)

            do {
                try await builder.beginCollection(at: startDate)
                try await builder.endCollection(at: endDate)
                try await builder.addMetadata(metadata)
                try await builder.finishWorkout()
                return true
            } catch {
                print("Failed to save workout to HealthKit: \(error.localizedDescription)")
                return false
            }
        #else
            return false
        #endif
    }
}
