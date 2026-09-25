//
//  DefaultSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/24/26.
//

import Foundation

@Observable
class DefaultSequencer: PlayRateSequencer {
    var currentRate: Float = 1.0
    
    func nextRate() -> Float? {
        return currentRate
    }
    
    func reset() {
        return
    }
    
    
}
