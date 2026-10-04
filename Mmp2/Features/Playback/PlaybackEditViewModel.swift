//
//  PlaybackEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackEditViewModel {
    var bpm: Int?
    
    var mode: PlaybackMode
    var constantVM: PlaybackConstantViewModel?
    var stepwiseVM: PlaybackStepwiseViewModel?
    var bounceVM: PlaybackBounceViewModel?
    
    init(playback: Playback, bpm: Int?) {
        self.bpm = bpm
        
        if let constant = playback.playbackConstant {
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel(
                rate: constant.rate,
                timesToPlay: constant.timesToPlay
            )
        } else if let stepwise = playback.playbackStepwise {
            self.mode = .stepwise
            self.stepwiseVM = PlaybackStepwiseViewModel(start: stepwise.start, step: stepwise.step, max: stepwise.max, timesToPlay: stepwise.timesToPlay)
        } else if let bounce = playback.playbackBounce {
            self.mode = .bounce
            self.bounceVM = PlaybackBounceViewModel(slowTempo: bounce.slowTempo, slowTempoTimesToPlay: bounce.timesToPlaySlowTempo, midTempo: bounce.midTempo, midTempoTimesToPlay: bounce.timesToPlayMidTempo, fastTempo: bounce.fastTempo, fastTempoTimesToPlay: bounce.timesToPlayFastTempo, numberOfBounces: bounce.numberOfBounces)
        } else {
            // default mode for new clips
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel(rate: 100, timesToPlay: nil)
        }
    }
    
    func apply(to playback: Playback) {
        
    }
}
