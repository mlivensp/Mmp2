import Testing
import SwiftData
@testable import Mmp2

@MainActor
@Suite("PlaybackEditViewModel")
struct PlaybackEditViewModelTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: SchemaV1.schema, configurations: config)
        context = ModelContext(container)
    }

    @Test("BPM changes scale constant rates and removing BPM restores percentage")
    func constantRateScalesWithBPM() {
        let playback = Playback()
        let constant = PlaybackConstant(rate: 90, timesToPlay: 1, playback: playback)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 9
        vm.bpm = 90
        #expect(vm.constantVM.rateString == "81")

        vm.bpm = nil
        #expect(vm.constantVM.rateString == "90")

        let defaultPlayback = Playback()
        let defaultConstant = PlaybackConstant(rate: 100, timesToPlay: 1, playback: defaultPlayback)
        defaultPlayback.playbackConstant = defaultConstant
        let defaultVM = PlaybackEditViewModel(playback: defaultPlayback, bpm: nil, context: context)
        defaultVM.bpm = 90
        #expect(defaultVM.constantVM.rateString == "90")
    }

    @Test("BPM changes scale stepwise start and max, but not step")
    func stepwiseRatesScaleWithBPM() {
        let playback = Playback()
        let stepwise = PlaybackStepwise(start: 100, step: 2, max: 110, timesToPlay: 1, playback: playback)
        playback.playbackStepwise = stepwise
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 90

        #expect(vm.stepwiseVM.startString == "90")
        #expect(vm.stepwiseVM.stepString == "2")
        #expect(vm.stepwiseVM.maxString == "99")
    }

    @Test("BPM changes scale all bounce tempos")
    func bounceTemposScaleWithBPM() {
        let playback = Playback()
        let bounce = PlaybackBounce(
            slowTempo: 90,
            timesToPlaySlowTempo: 1,
            midTempo: 100,
            timesToPlayMidTempo: 1,
            fastTempo: 110,
            timesToPlayFastTempo: 1,
            numberOfBounces: 1,
            playback: playback
        )
        playback.playbackBounce = bounce
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 90

        #expect(vm.bounceVM.slowTempoString == "81")
        #expect(vm.bounceVM.midTempoString == "90")
        #expect(vm.bounceVM.fastTempoString == "99")
    }
}
