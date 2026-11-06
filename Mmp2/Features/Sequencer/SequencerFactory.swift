//
//  SequencerFactory.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Foundation
import SwiftData

struct SequencerFactory {
    static func createConstantStepSequencer(value: Float, bpm: Int?) -> StepSequencer {
        let factor = Float(bpm ?? 100);
        let intValue = Int(factor * value)
        let generator = ConstantSequenceGenerator(value: intValue)
        let rawSequence = generator.generateSequence()
        let sequence = extendAndNormalizeSequence(sequence: rawSequence, repeatCount: 1, factor: factor)
        return StepSequencer(sequence: sequence, isBpm: bpm != nil, factor: factor, repeatIndefinitely: true)
    }
    
    static func createStepSequencer(from playback: Playback, bpm: Int?, forPlaylist: Bool = false) throws -> StepSequencer {
        let rawSequence = try generateSequence(playback: playback)
        
        let repeatCount = playback.timesToPlay ?? 1
        let factor = Float(bpm ?? 100)
        let sequence = extendAndNormalizeSequence(sequence: rawSequence, repeatCount: repeatCount, factor: factor)

        let repeatIndefinitely =
            !forPlaylist && playback.timesToPlay == nil
        return StepSequencer(sequence: sequence, isBpm: bpm != nil, factor: factor, repeatIndefinitely: repeatIndefinitely)
    }
    
    static private func generateSequence(playback: Playback) throws -> [TempoStep] {
        let generator = try createSequenceGenerator(playback)
        return generator.generateSequence()
    }
    
    private static func extendAndNormalizeSequence(sequence: [TempoStep], repeatCount: Int, factor: Float) -> [TempoStep] {
        return (0..<repeatCount).flatMap { repetition in
            sequence.enumerated().map { index, step in
                TempoStep(
                    tempo: step.tempo / factor,
                    tempoIndex: step.tempoIndex,
                    tempoCount: step.tempoCount,
                    sequenceIndex: index + 1,
                    sequenceOccurrence: repetition + 1
                )
            }
        }
    }
    
    private static func createSequenceGenerator(_ playback: Playback) throws -> SequenceGenerator {
        if let constant = playback.playbackConstant {
            return ConstantSequenceGenerator(value: constant.value)
        } else if let stepwise = playback.playbackStepwise {
            return StepwiseSequenceGenerator(stepwise: stepwise)
        } else if let bounce = playback.playbackBounce {
            return BounceSequenceGenerator(bounce: bounce)
        } else {
            throw AppError.invalidPlayback
        }
    }
}
