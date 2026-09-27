//
//  PlayRateSequencer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/21/26.
//

import Foundation

protocol PlayRateSequencer {
    var currentRate: Float { get set }
    var displayRate: String { get }
    func nextRate() -> Float?
    func reset()
}
