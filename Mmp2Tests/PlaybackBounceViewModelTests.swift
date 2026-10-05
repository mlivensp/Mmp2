//
//  PlaybackBounceViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/4/26.
//

import Testing
@testable import Mmp2
import SwiftData

@MainActor
@Suite("PlaybackBounceViewModel")
struct PlaybackBounceViewModelTests {
    let container: ModelContainer
    let context: ModelContext
    
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: SchemaV1.schema,
            configurations: config
        )
        context = ModelContext(container)
    }

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
    
    // MARK: - Cross-field validation: slowTempo < midTempo < fastTempo
    
    @Test("tempos: valid when slowTempo < midTempo < fastTempo")
    func tempoOrderingValid() {
        let playOrder = PlayOrder(name: "Test", slowOrder: 1, midOrder: 2, fastOrder: 3, sortOrder: 1)
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4,
            playOrder: playOrder
        )
        
        #expect(vm.isValid)
        #expect(vm.slowTempoError == nil)
        #expect(vm.midTempoError == nil)
        #expect(vm.fastTempoError == nil)
    }
    
    @Test("tempos: invalid when slowTempo >= midTempo")
    func tempoOrderingInvalidSlowGeMid() {
        let vm = makeVM(
            slowTempo: 80,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        #expect(!vm.isValid)
        #expect(vm.midTempoError == "Mid Tempo must be greater than Slow Tempo.")
    }
    
    @Test("tempos: invalid when midTempo >= fastTempo")
    func tempoOrderingInvalidMidGeFast() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 100,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        #expect(!vm.isValid)
        #expect(vm.fastTempoError == "Fast Tempo must be greater than Mid Tempo.")
    }
    
    @Test("tempos: error clears when slowTempo is increased")
    func tempoOrderingErrorClearsViaSlow() {
        let vm = makeVM(
            slowTempo: 80,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        #expect(vm.midTempoError != nil)
        
        vm.slowTempoString = "60"
        
        #expect(vm.midTempoError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempos: error clears when midTempo is increased")
    func tempoOrderingErrorClearViaMid() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 100,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        #expect(vm.fastTempoError != nil)
        
        vm.midTempoString = "80"
        
        #expect(vm.fastTempoError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempos: skipped when any tempo fails field validation")
    func tempoOrderingSkippedWhenFieldInvalid() {
        let vm = makeDefaultVM()
        
        vm.slowTempoString = "abc"
        
        #expect(vm.slowTempoError != nil)
        #expect(vm.midTempoError == nil)
        #expect(vm.fastTempoError == nil)
        #expect(!vm.isValid)
    }
    
    // MARK: - Cross-field validation: Tempo optional only if its timesToPlay is 0/empty
    
    @Test("tempo optional: slowTempo can be empty if slowTempoTimesToPlay is empty")
    func slowTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.slowTempoString = ""
        vm.slowTempoTimesToPlayString = ""
        
        #expect(vm.slowTempoError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: midTempo can be empty if midTempoTimesToPlay is empty")
    func midTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.midTempoString = ""
        vm.midTempoTimesToPlayString = ""
        
        #expect(vm.midTempoError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: fastTempo can be empty if fastTempoTimesToPlay is empty")
    func fastTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.fastTempoString = ""
        vm.fastTempoTimesToPlayString = ""
        
        #expect(vm.fastTempoError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: slowTempo invalid if empty but slowTempoTimesToPlay is not 0/empty")
    func slowTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.slowTempoString = ""
        
        #expect(vm.slowTempoError == "Slow Tempo can only be empty if Slow Tempo Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: midTempo invalid if empty but midTempoTimesToPlay is not 0/empty")
    func midTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.midTempoString = ""
        
        #expect(vm.midTempoError == "Mid Tempo can only be empty if Mid Tempo Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: fastTempo invalid if empty but fastTempoTimesToPlay is not 0/empty")
    func fastTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.fastTempoString = ""
        
        #expect(vm.fastTempoError == "Fast Tempo can only be empty if Fast Tempo Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: error clears when timesToPlay is set to empty")
    func tempoOptionalErrorClearsWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        vm.slowTempoString = ""
        #expect(vm.slowTempoError != nil)
        
        vm.slowTempoTimesToPlayString = ""
        
        #expect(vm.slowTempoError == nil)
        #expect(vm.isValid)
    }
    
    // MARK: - Cross-field validation: Only one timesToPlay can be 0 or empty
    
    @Test("timesToPlay count: valid when exactly one is 0/empty")
    func timesToPlayCountValidOneEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 0,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        #expect(vm.isValid)
        #expect(vm.slowTempoTimesToPlayError == nil)
        #expect(vm.midTempoTimesToPlayError == nil)
        #expect(vm.fastTempoTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: valid when none are 0/empty")
    func timesToPlayCountValidNoneEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 1,
            midTempo: 80,
            midTempoTimesToPlay: 2,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        #expect(vm.isValid)
        #expect(vm.slowTempoTimesToPlayError == nil)
        #expect(vm.midTempoTimesToPlayError == nil)
        #expect(vm.fastTempoTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: invalid when two are 0/empty")
    func timesToPlayCountInvalidTwoEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 0,
            midTempo: 80,
            midTempoTimesToPlay: 0,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        
        #expect(!vm.isValid)
        #expect(vm.slowTempoTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.midTempoTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.fastTempoTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: invalid when all three are 0/empty")
    func timesToPlayCountInvalidAllEmpty() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 0,
            midTempo: 80,
            midTempoTimesToPlay: 0,
            fastTempo: 100,
            fastTempoTimesToPlay: 0,
            numberOfBounces: 4
        )
        
        #expect(!vm.isValid)
        #expect(vm.slowTempoTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.midTempoTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.fastTempoTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
    }
    
    @Test("timesToPlay count: error clears when extra empty is set to value")
    func timesToPlayCountErrorClearsWhenValueSet() {
        let vm = makeVM(
            slowTempo: 60,
            slowTempoTimesToPlay: 0,
            midTempo: 80,
            midTempoTimesToPlay: 0,
            fastTempo: 100,
            fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        #expect(vm.slowTempoTimesToPlayError != nil)
        #expect(vm.midTempoTimesToPlayError != nil)
        
        vm.slowTempoTimesToPlayString = "1"
        
        #expect(vm.slowTempoTimesToPlayError == nil)
        #expect(vm.midTempoTimesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    @Test("isValid is false when any single field has an error")
    func isValidFalseWithAnyError() {
        let vm = makeDefaultVM()
        #expect(vm.isValid)
        
        vm.slowTempoString = "bad"
        #expect(!vm.isValid)
        
        vm.slowTempoString = "60"
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: slowTempoError fully clears when timesToPlay becomes empty")
    func slowTempoErrorClearsAfterTimesToPlayEmptied() {
        let vm = makeDefaultVM()   // slow 60 / ttp 1
        
        vm.slowTempoString = ""
        #expect(vm.slowTempoError == "Slow Tempo can only be empty if Slow Tempo Times To Play is empty or zero.")
        
        vm.slowTempoTimesToPlayString = ""
        
        #expect(vm.slowTempoError == nil)
        #expect(vm.slowTempo == 0)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: invalid text keeps field-level error even when timesToPlay is empty")
    func invalidTempoTextKeepsFieldError() {
        let vm = makeDefaultVM()
        vm.slowTempoTimesToPlayString = ""
        
        vm.slowTempoString = "abc"
        
        #expect(vm.slowTempoError == "Slow Tempo must be a number greater than zero.")
    }
    
    @Test("tempo ordering: skips empty mid and compares slow to fast")
    func orderingSkipsEmptyMid() {
        let vm = makeVM(
            slowTempo: 100, slowTempoTimesToPlay: 1,
            midTempo: 80, midTempoTimesToPlay: 0,
            fastTempo: 60, fastTempoTimesToPlay: 3,
            numberOfBounces: 4
        )
        vm.midTempoString = ""
        
        #expect(vm.midTempoError == nil)
        #expect(vm.fastTempoError == "Fast Tempo must be greater than Slow Tempo.")
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
            numberOfBounces: 4,
        )
    }

    private func makeVM(
        slowTempo: Int,
        slowTempoTimesToPlay: Int,
        midTempo: Int,
        midTempoTimesToPlay: Int,
        fastTempo: Int,
        fastTempoTimesToPlay: Int,
        numberOfBounces: Int,
        playOrder: PlayOrder? = nil
    ) -> PlaybackBounceViewModel {
        PlaybackBounceViewModel(
            slowTempo: slowTempo,
            slowTempoTimesToPlay: slowTempoTimesToPlay,
            midTempo: midTempo,
            midTempoTimesToPlay: midTempoTimesToPlay,
            fastTempo: fastTempo,
            fastTempoTimesToPlay: fastTempoTimesToPlay,
            numberOfBounces: numberOfBounces,
            playOrder: playOrder == nil ? PlayOrder.default() : playOrder,
            context: context
        )
    }
}
