//
//  PlaybackBounceViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/4/26.
//

import Testing
@testable import Mmp2

@Suite("PlaybackBounceViewModel")
struct PlaybackBounceViewModelTests {

    @Test("init maps values to strings and internal numeric state")
    func initMapsValuesToStringsAndState() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 2,
            midTempo: 80,
            midTempoTimesToPlay: 3,
            fastTempo: 100,
            fastTempoTimesToPlay: 4,
            numberOfBounces: 5
        )

        #expect(vm.slowTempoString == "60")
        #expect(vm.slowTempoTimesToPlayString == "2")
        #expect(vm.midTempoString == "80")
        #expect(vm.midTempoTimesToPlayString == "3")
        #expect(vm.fastTempoString == "100")
        #expect(vm.fastTempoTimesToPlayString == "4")
        #expect(vm.numberOfBouncesString == "5")

        #expect(vm.slowTempo == 60)
        #expect(vm.slowTempoTimesToPlay == 2)
        #expect(vm.midTempo == 80)
        #expect(vm.midTempoTimesToPlay == 3)
        #expect(vm.fastTempo == 100)
        #expect(vm.fastTempoTimesToPlay == 4)
        #expect(vm.numberOfBounces == 5)
    }

    @Test("slow tempo accepts positive numeric input")
    func slowTempoAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.slowTempoString = "72"

        #expect(vm.slowTempoString == "72")
        #expect(vm.slowTempo == 72)
    }

    @Test("slow tempo rejects zero and preserves previous numeric state")
    func slowTempoRejectsZero() {
        let vm = makeDefaultVM()
        let original = vm.slowTempo

        vm.slowTempoString = "0"

        #expect(vm.slowTempoString == "0")
        #expect(vm.slowTempo == original)
    }

    @Test("slow tempo rejects negative number and preserves previous numeric state")
    func slowTempoRejectsNegative() {
        let vm = makeDefaultVM()
        let original = vm.slowTempo

        vm.slowTempoString = "-10"

        #expect(vm.slowTempoString == "-10")
        #expect(vm.slowTempo == original)
    }

    @Test("slow tempo rejects non-numeric and preserves previous numeric state")
    func slowTempoRejectsNonNumeric() {
        let vm = makeDefaultVM()
        let original = vm.slowTempo

        vm.slowTempoString = "abc"

        #expect(vm.slowTempoString == "abc")
        #expect(vm.slowTempo == original)
    }

    @Test("mid tempo accepts positive numeric input")
    func midTempoAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.midTempoString = "88"

        #expect(vm.midTempoString == "88")
        #expect(vm.midTempo == 88)
    }

    @Test("mid tempo rejects zero and preserves previous numeric state")
    func midTempoRejectsZero() {
        let vm = makeDefaultVM()
        let original = vm.midTempo

        vm.midTempoString = "0"

        #expect(vm.midTempoString == "0")
        #expect(vm.midTempo == original)
    }

    @Test("fast tempo accepts positive numeric input")
    func fastTempoAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.fastTempoString = "144"

        #expect(vm.fastTempoString == "144")
        #expect(vm.fastTempo == 144)
    }

    @Test("fast tempo rejects empty input and preserves previous numeric state")
    func fastTempoRejectsEmptyInput() {
        let vm = makeDefaultVM()
        let original = vm.fastTempo

        vm.fastTempoString = ""

        #expect(vm.fastTempoString == "")
        #expect(vm.fastTempo == original)
    }

    @Test("slow times-to-play accepts empty and sets value to zero")
    func slowTimesToPlayAcceptsEmptyAndSetsZero() {
        let vm = makeDefaultVM()

        vm.slowTempoTimesToPlayString = ""

        #expect(vm.slowTempoTimesToPlayString == "")
        #expect(vm.slowTempoTimesToPlay == 0)
    }

    @Test("slow times-to-play accepts numeric input")
    func slowTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.slowTempoTimesToPlayString = "7"

        #expect(vm.slowTempoTimesToPlayString == "7")
        #expect(vm.slowTempoTimesToPlay == 7)
    }

    @Test("slow times-to-play rejects non-numeric and preserves previous numeric state")
    func slowTimesToPlayRejectsNonNumeric() {
        let vm = makeDefaultVM()
        let original = vm.slowTempoTimesToPlay

        vm.slowTempoTimesToPlayString = "x"

        #expect(vm.slowTempoTimesToPlayString == "x")
        #expect(vm.slowTempoTimesToPlay == original)
    }

    @Test("mid times-to-play accepts numeric input")
    func midTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.midTempoTimesToPlayString = "6"

        #expect(vm.midTempoTimesToPlayString == "6")
        #expect(vm.midTempoTimesToPlay == 6)
    }

    @Test("fast times-to-play accepts numeric input")
    func fastTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.fastTempoTimesToPlayString = "8"

        #expect(vm.fastTempoTimesToPlayString == "8")
        #expect(vm.fastTempoTimesToPlay == 8)
    }

    @Test("number of bounces accepts positive numeric input")
    func numberOfBouncesAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.numberOfBouncesString = "9"

        #expect(vm.numberOfBouncesString == "9")
        #expect(vm.numberOfBounces == 9)
    }

    @Test("number of bounces rejects zero and preserves previous numeric state")
    func numberOfBouncesRejectsZero() {
        let vm = makeDefaultVM()
        let original = vm.numberOfBounces

        vm.numberOfBouncesString = "0"

        #expect(vm.numberOfBouncesString == "0")
        #expect(vm.numberOfBounces == original)
    }

    @Test("number of bounces rejects non-numeric and preserves previous numeric state")
    func numberOfBouncesRejectsNonNumeric() {
        let vm = makeDefaultVM()
        let original = vm.numberOfBounces

        vm.numberOfBouncesString = "bad"

        #expect(vm.numberOfBouncesString == "bad")
        #expect(vm.numberOfBounces == original)
    }

    // MARK: - Helpers

    private func makeDefaultVM() -> PlaybackBounceViewModel {
        makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
    }

    private func makeVM(
        slowTempo: Int,
        slowTempoTimesToPlay: Int,
        midTempo: Int,
        midTempoTimesToPlay: Int,
        fastTempo: Int,
        fastTempoTimesToPlay: Int,
        numberOfBounces: Int
    ) -> PlaybackBounceViewModel {
        PlaybackBounceViewModel(
            slowTempo: slowTempo,
            slowTempoTimesToPlay: slowTempoTimesToPlay,
            midTempo: midTempo,
            midTempoTimesToPlay: midTempoTimesToPlay,
            fastTempo: fastTempo,
            fastTempoTimesToPlay: fastTempoTimesToPlay,
            numberOfBounces: numberOfBounces
        )
    }
}
