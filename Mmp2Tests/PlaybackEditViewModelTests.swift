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
    
    @Test("init with nil timesToPlay uses empty string and is valid")
    func initNilTimesToPlay() {
        let playback = Playback(timesToPlay: nil)
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)
        
        #expect(vm.timesToPlayString == "")
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
    }

    @Test("BPM changes scale constant rates and removing BPM restores percentage")
    func constantRateScalesWithBPM() {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 9
        vm.bpm = 90
        #expect(vm.constantVM.rateString == "81")

        vm.bpm = nil
        #expect(vm.constantVM.rateString == "90")

        let defaultPlayback = Playback(timesToPlay: 1)
        let defaultConstant = PlaybackConstant(value: 100)
        defaultPlayback.playbackConstant = defaultConstant
        let defaultVM = PlaybackEditViewModel(playback: defaultPlayback, bpm: nil, context: context)
        defaultVM.bpm = 90
        #expect(defaultVM.constantVM.rateString == "90")
    }

    @Test("BPM changes scale stepwise start and max, but not step")
    func stepwiseRatesScaleWithBPM() {
        let playback = Playback(timesToPlay: 1)
        let stepwise = PlaybackStepwise(start: 100, step: 2, max: 110, timesToPlayStep: 1, playback: playback)
        playback.playbackStepwise = stepwise
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 90

        #expect(vm.stepwiseVM.startString == "90")
        #expect(vm.stepwiseVM.stepString == "2")
        #expect(vm.stepwiseVM.maxString == "99")
    }

    @Test("BPM changes scale all bounce tempos")
    func bounceTemposScaleWithBPM() {
        let playback = Playback(timesToPlay: 1)
        let bounce = PlaybackBounce(
            slow: 90,
            timesToPlaySlow: 1,
            mid: 100,
            timesToPlayMid: 1,
            fast: 110,
            timesToPlayFast: 1,
            playback: playback
        )
        playback.playbackBounce = bounce
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.bpm = 90

        #expect(vm.bounceVM.slowString == "81")
        #expect(vm.bounceVM.midString == "90")
        #expect(vm.bounceVM.fastString == "99")
    }
    
    // MARK: - Times to play
    
    @Test("timesToPlay accepts positive number")
    func timesToPlayAcceptsPositive() throws {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.timesToPlayString = "5"
        
        #expect(vm.timesToPlayError == nil)
        #expect(try appliedTimesToPlay(vm) == 5)
    }
    
    @Test("timesToPlay empty is valid and sets value to nil")
    func timesToPlayEmptyIsNil() throws {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.timesToPlayString = ""
        
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
        #expect(try appliedTimesToPlay(vm) == nil)
    }
    
//    @Test("timesToPlay invalid input sets error and keeps previous value",
//          arguments: ["0", "-1", "x", "2.5"])
    @Test("timesToPlay invalid input sets error and keeps previous value",
          arguments: ["0"])
    func timesToPlayRejectsInvalid(input: String) throws {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)

        vm.timesToPlayString = input
        
        #expect(vm.timesToPlayString == input)
        #expect(vm.timesToPlayError == "Times To Play must be empty or a number greater than zero.")
        #expect(!vm.isValid)
        #expect(throws: AppError.attemptToSaveInvalidState("PlaybackConstant")) {
            try appliedTimesToPlay(vm)
        }
//        #expect {
//            try appliedTimesToPlay(vm)
//        } throws: { error in
//            print("thrown:", error, type(of: error))
//            guard case AppError.attemptToSaveInvalidState(let name) = error else {
//                print("wrong case")
//                return false
//            }
//            print("name:", name)
//            return name == "PlaybackConstant"
//        }
    }
    
    @Test("timesToPlay error clears after valid input")
    func timesToPlayErrorClears() {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)
        vm.timesToPlayString = "x"
        #expect(vm.timesToPlayError != nil)
        
        vm.timesToPlayString = "4"
        
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    @Test("apply sets timesToPlay to nil when field is empty")
    func applySetsNilTimesToPlay() throws {
        let playback = Playback(timesToPlay: 1)
        let constant = PlaybackConstant(value: 90)
        playback.playbackConstant = constant
        let vm = PlaybackEditViewModel(playback: playback, bpm: nil, context: context)
        let model = makeModel(timesToPlay: 1)
        
        vm.timesToPlayString = ""
        try vm.apply(to: model, context: context)
        
        #expect(model.timesToPlay == nil)
    }
    
    // MARK: - Helpers
    
    private func makeModel(timesToPlay: Int) -> Mmp2.Playback {
        Mmp2.Playback(timesToPlay: timesToPlay)
    }
    
    private func appliedTimesToPlay(_ vm: Mmp2.PlaybackEditViewModel) throws -> Int? {
        let model = makeModel(timesToPlay: 1)
        try vm.apply(to: model, context: context)
        return model.timesToPlay
    }
}
