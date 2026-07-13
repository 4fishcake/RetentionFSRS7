import XCTest
@testable import RetentionFSRS7

final class FSRS7SchedulerTests: XCTestCase {
    private let referenceDate = Date(
        timeIntervalSince1970: 1_700_000_000
    )
    
    func testFirstGoodReviewInitializesCard() {
        let scheduler = FSRS7Scheduler()
        let originalCard = FSRS7Card(
            due: referenceDate
        )
        
        let reviewedCard = scheduler.review(
            originalCard,
            rating: .good,
            at: referenceDate,
            responseSeconds: 2.5
        )
        
        XCTAssertEqual(
            reviewedCard.stability,
            4.1283,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            reviewedCard.difficulty,
            4.194_588_083_372_719,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            reviewedCard.state,
            .review
        )
        
        XCTAssertEqual(
            reviewedCard.reviewCount,
            1
        )
        
        XCTAssertEqual(
            reviewedCard.lapseCount,
            0
        )
        
        XCTAssertEqual(
            reviewedCard.lastReview,
            referenceDate
        )
        
        XCTAssertEqual(
            reviewedCard.reviewHistory.count,
            1
        )
        
        XCTAssertEqual(
            reviewedCard.reviewHistory[0].rating,
            .good
        )
        
        XCTAssertEqual(
            reviewedCard.reviewHistory[0].responseSeconds,
            2.5,
            accuracy: 0.000_000_000_001
        )
        
        let interval = reviewedCard.due
            .timeIntervalSince(referenceDate)
            / 86_400
        
        XCTAssertEqual(
            interval,
            2.966_927_162_372_141,
            accuracy: 0.000_000_000_1
        )
        
        XCTAssertEqual(
            originalCard.state,
            .new
        )
        
        XCTAssertEqual(
            originalCard.reviewCount,
            0
        )
    }
    
    func testRetrievabilityAtDueDateMatchesTarget() {
        let scheduler = FSRS7Scheduler(
            desiredRetention: 0.9
        )
        
        let reviewedCard = scheduler.review(
            FSRS7Card(due: referenceDate),
            rating: .good,
            at: referenceDate
        )
        
        let retrievability = scheduler.retrievability(
            of: reviewedCard,
            at: reviewedCard.due
        )
        
        XCTAssertEqual(
            retrievability,
            0.9,
            accuracy: 0.000_000_000_1
        )
    }
    
    func testAgainAfterReviewCreatesRelearningCard() {
        let scheduler = FSRS7Scheduler()
        
        let firstReview = scheduler.review(
            FSRS7Card(due: referenceDate),
            rating: .good,
            at: referenceDate
        )
        
        let secondReviewDate = referenceDate
            .addingTimeInterval(86_400)
        
        let failedReview = scheduler.review(
            firstReview,
            rating: .again,
            at: secondReviewDate,
            responseSeconds: 4
        )
        
        XCTAssertEqual(
            failedReview.stability,
            0.792_737_360_313_514,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            failedReview.difficulty,
            8.347_017_296_104_067,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            failedReview.state,
            .relearning
        )
        
        XCTAssertEqual(
            failedReview.reviewCount,
            2
        )
        
        XCTAssertEqual(
            failedReview.lapseCount,
            1
        )
        
        XCTAssertEqual(
            failedReview.reviewHistory.count,
            2
        )
        
        let interval = failedReview.due
            .timeIntervalSince(secondReviewDate)
            / 86_400
        
        XCTAssertEqual(
            interval,
            0.018_073_274_405_992,
            accuracy: 0.000_000_000_1
        )
    }
    
    func testAgainOnNewCardUsesLearningState() {
        let scheduler = FSRS7Scheduler()
        
        let reviewedCard = scheduler.review(
            FSRS7Card(due: referenceDate),
            rating: .again,
            at: referenceDate
        )
        
        XCTAssertEqual(
            reviewedCard.state,
            .learning
        )
        
        XCTAssertEqual(
            reviewedCard.stability,
            0.041,
            accuracy: 0.000_000_000_001
        )
        
        XCTAssertEqual(
            reviewedCard.lapseCount,
            0
        )
    }
}
