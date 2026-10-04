//
//  PlaybackStepwiseViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackStepwiseViewModel {

    var start: Int
    var step: Int
    var max: Int
    var timesToPlay: Int

    init(start: Int, step: Int, max: Int, timesToPlay: Int) {
        self.start = start
        self.step = step
        self.max = max
        self.timesToPlay = timesToPlay
    }
}
