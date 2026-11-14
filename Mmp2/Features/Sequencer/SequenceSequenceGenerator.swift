//
//  SequenceSequenceGenerator.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/12/26.
//

import Foundation

struct SequenceSequenceGenerator: SequenceGenerator {
    let sequences: [PlaybackSequence]
    
    func generateSequence() -> [TempoStep] {
        var result: [TempoStep] = []
        for sequence in sequences {
            let timesToPlay = sequence.timesToPlay ?? 1
            for i in 0..<timesToPlay {
                result.append(
                    TempoStep(
                        tempo: Float(sequence.value),
                        tempoIndex: i + 1,
                        tempoCount: timesToPlay,
                        sequenceIndex: 0,
                        sequenceOccurrence: 0))
            }
        }
        
        return result
    }
}
