//
//  StepSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/5/26.
//

import Foundation

@Observable
final class StepSequencer {
    let sequence: [TempoStep]
    let isBpm: Bool
    let factor: Float
    let repeatIndefinitely: Bool
    
    var iterator: IndexingIterator<[TempoStep]>
    var currentTempoStep: TempoStep?
    var emptyList: Bool
    
    init(sequence: [TempoStep], isBpm: Bool, factor: Float, repeatIndefinitely: Bool) {
        self.sequence = sequence
        self.isBpm = isBpm
        self.factor = factor
        self.repeatIndefinitely = repeatIndefinitely
        iterator = sequence.makeIterator()
        emptyList = false
    }
    
    var current: Float {
        get { currentTempoStep?.tempo ?? 0 }
        set { }
    }
    
    var displayRate: String {
        let value = Int((current * factor).rounded())
        return isBpm ? "\(value) BPM" : "\(value)%"
    }
    
    func next() -> Float? {
        let tempoStep = iterator.next()
        
        if let tempoStep {
            emptyList = false
            currentTempoStep = tempoStep
            return current
        } else {
            if repeatIndefinitely {
                if emptyList {
                    return nil
                } else {
                    reset()
                    return next()
                }
            } else {
                return nil
            }
        }
    }
    
    func reset() {
        emptyList = true
        iterator = sequence.makeIterator()
    }
    
    
}
