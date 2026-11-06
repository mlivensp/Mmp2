//
//  BounceRateSequencerTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/8/26.
//

import Testing
@testable import Mmp2

@Suite("BounceRateSequencer")
struct BounceRateSequencerTests {

    // MARK: - Helpers

    private func makeOrder(slow: Int = 1, mid: Int = 2, fast: Int = 3) -> PlayOrder {
        PlayOrder(name: "test", slowOrder: slow, midOrder: mid, fastOrder: fast, sortOrder: 0)
    }

    private func makeBounce(
        timesToPlay: Int = 1,
        slow: Int = 60, slowTimes: Int = 2,
        mid: Int = 80, midTimes: Int = 3,
        fast: Int = 100, fastTimes: Int = 1,
        order: PlayOrder? = nil
    ) -> Playback {
        let playback = Playback(timesToPlay: timesToPlay)
        playback.playbackBounce = PlaybackBounce(
            slow: slow, timesToPlaySlow: slowTimes,
            mid: mid, timesToPlayMid: midTimes,
            fast: fast, timesToPlayFast: fastTimes,
            playOrder: order ?? makeOrder(),
            playback: nil
        )
        
        return playback
    }

    /// Drains the sequencer until nextRate() returns nil.
    private func drain(_ stepSequencer: StepSequencer) -> [Float] {
        var result: [Float] = []
        var sequencer = stepSequencer
        while let rate = sequencer.next() {
            result.append(rate)
            if result.count > 10_000 { break } // safety
        }
        return result
    }

    private func pct(_ values: [Int], divisor: Float = 100) -> [Float] {
        values.map { Float($0) / divisor }
    }

    // MARK: - Basic sequencing (all non-zero)

    @Test("default order plays slow, mid, fast with repeat counts")
    func defaultOrder() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([60, 60, 80, 80, 80, 100]))
    }

    @Test("custom play order reorders segments")
    func customOrder() throws {
        // mid first, fast second, slow last
        let order = makeOrder(slow: 3, mid: 1, fast: 2)
        let playbackBounce = makeBounce(order: order)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([80, 80, 80, 100, 60, 60]))
    }

    @Test("fast, mid, slow order")
    func reverseOrder() throws {
        let order = makeOrder(slow: 3, mid: 2, fast: 1)
        let playbackBounce = makeBounce(order: order)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([100, 80, 80, 80, 60, 60]))
    }

    // MARK: - Exactly one timesToPlay is zero

    @Test("slow timesToPlay zero skips slow tempo")
    func slowZero() throws {
        let playbackBounce = makeBounce(slowTimes: 0, midTimes: 2, fastTimes: 3)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([80, 80, 100, 100, 100]))
    }

    @Test("mid timesToPlay zero skips mid tempo")
    func midZero() throws {
        let playbackBounce = makeBounce(slowTimes: 2, midTimes: 0, fastTimes: 3)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([60, 60, 100, 100, 100]))
    }

    @Test("fast timesToPlay zero skips fast tempo")
    func fastZero() throws {
        let playbackBounce = makeBounce(slowTimes: 2, midTimes: 3, fastTimes: 0)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([60, 60, 80, 80, 80]))
    }
// TODO: this is a decent test but needs playback.timesToPlay
//    @Test("zero slow count with multiple bounces repeats remaining segments")
//    func slowZeroMultipleBounces() throws {
//        let bounce = makeBounce(slowTimes: 0, midTimes: 1, fastTimes: 2, bounces: 2)
//        let sut = try BounceStepSequencer(bounce: bounce, bpm: nil)
//        #expect(drain(sut) == pct([80, 100, 100, 80, 100, 100]))
//    }

    @Test("zero count segment is skipped regardless of play order")
    func zeroWithCustomOrder() throws {
        // order: fast, slow, mid; mid skipped
        let order = makeOrder(slow: 2, mid: 3, fast: 1)
        let playbackBounce = makeBounce(slowTimes: 2, midTimes: 0, fastTimes: 1, order: order)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(drain(sut) == pct([100, 60, 60]))
    }
    
    // TODO: this is a decent test but needs playback.timesToPlay
//    @Test("each single zero position yields correct total count",
//          arguments: [(0, 2, 3), (2, 0, 3), (2, 3, 0)])
//    func zeroPositionsTotalCount(times: (Int, Int, Int)) throws {
//        let bounce = makeBounce(slowTimes: times.0, midTimes: times.1, fastTimes: times.2, bounces: 4)
//        let sut = try BounceStepSequencer(bounce: bounce, bpm: nil)
//        let nonZeroSum = times.0 + times.1 + times.2
//        #expect(drain(sut).count == nonZeroSum * 4)
//    }

    // MARK: - BPM

    @Test("bpm is used as divisor")
    func bpmDivisor() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: 120)
        #expect(drain(sut) == pct([60, 60, 80, 80, 80, 100], divisor: 120))
    }

    @Test("displayRate shows percent when bpm is nil")
    func displayRatePercent() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        _ = sut.next()
        #expect(sut.displayRate == "60%")
        _ = sut.next()
        #expect(sut.displayRate == "60%")
    }

    @Test("displayRate shows BPM when bpm is set")
    func displayRateBpm() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: 120)
        _ = sut.next()
        #expect(sut.displayRate == "60 BPM")
        _ = sut.next() // 60
        _ = sut.next() // 60
        _ = sut.next() // 80
        #expect(sut.displayRate == "80 BPM")
    }

    // MARK: - currentRate / nextRate / reset

    @Test("currentRate starts at first rate before nextRate is called")
    func initialCurrentRate() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        _ = sut.next()
        #expect(sut.current == 0.6)
    }

    @Test("currentRate starts at first non-zero segment when slow is zero")
    func initialCurrentRateSlowZero() throws {
        let playbackBounce = makeBounce(slowTimes: 0, midTimes: 2, fastTimes: 2)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        _ = sut.next()
        #expect(sut.current == 0.8)
    }

    @Test("nextRate updates currentRate")
    func nextRateUpdatesCurrent() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        let first = sut.next()
        #expect(sut.current == first)
    }

    @Test("nextRate returns nil when exhausted and keeps returning nil")
    func exhausted() throws {
        let playbackBounce = makeBounce(slowTimes: 1, midTimes: 1, fastTimes: 0)
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        #expect(sut.next() != nil)
        #expect(sut.next() != nil)
        #expect(sut.next() == nil)
        #expect(sut.next() == nil)
    }

    @Test("reset restarts the sequence")
    func resetRestarts() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        let first = drain(sut)
        sut.reset()
        let second = drain(sut)
        #expect(first == second)
        #expect(!second.isEmpty)
    }

    @Test("reset mid-sequence returns to first rate")
    func resetMidSequence() throws {
        let playbackBounce = makeBounce()
        let sut = try SequencerFactory.createStepSequencer(from: playbackBounce, bpm: nil)
        _ = sut.next()
        _ = sut.next()
        _ = sut.next()
        sut.reset()
        #expect(sut.next() == 0.6)
    }
}
