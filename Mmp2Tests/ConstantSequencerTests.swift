//
//  ConstantSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 9/20/26.
//

import Testing
import Mmp2
import SwiftData

struct ConstantSequencerTests {

    @Test func play10Times() async throws {
        let playback = Playback()
        let playbackConstant = PlaybackConstant(tempo: 1, timesToPlay: 10, playback: playback)
        playback.playbackConstant = playbackConstant
        var sequencer = try? SequencerFactory.createSequencer(from: playback)
        var actual: [Double] = []
        while let nextRate = sequencer!.nextRate() {
            actual.append(nextRate)
        }
        
        let expected = Array(repeating: 1.0, count: 10)
        #expect(actual == expected)
    }
    
    @Test func loop() async throws {
        let playback = Playback()
        let playbackConstant = PlaybackConstant(tempo: 1, timesToPlay: nil, playback: playback)
        playback.playbackConstant = playbackConstant
        var sequencer = try? SequencerFactory.createSequencer(from: playback)
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
}
