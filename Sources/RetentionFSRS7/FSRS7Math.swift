import Foundation

public enum FSRS7Math {
    public static func retrievability(
        elapsedDays: Double,
        stability: Double,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        guard elapsedDays.isFinite else {
            return 0
        }
        
        guard stability.isFinite, stability > 0 else {
            return 0
        }
        
        let t = max(0, elapsedDays)
        let tOverS = t / stability
        
        let decay1 = -parameters[27]
        let decay2 = -parameters[28]
        let base1 = parameters[29]
        let base2 = parameters[30]
        
        let retention1 = powerLawRetention(
            tOverS: tOverS,
            base: base1,
            decay: decay1
        )
        
        let retention2 = powerLawRetention(
            tOverS: tOverS,
            base: base2,
            decay: decay2
        )
        
        let weight1 = parameters[31]
            * pow(stability, -parameters[33])
        
        let weight2 = parameters[32]
            * pow(stability, parameters[34])
        
        let totalWeight = weight1 + weight2
        
        guard totalWeight.isFinite, totalWeight > 0 else {
            return 0
        }
        
        let result = (
            weight1 * retention1
            + weight2 * retention2
        ) / totalWeight
        
        guard result.isFinite else {
            return 0
        }
        
        return min(1, max(0, result))
    }
    
    private static func powerLawRetention(
        tOverS: Double,
        base: Double,
        decay: Double
    ) -> Double {
        let factor = pow(base, 1 / decay) - 1
        
        return pow(
            1 + factor * tOverS,
            decay
        )
    }
}
