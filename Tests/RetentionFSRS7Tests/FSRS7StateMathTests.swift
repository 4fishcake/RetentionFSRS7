import XCTest
@testable import RetentionFSRS7

final class FSRS7StateMathTests: XCTestCase {
    func testInitialStabilityMatchesOfficialWeights() {
        let expected: [(FSRS7Rating, Double)] = [
            (.again, 0.041),
            (.hard, 2.4175),
            (.good, 4.1283),
            (.easy, 11.9709)
        ]
        
        for (rating, value) in expected {
            XCTAssertEqual(
                FSRS7Math.initialStability(
                    for: rating
                ),
                value,
                accuracy: 0.000_000_000_001
            )
        }
    }
    
    func testInitialDifficultyMatchesOfficialFormula() {
        let expected: [(FSRS7Rating, Double)] = [
            (
                .again,
                5.638_500_000_000_000
            ),
            (
                .hard,
                5.075_198_392_303_237
            ),
            (
                .good,
                4.194_588_083_372_719
            ),
            (
                .easy,
                2.817_928_571_667_297
            )
        ]
        
        for (rating, value) in expected {
            XCTAssertEqual(
                FSRS7Math.initialDifficulty(
                    for: rating
                ),
                value,
                accuracy: 0.000_000_000_001
            )
        }
    }
    
    func testDifficultyAfterReviewMatchesOfficialFormula() {
        let expected: [(FSRS7Rating, Double)] = [
            (
                .again,
                8.566_379_285_716_673
            ),
            (
                .hard,
                6.772_279_285_716_673
            ),
            (
                .good,
                4.978_179_285_716_673
            ),
            (
                .easy,
                3.184_079_285_716_673
            )
        ]
        
        for (rating, value) in expected {
            XCTAssertEqual(
                FSRS7Math.difficultyAfterReview(
                    currentDifficulty: 5,
                    rating: rating
                ),
                value,
                accuracy: 0.000_000_000_001
            )
        }
    }
    
    func testStabilityAfterReviewMatchesOfficialFormula() {
        let expected: [(FSRS7Rating, Double)] = [
            (
                .again,
                0.930_356_208_169_119
            ),
            (
                .hard,
                8.062_098_933_073_294
            ),
            (
                .good,
                9.656_679_953_321_841
            ),
            (
                .easy,
                11.053_683_939_318_395
            )
        ]
        
        for (rating, value) in expected {
            XCTAssertEqual(
                FSRS7Math.stabilityAfterReview(
                    elapsedDays: 1,
                    stability: 5,
                    difficulty: 5,
                    rating: rating
                ),
                value,
                accuracy: 0.000_000_000_001
            )
        }
    }
}
