import Foundation

public enum FSRS7ParametersError: Error, Equatable, Sendable {
    case invalidCount(expected: Int, actual: Int)
    case nonFiniteValue(index: Int)
}

public struct FSRS7Parameters: Codable, Equatable, Sendable {
    public static let algorithmVersion = "FSRS-7"
    public static let expectedCount = 35
    
    public let weights: [Double]
    
    public init(weights: [Double]) throws {
        guard weights.count == Self.expectedCount else {
            throw FSRS7ParametersError.invalidCount(
                expected: Self.expectedCount,
                actual: weights.count
            )
        }
        
        if let invalidIndex = weights.firstIndex(
            where: { !$0.isFinite }
        ) {
            throw FSRS7ParametersError.nonFiniteValue(
                index: invalidIndex
            )
        }
        
        self.weights = weights
    }
    
    private init(uncheckedWeights: [Double]) {
        self.weights = uncheckedWeights
    }
    
    public static let officialDefault = FSRS7Parameters(
        uncheckedWeights: [
            // 0...3: 초기 안정성
            0.0410,
            2.4175,
            4.1283,
            11.9709,
            
            // 4...6: 난이도
            5.6385,
            0.4468,
            3.2620,
            
            // 7...15: 장기 안정성
            2.3054,
            0.1688,
            1.3325,
            0.3524,
            0.0049,
            0.7503,
            0.0896,
            0.6625,
            1.3000,
            
            // 16...24: 단기 안정성
            0.8820,
            0.3072,
            3.5875,
            0.3030,
            0.0107,
            0.2279,
            2.6413,
            0.5594,
            1.3000,
            
            // 25...26: 장기·단기 전환 함수
            2.5000,
            1.0000,
            
            // 27...34: 망각곡선
            0.0723,
            0.1634,
            0.5000,
            0.9555,
            0.2245,
            0.6232,
            0.1362,
            0.3862
        ]
    )
    
    public var count: Int {
        weights.count
    }
    
    public subscript(index: Int) -> Double {
        weights[index]
    }
}
