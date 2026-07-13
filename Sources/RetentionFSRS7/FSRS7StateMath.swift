import Foundation

public extension FSRS7Math {
    static func initialStability(
        for rating: FSRS7Rating,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        let value = parameters[rating.rawValue - 1]
        return clampedStability(value)
    }
    
    static func initialDifficulty(
        for rating: FSRS7Rating,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        let ratingValue = Double(rating.rawValue)
        
        let value = parameters[4]
            - exp(parameters[5] * (ratingValue - 1))
            + 1
        
        return clampedDifficulty(value)
    }
    
    static func difficultyAfterReview(
        currentDifficulty: Double,
        rating: FSRS7Rating,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        guard currentDifficulty.isFinite else {
            return initialDifficulty(
                for: rating,
                parameters: parameters
            )
        }
        
        let oldDifficulty = clampedDifficulty(
            currentDifficulty
        )
        
        let ratingValue = Double(rating.rawValue)
        
        let difficultyChange = -parameters[6]
            * (ratingValue - 3)
        
        let dampedChange = difficultyChange
            * (10 - oldDifficulty)
            / 9
        
        let changedDifficulty = oldDifficulty
            + dampedChange
        
        let easyInitialDifficulty = initialDifficulty(
            for: .easy,
            parameters: parameters
        )
        
        let revertedDifficulty = 0.01
            * easyInitialDifficulty
            + 0.99
            * changedDifficulty
        
        return clampedDifficulty(revertedDifficulty)
    }
    
    static func stabilityAfterReview(
        elapsedDays: Double,
        stability: Double,
        difficulty: Double,
        rating: FSRS7Rating,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        guard elapsedDays.isFinite else {
            return 0
        }
        
        guard stability.isFinite, stability > 0 else {
            return 0
        }
        
        guard difficulty.isFinite else {
            return 0
        }
        
        let elapsed = max(0, elapsedDays)
        let oldStability = clampedStability(stability)
        let oldDifficulty = clampedDifficulty(difficulty)
        
        let retrievability = retrievability(
            elapsedDays: elapsed,
            stability: oldStability,
            parameters: parameters
        )
        
        let longTermStability = componentStability(
            baseIndex: 7,
            stability: oldStability,
            difficulty: oldDifficulty,
            retrievability: retrievability,
            rating: rating,
            parameters: parameters
        )
        
        let shortTermStability = componentStability(
            baseIndex: 16,
            stability: oldStability,
            difficulty: oldDifficulty,
            retrievability: retrievability,
            rating: rating,
            parameters: parameters
        )
        
        let transitionValue = 1
            - parameters[26]
            * exp(-parameters[25] * elapsed)
        
        let transition = min(
            1,
            max(0, transitionValue)
        )
        
        let value = transition
            * longTermStability
            + (1 - transition)
            * shortTermStability
        
        return clampedStability(value)
    }
    
    private static func componentStability(
        baseIndex: Int,
        stability: Double,
        difficulty: Double,
        retrievability: Double,
        rating: FSRS7Rating,
        parameters: FSRS7Parameters
    ) -> Double {
        let failureStability = parameters[baseIndex + 3]
            * pow(
                difficulty,
                -parameters[baseIndex + 4]
            )
            * (
                pow(
                    stability + 1,
                    parameters[baseIndex + 5]
                )
                - 1
            )
            * exp(
                (1 - retrievability)
                * parameters[baseIndex + 6]
            )
        
        let postLapseStability = min(
            stability,
            failureStability
        )
        
        guard rating != .again else {
            return postLapseStability
        }
        
        let hardPenalty = rating == .hard
            ? parameters[baseIndex + 7]
            : 1
        
        let easyBonus = rating == .easy
            ? parameters[baseIndex + 8]
            : 1
        
        let stabilityIncrease = 1
            + exp(parameters[baseIndex] - 1.5)
            * (11 - difficulty)
            * pow(
                stability,
                -parameters[baseIndex + 1]
            )
            * (
                exp(
                    (1 - retrievability)
                    * parameters[baseIndex + 2]
                )
                - 1
            )
            * hardPenalty
            * easyBonus
        
        return max(
            postLapseStability,
            stability * stabilityIncrease
        )
    }
    
    private static func clampedDifficulty(
        _ value: Double
    ) -> Double {
        guard value.isFinite else {
            return 1
        }
        
        return min(10, max(1, value))
    }
    
    private static func clampedStability(
        _ value: Double
    ) -> Double {
        guard value.isFinite else {
            return 0.0001
        }
        
        return min(
            36_500,
            max(0.0001, value)
        )
    }
}
