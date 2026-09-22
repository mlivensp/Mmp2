//
//  File.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Foundation

struct SequencerFactory {
    static func createSequencer(from playback: Playback) throws -> PlayRateSequencer {
        if playback.playbackBounce == nil {
            if playback.playbackStepwise == nil {
                // create constant sequencer
                guard let playbackConstant = playback.playbackConstant else {
                    throw AppError.invalidPlayback
                }
                return ConstantPlayRateSequencer(rate: Double(playbackConstant.tempo), timesToPlay: playbackConstant.timesToPlay)
            } else {
                // TODO: create stepwise sequencer
                guard let playbackConstant = playback.playbackConstant else {
                    throw AppError.invalidPlayback
                }
                return ConstantPlayRateSequencer(rate: Double(playbackConstant.tempo), timesToPlay: playbackConstant.timesToPlay)
            }
        } else {
            // TODO: create bounce sequencer
            guard let playbackConstant = playback.playbackConstant else {
                throw AppError.invalidPlayback
            }
            return ConstantPlayRateSequencer(rate: Double(playbackConstant.tempo), timesToPlay: playbackConstant.timesToPlay)
        }
    }
}
