import XCTest
@testable import RetentionFSRS7

final class FSRS7ParametersTests: XCTestCase {
    func testOfficialDefaultHasExpectedCount() {
        XCTAssertEqual(
            FSRS7Parameters.officialDefault.count,
            FSRS7Parameters.expectedCount
        )
        
        XCTAssertEqual(
            FSRS7Parameters.officialDefault.count,
            35
        )
    }
    
    func testCurrentSourceTransitionValues() {
        XCTAssertEqual(
            FSRS7Parameters.officialDefault[15],
            1.3,
            accuracy: 0.000_000_1
        )
        
        XCTAssertEqual(
            FSRS7Parameters.officialDefault[24],
            1.3,
            accuracy: 0.000_000_1
        )
    }
    
    func testRejectsIncorrectParameterCount() {
        XCTAssertThrowsError(
            try FSRS7Parameters(
                weights: [1, 2, 3]
            )
        ) { error in
            XCTAssertEqual(
                error as? FSRS7ParametersError,
                .invalidCount(
                    expected: 35,
                    actual: 3
                )
            )
        }
    }
    
    func testRejectsNonFiniteValue() {
        var weights = Array(
            repeating: 1.0,
            count: 35
        )
        
        weights[10] = .infinity
        
        XCTAssertThrowsError(
            try FSRS7Parameters(
                weights: weights
            )
        ) { error in
            XCTAssertEqual(
                error as? FSRS7ParametersError,
                .nonFiniteValue(index: 10)
            )
        }
    }
}
