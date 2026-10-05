//
//  ConstantSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Testing
import SwiftData
@testable import Mmp2

struct ConstantSequencerTests {

    @Test func play10Times() async throws {
        let playback = Playback()
        let playbackConstant = PlaybackConstant(rate: 100, timesToPlay: 10, playback: playback)
        playback.playbackConstant = playbackConstant
        let sequencer = try? SequencerFactory.createSequencer(from: playback, bpm: nil)
        var actual: [Float] = []
        while let nextRate = sequencer!.nextRate() {
            actual.append(nextRate)
        }
        
        let expected = Array(repeating: Float(1.0), count: 10)
        #expect(actual == expected)
    }
    
    @Test func loop() async throws {
        let playback = Playback()
        let playbackConstant = PlaybackConstant(rate: 1, timesToPlay: nil, playback: playback)
        playback.playbackConstant = playbackConstant
        let sequencer = try? SequencerFactory.createSequencer(from: playback, bpm: nil)
        var actual = 0
        let timesToLoop = 100
        for _ in 0..<100 {
            if let _ = sequencer!.nextRate() {
                actual += 1
            }
        }
        
        let expected = timesToLoop
        #expect(actual == expected)
    }
    
    @Test func bpmOnceNormalSpeed() async throws {
        let playback = Playback()
        let playbackConstant = PlaybackConstant(rate: 72, timesToPlay: 1, playback: playback)
        playback.playbackConstant = playbackConstant
        let sequencer = try? SequencerFactory.createSequencer(from: playback, bpm: 72)
        var actual: [Float] = []
        while let nextRate = sequencer!.nextRate() {
            actual.append(nextRate)
        }
        
        let expected = Array(repeating: Float(1.0), count: 1)
        #expect(actual == expected)
    }
}
