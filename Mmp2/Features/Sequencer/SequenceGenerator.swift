//
//  File.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/5/26.
//

import Foundation

protocol SequenceGenerator {
    func generateSequence() -> [TempoStep]
}
