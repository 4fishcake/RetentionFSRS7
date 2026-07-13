import Foundation

public extension FSRS7Math {
    static func intervalDays(
        stability: Double,
        desiredRetention: Double,
        maximumIntervalDays: Double = 36_500,
        parameters: FSRS7Parameters = .officialDefault
    ) -> Double {
        guard stability.isFinite, stability > 0 else {
            return 0
        }
        
        guard desiredRetention.isFinite else {
            return 0
        }
        
        guard maximumIntervalDays.isFinite,
              maximumIntervalDays > 0 else {
            return 0
        }
        
        let minimumInterval = 1.0 / 86_400.0
        
        let maximumInterval = min(
            36_500,
            max(minimumInterval, maximumIntervalDays)
        )
        
        let safeStability = min(
            36_500,
            max(0.0001, stability)
        )
        
        let targetRetention = min(
            0.9999,
            max(0.0001, desiredRetention)
        )
        
        let minimumLogInterval = log(minimumInterval)
        let maximumLogInterval = log(maximumInterval)
        
        var logInterval = log(
            max(safeStability, 0.000_000_000_1)
        )
        
        for _ in 0..<12 {
            logInterval = min(
                maximumLogInterval,
                max(minimumLogInterval, logInterval)
            )
            
            let interval = min(
                maximumInterval,
                max(minimumInterval, exp(logInterval))
            )
            
            let result = intervalRetentionAndDerivative(
                interval: interval,
                stability: safeStability,
                parameters: parameters
            )
            
            let logDerivative = min(
                result.derivative * interval,
                -0.000_000_000_001
            )
            
            logInterval -= (
                result.retention - targetRetention
            ) / logDerivative
        }
        
        logInterval = min(
            maximumLogInterval,
            max(minimumLogInterval, logInterval)
        )
        
        return min(
            maximumInterval,
            max(minimumInterval, exp(logInterval))
        )
    }
    
    private static func intervalRetentionAndDerivative(
        interval: Double,
        stability: Double,
        parameters: FSRS7Parameters
    ) -> (
        retention: Double,
        derivative: Double
    ) {
        let decay1 = -max(
            0.0001,
            parameters[27]
        )
        
        let decay2 = -max(
            0.0001,
            parameters[28]
        )
        
        let base1 = max(
            0.0001,
            parameters[29]
        )
        
        let base2 = max(
            0.0001,
            parameters[30]
        )
        
        let baseWeight1 = max(
            0.0001,
            parameters[31]
        )
        
        let baseWeight2 = max(
            0.0001,
            parameters[32]
        )
        
        let stabilityWeightPower1 = parameters[33]
        let stabilityWeightPower2 = parameters[34]
        
        let factor1 = pow(
            base1,
            1 / decay1
        ) - 1
        
        let factor2 = pow(
            base2,
            1 / decay2
        ) - 1
        
        let intervalOverStability = interval
            / stability
        
        let inner1 = max(
            0.000_000_001,
            1 + factor1 * intervalOverStability
        )
        
        let inner2 = max(
            0.000_000_001,
            1 + factor2 * intervalOverStability
        )
        
        let retention1 = pow(
            inner1,
            decay1
        )
        
        let retention2 = pow(
            inner2,
            decay2
        )
        
        let weight1 = baseWeight1
            * pow(
                stability,
                -stabilityWeightPower1
            )
        
        let weight2 = baseWeight2
            * pow(
                stability,
                stabilityWeightPower2
            )
        
        let totalWeight = max(
            0.000_000_001,
            weight1 + weight2
        )
        
        let retention = (
            weight1 * retention1
            + weight2 * retention2
        ) / totalWeight
        
        let derivative1 = decay1
            * pow(inner1, decay1 - 1)
            * factor1
            / stability
        
        let derivative2 = decay2
            * pow(inner2, decay2 - 1)
            * factor2
            / stability
        
        let derivative = (
            weight1 * derivative1
            + weight2 * derivative2
        ) / totalWeight
        
        return (
            retention: min(
                1,
                max(0, retention)
            ),
            derivative: min(0, derivative)
        )
    }
}
