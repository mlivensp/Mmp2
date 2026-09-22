//
//  PlayRateSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/21/26.
//

import Foundation

protocol PlayRateSequencer {
    mutating func nextRate() -> Double?
    mutating func reset()
}
