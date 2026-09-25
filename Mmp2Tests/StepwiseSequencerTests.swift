//
//  StepwiseSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/23/26.
//

import Testing

struct StepwiseSequencerTests {

    @Test func rateStepsOncePerRate() async throws {
        let playback = Playback()
        let playbackStepwise = PlaybackStepwise(start: 90, step: 2, max: 100, timesToPlay: 1, playback: playback)
        playback.playbackStepwise = playbackStepwise
        var sequencer = try SequencerFactory.createSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        var rate = sequencer.nextRate()
        while rate != nil {
            actual.append(rate!)
            rate = sequencer.nextRate()
        }
        let expected: [Float] = [0.9, 0.92, 0.94, 0.96, 0.98, 1.0]
        #expect(actual == expected)
    }

    @Test func rateStepsTwicePerRate() async throws {
        let playback = Playback()
        let playbackStepwise = PlaybackStepwise(start: 90, step: 2, max: 100, timesToPlay: 2, playback: playback)
        playback.playbackStepwise = playbackStepwise
        var sequencer = try SequencerFactory.createSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        var rate = sequencer.nextRate()
        while rate != nil {
            actual.append(rate!)
            rate = sequencer.nextRate()
        }
        let expected: [Float] = [0.9, 0.9, 0.92, 0.92, 0.94, 0.94, 0.96, 0.96, 0.98, 0.98, 1.0, 1.0]
        #expect(actual == expected)
    }

}
