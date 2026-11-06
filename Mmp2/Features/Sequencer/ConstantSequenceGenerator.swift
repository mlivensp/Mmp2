//
//  ConstantSequenceGenerator.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/5/26.
//

import Foundation

struct ConstantSequenceGenerator: SequenceGenerator {
    let value: Int
    
    func generateSequence() -> [TempoStep] {
        [TempoStep(
            tempo: Float(value),
            tempoIndex: 1,
            tempoCount: 1,
            sequenceIndex: 1,
            sequenceOccurrence: 1)]
    }
}
