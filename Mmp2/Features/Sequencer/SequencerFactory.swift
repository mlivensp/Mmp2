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
    
    static func createSequencer(from playback: Playback, bpm: Int?) throws -> PlayRateSequencer {
        if playback.playbackBounce == nil {
            if playback.playbackStepwise == nil {
                // create constant sequencer
                guard let playbackConstant = playback.playbackConstant else {
                    throw AppError.invalidPlayback
                }
                return ConstantPlayRateSequencer(rate: playbackConstant.rate, bpm: bpm, timesToPlay: playbackConstant.timesToPlay)
            } else {
                // TODO: create stepwise sequencer
                guard let playbackStepwise = playback.playbackStepwise else {
                    throw AppError.invalidPlayback
                }
                return try StepwisePlayRateSequencer(stepwise: playbackStepwise, bpm: bpm)
            }
        } else {
            // TODO: create bounce sequencer
            guard let playbackConstant = playback.playbackConstant else {
                throw AppError.invalidPlayback
            }
            return ConstantPlayRateSequencer(rate: playbackConstant.rate, bpm: bpm, timesToPlay: playbackConstant.timesToPlay)
        }
    }
}
