//
//  PlaybackEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation
import SwiftData

@Observable
final class PlaybackEditViewModel {
    var bpm: Int? {
        didSet {
            guard oldValue != bpm else { return }
            let previousBpm = oldValue ?? 100
            let currentBpm = bpm ?? 100
            guard previousBpm > 0, currentBpm > 0 else { return }

            let factor = Double(currentBpm) / Double(previousBpm)
            constantVM.scaleRate(by: factor)
            stepwiseVM.scaleRates(by: factor)
            bounceVM.scaleTempos(by: factor)
        }
    }
    var context: ModelContext
    
    var mode: PlaybackMode
    var constantVM: PlaybackConstantViewModel
    var stepwiseVM: PlaybackStepwiseViewModel
    var bounceVM: PlaybackBounceViewModel
    
    init(playback: Playback, bpm: Int?, context: ModelContext) {
        self.bpm = bpm
        self.context = context
        
        if let constant = playback.playbackConstant {
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel(
                rate: constant.rate,
                timesToPlay: constant.timesToPlay
            )
            self.stepwiseVM = PlaybackStepwiseViewModel.default()
            self.bounceVM = PlaybackBounceViewModel.default()
        } else if let stepwise = playback.playbackStepwise {
            self.mode = .stepwise
            self.stepwiseVM = PlaybackStepwiseViewModel(start: stepwise.start, step: stepwise.step, max: stepwise.max, timesToPlay: stepwise.timesToPlay)
            self.constantVM = PlaybackConstantViewModel.default()
            self.bounceVM = PlaybackBounceViewModel.default()
        } else if let bounce = playback.playbackBounce {
            self.mode = .bounce
            self.bounceVM = PlaybackBounceViewModel(slowTempo: bounce.slowTempo, slowTempoTimesToPlay: bounce.timesToPlaySlowTempo, midTempo: bounce.midTempo, midTempoTimesToPlay: bounce.timesToPlayMidTempo, fastTempo: bounce.fastTempo, fastTempoTimesToPlay: bounce.timesToPlayFastTempo, numberOfBounces: bounce.numberOfBounces, playOrder: bounce.playOrder)
            self.constantVM = PlaybackConstantViewModel.default()
            self.stepwiseVM = PlaybackStepwiseViewModel.default()
        } else {
            // default mode for new clips
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel.default()
            self.stepwiseVM = PlaybackStepwiseViewModel.default()
            self.bounceVM = PlaybackBounceViewModel.default()
        }
    }

    func apply(to playback: Playback, context: ModelContext) throws {
        // 1. Switch mode (handles deletion + creation)
        playback.switchMode(to: mode, context: context)

        // 2. Apply values to the active submodel
        switch mode {
        case .constant:
            try constantVM.apply(to: playback.playbackConstant!)
        case .stepwise:
            try stepwiseVM.apply(to: playback.playbackStepwise!)
        case .bounce:
            try bounceVM.apply(to: playback.playbackBounce!)
        }
    }
}

func scaledPlaybackValue(_ value: Double) -> Int {
    let scaledValue = value.rounded()
    guard scaledValue.isFinite else { return value }
    if scaledValue >= Double(Int.max) { return Int.max }
    return max(1, Int(scaledValue))
}
