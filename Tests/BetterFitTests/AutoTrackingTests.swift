import XCTest
@testable import BetterFit

final class AutoTrackingTests: XCTestCase {
    
    func testStartTracking() {
        let service = AutoTrackingService()
        let workout = Workout(name: "Test Workout")
        
        service.startTracking(workout: workout)
        
        let status = service.getTrackingStatus()
        XCTAssertTrue(status.isTracking)
        XCTAssertEqual(status.currentExercise, 0)
        XCTAssertEqual(status.detectedReps, 0)
    }
    
    func testStopTracking() {
        let service = AutoTrackingService()
        let workout = Workout(name: "Test Workout")
        
        service.startTracking(workout: workout)
        service.stopTracking()
        
        let status = service.getTrackingStatus()
        XCTAssertFalse(status.isTracking)
    }
    
    func testMotionDataRepDetection() {
        let highAcceleration = MotionData(
            acceleration: [2.0, 1.5, 1.0],
            rotation: [0, 0, 0]
        )
        
        XCTAssertTrue(highAcceleration.isRepetitionDetected())
        
        let lowAcceleration = MotionData(
            acceleration: [0.1, 0.1, 0.1],
            rotation: [0, 0, 0]
        )
        
        XCTAssertFalse(lowAcceleration.isRepetitionDetected())
    }
    
    func testMotionDataRestDetection() {
        let restingData = MotionData(
            acceleration: [0.05, 0.05, 0.05],
            rotation: [0, 0, 0]
        )
        
        XCTAssertTrue(restingData.isRestPeriod())
        
        let activeData = MotionData(
            acceleration: [1.0, 1.0, 1.0],
            rotation: [0, 0, 0]
        )
        
        XCTAssertFalse(activeData.isRestPeriod())
    }
}
