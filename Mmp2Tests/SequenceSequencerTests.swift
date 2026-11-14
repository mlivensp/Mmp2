//
//  SequenceSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 11/12/26.
//

@testable import Mmp2
import Testing

@Suite("SequenceSequencerTests", .serialized)
struct SequenceSequencerTests {

    @Test("sequence plays through one time")
    func sequencePlaysOnce() async throws {
        let sequences = [
            PlaybackSequence.makeDraft(playOrder: 1, value: 90, timesToPlay: 1),
            PlaybackSequence.makeDraft(playOrder: 2, value: 95, timesToPlay: 2),
            PlaybackSequence.makeDraft(playOrder: 3, value: 100, timesToPlay: 2)
        ]
        let playback = Playback.makeDraft(timesToPlay: 1)
        playback.playbackSequences = sequences
        let sequencer = try? await SequencerFactory.createStepSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        while let nextRate = await sequencer!.next() {
            actual.append(nextRate)
        }
        
        let expected: [Float] = [0.9, 0.95, 0.95, 1.0, 1.0]
        #expect(actual == expected)
    }

    @Test("sequence plays three times")
    func sequencePlaysThreeTimes() async throws {
        let sequences = [
            PlaybackSequence.makeDraft(playOrder: 1, value: 90, timesToPlay: 1),
            PlaybackSequence.makeDraft(playOrder: 2, value: 95, timesToPlay: 2),
            PlaybackSequence.makeDraft(playOrder: 3, value: 100, timesToPlay: 2)
        ]
        let playback = Playback.makeDraft(timesToPlay: 3)
        playback.playbackSequences = sequences
        let sequencer = try? await SequencerFactory.createStepSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        while let nextRate = await sequencer!.next() {
            actual.append(nextRate)
        }
        
        let expected: [Float] = [0.9, 0.95, 0.95, 1.0, 1.0, 0.9, 0.95, 0.95, 1.0, 1.0, 0.9, 0.95, 0.95, 1.0, 1.0]
        #expect(actual == expected)
    }

}
