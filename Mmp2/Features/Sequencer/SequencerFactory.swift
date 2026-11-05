//
//  File.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Foundation
import SwiftData

struct SequencerFactory {
    static func createConstantPlayRateSequencer(rate: Float, bpm: Int?) -> ConstantPlayRateSequencer {
        let intRate = Int((rate * 100).rounded())
        return ConstantPlayRateSequencer(rate: intRate, bpm: bpm, timesToPlay: nil)
    }
    
    static func createSequencer(from playback: Playback, bpm: Int?, forPlaylist: Bool = false) throws -> PlayRateSequencer {
        if playback.playbackBounce == nil {
            if playback.playbackStepwise == nil {
                // create constant sequencer
                guard let playbackConstant = playback.playbackConstant else {
                    throw AppError.invalidPlayback
                }
                var timesToPlay = playback.timesToPlay
                
                if forPlaylist {
                    if timesToPlay == nil {
                        timesToPlay = 1
                    }
                }
                
                return ConstantPlayRateSequencer(rate: playbackConstant.value, bpm: bpm, timesToPlay: timesToPlay)
            } else {
                guard let playbackStepwise = playback.playbackStepwise else {
                    throw AppError.invalidPlayback
                }
                
                // TODO: need to correct for nil timesToPlay if forPlaylist
                return try StepwisePlayRateSequencer(stepwise: playbackStepwise, bpm: bpm)
            }
        } else {
            guard let playbackBounce = playback.playbackBounce else {
                throw AppError.invalidPlayback
            }
            return try BouncePlayRateSequencer(bounce: playbackBounce, bpm: bpm)
        }
    }
}
