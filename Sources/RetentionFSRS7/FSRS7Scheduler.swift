import Foundation

public struct FSRS7Scheduler: Sendable {
    public let parameters: FSRS7Parameters
    public let desiredRetention: Double
    public let maximumIntervalDays: Double
    
    public init(
        parameters: FSRS7Parameters = .officialDefault,
        desiredRetention: Double = 0.9,
        maximumIntervalDays: Double = 36_500
    ) {
        self.parameters = parameters
        
        if desiredRetention.isFinite {
            self.desiredRetention = min(
                0.9999,
                max(0.0001, desiredRetention)
            )
        } else {
            self.desiredRetention = 0.9
        }
        
        if maximumIntervalDays.isFinite,
           maximumIntervalDays > 0 {
            self.maximumIntervalDays = min(
                36_500,
                max(
                    1.0 / 86_400.0,
                    maximumIntervalDays
                )
            )
        } else {
            self.maximumIntervalDays = 36_500
        }
    }
    
    public func review(
        _ card: FSRS7Card,
        rating: FSRS7Rating,
        at reviewedAt: Date = Date(),
        responseSeconds: Double = 0
    ) -> FSRS7Card {
        var updatedCard = card
        
        let isNewMemory = card.state == .new
            || card.reviewCount == 0
            || !card.stability.isFinite
            || card.stability <= 0
        
        let newStability: Double
        let newDifficulty: Double
        
        if isNewMemory {
            newStability = FSRS7Math.initialStability(
                for: rating,
                parameters: parameters
            )
            
            newDifficulty = FSRS7Math.initialDifficulty(
                for: rating,
                parameters: parameters
            )
        } else {
            let elapsedDays = elapsedDays(
                from: card.lastReview,
                to: reviewedAt
            )
            
            newStability = FSRS7Math.stabilityAfterReview(
                elapsedDays: elapsedDays,
                stability: card.stability,
                difficulty: card.difficulty,
                rating: rating,
                parameters: parameters
            )
            
            newDifficulty = FSRS7Math.difficultyAfterReview(
                currentDifficulty: card.difficulty,
                rating: rating,
                parameters: parameters
            )
        }
        
        let interval = FSRS7Math.intervalDays(
            stability: newStability,
            desiredRetention: desiredRetention,
            maximumIntervalDays: maximumIntervalDays,
            parameters: parameters
        )
        
        updatedCard.stability = newStability
        updatedCard.difficulty = newDifficulty
        updatedCard.lastReview = reviewedAt
        updatedCard.due = reviewedAt.addingTimeInterval(
            interval * 86_400
        )
        updatedCard.reviewCount = card.reviewCount + 1
        
        if rating == .again,
           card.state == .review {
            updatedCard.lapseCount = card.lapseCount + 1
        }
        
        updatedCard.state = nextState(
            currentState: card.state,
            rating: rating
        )
        
        updatedCard.reviewHistory.append(
            FSRS7ReviewEvent(
                reviewedAt: reviewedAt,
                rating: rating,
                responseSeconds: responseSeconds
            )
        )
        
        return updatedCard
    }
    
    public func retrievability(
        of card: FSRS7Card,
        at date: Date = Date()
    ) -> Double {
        guard let lastReview = card.lastReview else {
            return 0
        }
        
        guard card.stability.isFinite,
              card.stability > 0 else {
            return 0
        }
        
        let elapsed = max(
            0,
            date.timeIntervalSince(lastReview)
            / 86_400
        )
        
        return FSRS7Math.retrievability(
            elapsedDays: elapsed,
            stability: card.stability,
            parameters: parameters
        )
    }
    
    public func intervalDays(
        for stability: Double
    ) -> Double {
        FSRS7Math.intervalDays(
            stability: stability,
            desiredRetention: desiredRetention,
            maximumIntervalDays: maximumIntervalDays,
            parameters: parameters
        )
    }
    
    private func elapsedDays(
        from previousReview: Date?,
        to currentReview: Date
    ) -> Double {
        guard let previousReview else {
            return 0
        }
        
        return max(
            0,
            currentReview.timeIntervalSince(previousReview)
            / 86_400
        )
    }
    
    private func nextState(
        currentState: FSRS7CardState,
        rating: FSRS7Rating
    ) -> FSRS7CardState {
        guard rating == .again else {
            return .review
        }
        
        switch currentState {
        case .new, .learning:
            return .learning
            
        case .review, .relearning:
            return .relearning
        }
    }
}
