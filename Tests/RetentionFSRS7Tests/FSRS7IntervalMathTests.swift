import XCTest
@testable import RetentionFSRS7

final class FSRS7IntervalMathTests: XCTestCase {
    func testIntervalsMatchOfficialReferenceValues() {
        let expected: [
            (
                stability: Double,
                retention: Double,
                interval: Double
            )
        ] = [
            (
                5,
                0.90,
                4.258_338_872_457_895
            ),
            (
                5,
                0.95,
                0.166_262_851_303_338
            ),
            (
                5,
                0.99,
                0.000_655_040_021_688
            ),
            (
                10,
                0.90,
                13.073_393_576_179_084
            )
        ]
        
        for value in expected {
            XCTAssertEqual(
                FSRS7Math.intervalDays(
                    stability: value.stability,
                    desiredRetention: value.retention
                ),
                value.interval,
                accuracy: 0.000_000_000_1
            )
        }
    }
    
    func testCalculatedIntervalReachesDesiredRetention() {
        let stability = 5.0
        let desiredRetention = 0.9
        
        let interval = FSRS7Math.intervalDays(
            stability: stability,
            desiredRetention: desiredRetention
        )
        
        let resultingRetention = FSRS7Math.retrievability(
            elapsedDays: interval,
            stability: stability
        )
        
        XCTAssertEqual(
            resultingRetention,
            desiredRetention,
            accuracy: 0.000_000_000_1
        )
    }
    
    func testIntervalHasOneSecondMinimum() {
        let interval = FSRS7Math.intervalDays(
            stability: 0.041,
            desiredRetention: 0.99
        )
        
        XCTAssertEqual(
            interval,
            1.0 / 86_400.0,
            accuracy: 0.000_000_000_001
        )
    }
    
    func testMaximumIntervalIsRespected() {
        let interval = FSRS7Math.intervalDays(
            stability: 1_000,
            desiredRetention: 0.5,
            maximumIntervalDays: 30
        )
        
        XCTAssertEqual(
            interval,
            30,
            accuracy: 0.000_000_000_001
        )
    }
}
