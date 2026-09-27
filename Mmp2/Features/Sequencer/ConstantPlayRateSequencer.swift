//
//  ConstantSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Foundation

@Observable
class ConstantPlayRateSequencer: PlayRateSequencer {
    private var computedRate: Float
    private var rates: [Float] = []
    private var index: Int? = nil
    private var bpm: Int?
    
    init(rate: Int, bpm: Int?, timesToPlay: Int?) {
        self.bpm = bpm
        
        if let bpm {
            computedRate = Float(rate) / Float(bpm)
        } else {
            computedRate = Float(rate) / Float(100)
        }
        
        if let timesToPlay {
            rates = Array(repeating: computedRate, count: timesToPlay)
            index = 0
        }
        
        localCurrentRate = computedRate
    }
    
    private var localCurrentRate: Float = 0
    
    var currentRate: Float {
        get { return localCurrentRate }
        set {
            index = nil
            localCurrentRate = newValue
        }
    }
    
    var displayRate: String {
        if let bpm {
            let currentBpm = Int((Float(bpm) * currentRate).rounded())
            return "\(currentBpm) BPM"
        } else {
            return currentRate.formatted(.percent.precision(.fractionLength(0)))
        }
    }
    
    func nextRate() -> Float? {
        if let index {
            defer { self.index! += 1 }
            if index >= rates.count { return nil }
            localCurrentRate = rates[index]
            return currentRate
        }

        localCurrentRate = computedRate
        print("currentRate is \(currentRate)")
        return currentRate
    }
    
    func reset() {
        index? = 0
    }
}
