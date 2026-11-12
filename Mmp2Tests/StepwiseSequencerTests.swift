//
//  StepwiseSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/23/26.
//

import Testing
@testable import Mmp2

@MainActor
struct StepwiseSequencerTests {

    @Test func rateStepsOncePerRate() async throws {
        let playback = Playback(timesToPlay: 1)
        let playbackProgression = PlaybackProgression(start: 90, increment: 2, max: 100, timesToPlayEach: 1)
        playback.playbackProgression = playbackProgression
        let sequencer = try SequencerFactory.createStepSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        var rate = sequencer.next()
        while rate != nil {
            actual.append(rate!)
            rate = sequencer.next()
        }
        let expected: [Float] = [0.9, 0.92, 0.94, 0.96, 0.98, 1.0]
        #expect(actual == expected)
    }

    @Test func rateStepsTwicePerRate() async throws {
        let playback = Playback(timesToPlay: 1)
        let playbackProgression = PlaybackProgression(start: 90, increment: 2, max: 100, timesToPlayEach: 2)
        playback.playbackProgression = playbackProgression
        let sequencer = try SequencerFactory.createStepSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        var rate = sequencer.next()
        while rate != nil {
            actual.append(rate!)
            rate = sequencer.next()
        }
        let expected: [Float] = [0.9, 0.9, 0.92, 0.92, 0.94, 0.94, 0.96, 0.96, 0.98, 0.98, 1.0, 1.0]
        #expect(actual == expected)
    }

}
