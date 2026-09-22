//
//  ConstantSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Foundation

struct ConstantPlayRateSequencer: PlayRateSequencer {
    private var rate: Double? = nil
    private var rates: [Double] = []
    private var index: Int? = nil
    
    init(rate: Double, timesToPlay: Int?) {
        if let timesToPlay {
            rates = Array(repeating: rate, count: timesToPlay)
            index = 0
        } else {
            self.rate = rate
        }
    }
    
    mutating func nextRate() -> Double? {
        if let rate {
            return rate
        } else {
            defer { index! += 1 }
            guard let index else { return nil }
            if index >= rates.count { return nil }
            return rates[index]
        }
    }
    
    mutating func reset() {
        index? = 0
    }
}
