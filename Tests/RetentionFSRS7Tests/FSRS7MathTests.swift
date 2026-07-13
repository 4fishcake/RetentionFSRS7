import XCTest
@testable import RetentionFSRS7

final class FSRS7MathTests: XCTestCase {
    func testRetrievabilityAtZeroElapsedTimeIsOne() {
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: 0,
                stability: 1
            ),
            1,
            accuracy: 0.000_000_000_001
        )
    }
    
    func testMatchesOfficialReferenceValues() {
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: 1,
                stability: 1
            ),
            0.834_867_995_753_214,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: 10,
                stability: 10
            ),
            0.911_030_434_988_129,
            accuracy: 0.000_000_000_001
        )
    }
    
    func testRetrievabilityDecreasesOverTime() {
        let earlier = FSRS7Math.retrievability(
            elapsedDays: 1,
            stability: 5
        )
        
        let later = FSRS7Math.retrievability(
            elapsedDays: 30,
            stability: 5
        )
        
        XCTAssertGreaterThan(earlier, later)
    }
    
    func testNonPositiveStabilityReturnsZero() {
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: 1,
                stability: 0
            ),
            0
        )
        
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: 1,
                stability: -1
            ),
            0
        )
    }
    
    func testNegativeElapsedTimeUsesZeroDays() {
        XCTAssertEqual(
            FSRS7Math.retrievability(
                elapsedDays: -1,
                stability: 1
            ),
            1,
            accuracy: 0.000_000_000_001
        )
    }
}
