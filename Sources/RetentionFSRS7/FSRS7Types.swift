import Foundation

public enum FSRS7Rating: Int, Codable, CaseIterable, Sendable {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4
}

public enum FSRS7CardState: Int, Codable, Sendable {
    case new = 0
    case learning = 1
    case review = 2
    case relearning = 3
}

public struct FSRS7ReviewEvent: Codable, Equatable, Sendable {
    public var reviewedAt: Date
    public var rating: FSRS7Rating
    public var responseSeconds: Double
    
    public init(
        reviewedAt: Date,
        rating: FSRS7Rating,
        responseSeconds: Double
    ) {
        self.reviewedAt = reviewedAt
        self.rating = rating
        self.responseSeconds = max(0, responseSeconds)
    }
}

public struct FSRS7Card: Codable, Equatable, Sendable {
    public var difficulty: Double
    public var stability: Double
    public var due: Date
    public var lastReview: Date?
    public var reviewCount: Int
    public var lapseCount: Int
    public var state: FSRS7CardState
    public var reviewHistory: [FSRS7ReviewEvent]
    
    public init(
        difficulty: Double = 0,
        stability: Double = 0,
        due: Date = Date(),
        lastReview: Date? = nil,
        reviewCount: Int = 0,
        lapseCount: Int = 0,
        state: FSRS7CardState = .new,
        reviewHistory: [FSRS7ReviewEvent] = []
    ) {
        self.difficulty = difficulty
        self.stability = stability
        self.due = due
        self.lastReview = lastReview
        self.reviewCount = max(0, reviewCount)
        self.lapseCount = max(0, lapseCount)
        self.state = state
        self.reviewHistory = reviewHistory
    }
}
