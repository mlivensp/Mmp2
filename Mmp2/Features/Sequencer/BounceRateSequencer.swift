//
//  BounceRateSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/8/26.
//

import Foundation

@Observable
final class BounceRateSequencer: PlayRateSequencer {
    var index: Int = 0
    var rates: [Float] = []
    let bpm: Int?
    
    init(bounce: PlaybackBounce, bpm: Int?) throws {
        self.bpm = bpm
        
        var divisor: Float
        
        if let bpm {
            divisor = Float(bpm)
        } else {
            divisor = Float(100)
        }
        
        let slowTempos = (bounce.playOrder?.slowOrder ?? 1, Array(repeating: bounce.slowTempo, count: bounce.timesToPlaySlowTempo))
        let midTempos = (bounce.playOrder?.midOrder ?? 2, Array(repeating: bounce.midTempo, count: bounce.timesToPlayMidTempo))
        let fastTempos = (bounce.playOrder?.fastOrder ?? 3, Array(repeating: bounce.fastTempo, count: bounce.timesToPlayFastTempo))
        
        let oneBounce = [slowTempos, midTempos, fastTempos]
            .sorted(by: { $0.0 < $1.0 } )
            .map(\.1)
            .flatMap{ $0 }
        rates = Array(repeating: oneBounce, count: bounce.numberOfBounces)
            .flatMap { $0 }
            .map { Float($0) / divisor }
        
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
