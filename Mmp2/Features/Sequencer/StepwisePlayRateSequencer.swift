//
//  StepwisePlayRateSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/23/26.
//

import Foundation
import SwiftData

@Observable
class StepwisePlayRateSequencer: PlayRateSequencer {
    var index: Int = 0
    var rates: [Float] = []
    let bpm: Int?
    
    init(stepwise: PlaybackStepwise, bpm: Int?) throws {
        self.bpm = bpm
        
        var divisor: Float
        
        if let bpm {
            divisor = Float(bpm)
        } else {
            divisor = Float(100)
        }
        
        var current = stepwise.start
        var rate: Float
        rate = Float(current) / divisor
        appendRate(rate: rate, count: stepwise.timesToPlay)
        
        while current < stepwise.max {
            current = min(current + stepwise.step, stepwise.max)
            rate = Float(current) / divisor
            appendRate(rate: rate, count: stepwise.timesToPlay)
        }
        
        currentRate = rates[0]
    }
    
    private func appendRate(rate: Float, count: Int) {
        for _ in 0..<count {
            rates.append(rate)
        }
    }
    
    var currentRate: Float = 0
    
    var displayRate: String {
        if let bpm {
            let currentBpm = Int((Float(bpm) * currentRate).rounded())
            return "\(currentBpm) BPM"
        } else {
            return currentRate.formatted(.percent.precision(.fractionLength(0)))
        }
    }

    func nextRate() -> Float? {
        if index >= rates.count {
            return nil
        } else {
            defer { index += 1 }
            currentRate = rates[index]
            return currentRate
        }
    }
    
    func reset() {
        index = 0
    }
    
    
}
