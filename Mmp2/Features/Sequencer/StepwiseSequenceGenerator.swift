//
//  StepwiseSequenceGenerator.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/5/26.
//

import Foundation

struct StepwiseSequenceGenerator: SequenceGenerator {
    let progression: PlaybackProgression
    
    func generateSequence() -> [TempoStep] {
        var sequence: [TempoStep] = []
        var tempo = progression.start
        let max = progression.max
        let step = progression.increment
        let timesToPlayStep = progression.timesToPlayEach
        var done = false
        
        repeat {
            for i in 0..<timesToPlayStep {
                sequence.append(
                    TempoStep(
                        tempo: Float(tempo),
                        tempoIndex: i + 1,
                        tempoCount: timesToPlayStep,
                        sequenceIndex: 0,
                        sequenceOccurrence: 0))
            }
            
            if tempo < max {
                tempo = min(tempo + step, max)
            } else {
                done = true
            }
        } while !done
        
        return sequence
    }
}
