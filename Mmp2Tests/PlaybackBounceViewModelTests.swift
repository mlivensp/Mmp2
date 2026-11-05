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
            slow: 60,
            slowTimesToPlay: 2,
            mid: 80,
            midTimesToPlay: 3,
            fast: 100,
            fastTimesToPlay: 4,
        )

        #expect(vm.slowString == "60")
        #expect(vm.slowTimesToPlayString == "2")
        #expect(vm.midString == "80")
        #expect(vm.midTimesToPlayString == "3")
        #expect(vm.fastString == "100")
        #expect(vm.fastTimesToPlayString == "4")

        #expect(vm.slow == 60)
        #expect(vm.slowTimesToPlay == 2)
        #expect(vm.mid == 80)
        #expect(vm.midTimesToPlay == 3)
        #expect(vm.fast == 100)
        #expect(vm.fastTimesToPlay == 4)
    }

    @Test("slow accepts positive numeric input")
    func slowAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.slowString = "72"

        #expect(vm.slowString == "72")
        #expect(vm.slow == 72)
    }

    @Test("slow rejects zero and preserves previous numeric state")
    func slowRejectsZero() {
        let vm = makeDefaultVM()
        let original = vm.slow

        vm.slowString = "0"

        #expect(vm.slowString == "0")
        #expect(vm.slow == original)
    }

    @Test("slow rejects negative number and preserves previous numeric state")
    func slowRejectsNegative() {
        let vm = makeDefaultVM()
        let original = vm.slow

        vm.slowString = "-10"

        #expect(vm.slowString == "-10")
        #expect(vm.slow == original)
    }

    @Test("slow rejects non-numeric and preserves previous numeric state")
    func slowRejectsNonNumeric() {
        let vm = makeDefaultVM()
        let original = vm.slow

        vm.slowString = "abc"

        #expect(vm.slowString == "abc")
        #expect(vm.slow == original)
    }

    @Test("mid accepts positive numeric input")
    func midAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.midString = "88"

        #expect(vm.midString == "88")
        #expect(vm.mid == 88)
    }

    @Test("mid rejects zero and preserves previous numeric state")
    func midRejectsZero() {
        let vm = makeDefaultVM()
        let original = vm.mid

        vm.midString = "0"

        #expect(vm.midString == "0")
        #expect(vm.mid == original)
    }

    @Test("fast accepts positive numeric input")
    func fastAcceptsPositiveNumericInput() {
        let vm = makeDefaultVM()

        vm.fastString = "144"

        #expect(vm.fastString == "144")
        #expect(vm.fast == 144)
    }

    @Test("fast rejects empty input and preserves previous numeric state")
    func fastRejectsEmptyInput() {
        let vm = makeDefaultVM()
        let original = vm.fast

        vm.fastString = ""

        #expect(vm.fastString == "")
        #expect(vm.fast == original)
    }

    @Test("slow times-to-play accepts empty and sets value to zero")
    func slowTimesToPlayAcceptsEmptyAndSetsZero() {
        let vm = makeDefaultVM()

        vm.slowTimesToPlayString = ""

        #expect(vm.slowTimesToPlayString == "")
        #expect(vm.slowTimesToPlay == 0)
    }

    @Test("slow times-to-play accepts numeric input")
    func slowTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.slowTimesToPlayString = "7"

        #expect(vm.slowTimesToPlayString == "7")
        #expect(vm.slowTimesToPlay == 7)
    }

    @Test("slow times-to-play rejects non-numeric and preserves previous numeric state")
    func slowTimesToPlayRejectsNonNumeric() {
        let vm = makeDefaultVM()
        let original = vm.slowTimesToPlay

        vm.slowTimesToPlayString = "x"

        #expect(vm.slowTimesToPlayString == "x")
        #expect(vm.slowTimesToPlay == original)
    }

    @Test("mid times-to-play accepts numeric input")
    func midTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.midTimesToPlayString = "6"

        #expect(vm.midTimesToPlayString == "6")
        #expect(vm.midTimesToPlay == 6)
    }

    @Test("fast times-to-play accepts numeric input")
    func fastTimesToPlayAcceptsNumericInput() {
        let vm = makeDefaultVM()

        vm.fastTimesToPlayString = "8"

        #expect(vm.fastTimesToPlayString == "8")
        #expect(vm.fastTimesToPlay == 8)
    }
    // MARK: - Cross-field validation: slow < mid < fast
    
    @Test("tempos: valid when slow < mid < fast")
    func tempoOrderingValid() {
        let playOrder = PlayOrder(name: "Test", slowOrder: 1, midOrder: 2, fastOrder: 3, sortOrder: 1)
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3,
            playOrder: playOrder
        )
        
        #expect(vm.isValid)
        #expect(vm.slowError == nil)
        #expect(vm.midError == nil)
        #expect(vm.fastError == nil)
    }
    
    @Test("tempos: invalid when slow >= mid")
    func tempoOrderingInvalidSlowGeMid() {
        let vm = makeVM(
            slow: 80,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        #expect(!vm.isValid)
        #expect(vm.midError == "Mid must be greater than Slow.")
    }
    
    @Test("tempos: invalid when mid >= fast")
    func tempoOrderingInvalidMidGeFast() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 100,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        #expect(!vm.isValid)
        #expect(vm.fastError == "Fast must be greater than Mid.")
    }
    
    @Test("tempos: error clears when slow is increased")
    func tempoOrderingErrorClearsViaSlow() {
        let vm = makeVM(
            slow: 80,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        #expect(vm.midError != nil)
        
        vm.slowString = "60"
        
        #expect(vm.midError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempos: error clears when mid is increased")
    func tempoOrderingErrorClearViaMid() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 100,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        #expect(vm.fastError != nil)
        
        vm.midString = "80"
        
        #expect(vm.fastError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempos: skipped when any tempo fails field validation")
    func tempoOrderingSkippedWhenFieldInvalid() {
        let vm = makeDefaultVM()
        
        vm.slowString = "abc"
        
        #expect(vm.slowError != nil)
        #expect(vm.midError == nil)
        #expect(vm.fastError == nil)
        #expect(!vm.isValid)
    }
    
    // MARK: - Cross-field validation: Tempo optional only if its timesToPlay is 0/empty
    
    @Test("tempo optional: slow can be empty if slowTimesToPlay is empty")
    func slowTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.slowString = ""
        vm.slowTimesToPlayString = ""
        
        #expect(vm.slowError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: mid can be empty if midTimesToPlay is empty")
    func midTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.midString = ""
        vm.midTimesToPlayString = ""
        
        #expect(vm.midError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: fast can be empty if fastTimesToPlay is empty")
    func fastTempoOptionalWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.fastString = ""
        vm.fastTimesToPlayString = ""
        
        #expect(vm.fastError == nil)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: slow invalid if empty but slowTimesToPlay is not 0/empty")
    func slowTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.slowString = ""
        
        #expect(vm.slowError == "Slow can only be empty if Slow Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: mid invalid if empty but midTimesToPlay is not 0/empty")
    func midTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.midString = ""
        
        #expect(vm.midError == "Mid can only be empty if Mid Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: fast invalid if empty but fastTimesToPlay is not 0/empty")
    func fastTempoRequiredWhenTimesToPlayHasValue() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.fastString = ""
        
        #expect(vm.fastError == "Fast can only be empty if Fast Times To Play is empty or zero.")
        #expect(!vm.isValid)
    }
    
    @Test("tempo optional: error clears when timesToPlay is set to empty")
    func tempoOptionalErrorClearsWhenTimesToPlayEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        vm.slowString = ""
        #expect(vm.slowError != nil)
        
        vm.slowTimesToPlayString = ""
        
        #expect(vm.slowError == nil)
        #expect(vm.isValid)
    }
    
    // MARK: - Cross-field validation: Only one timesToPlay can be 0 or empty
    
    @Test("timesToPlay count: valid when exactly one is 0/empty")
    func timesToPlayCountValidOneEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 0,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        #expect(vm.isValid)
        #expect(vm.slowTimesToPlayError == nil)
        #expect(vm.midTimesToPlayError == nil)
        #expect(vm.fastTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: valid when none are 0/empty")
    func timesToPlayCountValidNoneEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        #expect(vm.isValid)
        #expect(vm.slowTimesToPlayError == nil)
        #expect(vm.midTimesToPlayError == nil)
        #expect(vm.fastTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: invalid when two are 0/empty")
    func timesToPlayCountInvalidTwoEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 0,
            mid: 80,
            midTimesToPlay: 0,
            fast: 100,
            fastTimesToPlay: 3
        )
        
        #expect(!vm.isValid)
        #expect(vm.slowTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.midTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.fastTimesToPlayError == nil)
    }
    
    @Test("timesToPlay count: invalid when all three are 0/empty")
    func timesToPlayCountInvalidAllEmpty() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 0,
            mid: 80,
            midTimesToPlay: 0,
            fast: 100,
            fastTimesToPlay: 0
        )
        
        #expect(!vm.isValid)
        #expect(vm.slowTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.midTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
        #expect(vm.fastTimesToPlayError == "Only one tempo can have empty or zero Times To Play.")
    }
    
    @Test("timesToPlay count: error clears when extra empty is set to value")
    func timesToPlayCountErrorClearsWhenValueSet() {
        let vm = makeVM(
            slow: 60,
            slowTimesToPlay: 0,
            mid: 80,
            midTimesToPlay: 0,
            fast: 100,
            fastTimesToPlay: 3
        )
        #expect(vm.slowTimesToPlayError != nil)
        #expect(vm.midTimesToPlayError != nil)
        
        vm.slowTimesToPlayString = "1"
        
        #expect(vm.slowTimesToPlayError == nil)
        #expect(vm.midTimesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    @Test("isValid is false when any single field has an error")
    func isValidFalseWithAnyError() {
        let vm = makeDefaultVM()
        #expect(vm.isValid)
        
        vm.slowString = "bad"
        #expect(!vm.isValid)
        
        vm.slowString = "60"
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: slowError fully clears when timesToPlay becomes empty")
    func slowErrorClearsAfterTimesToPlayEmptied() {
        let vm = makeDefaultVM()   // slow 60 / ttp 1
        
        vm.slowString = ""
        #expect(vm.slowError == "Slow can only be empty if Slow Times To Play is empty or zero.")
        
        vm.slowTimesToPlayString = ""
        
        #expect(vm.slowError == nil)
        #expect(vm.slow == 0)
        #expect(vm.isValid)
    }
    
    @Test("tempo optional: invalid text keeps field-level error even when timesToPlay is empty")
    func invalidTempoTextKeepsFieldError() {
        let vm = makeDefaultVM()
        vm.slowTimesToPlayString = ""
        
        vm.slowString = "abc"
        
        #expect(vm.slowError == "Slow must be a number greater than zero.")
    }
    
    @Test("tempo ordering: skips empty mid and compares slow to fast")
    func orderingSkipsEmptyMid() {
        let vm = makeVM(
            slow: 100, slowTimesToPlay: 1,
            mid: 80, midTimesToPlay: 0,
            fast: 60, fastTimesToPlay: 3
        )
        vm.midString = ""
        
        #expect(vm.midError == nil)
        #expect(vm.fastError == "Fast must be greater than Slow.")
    }

    // MARK: - Helpers

    private func makeDefaultVM() -> PlaybackBounceViewModel {
        makeVM(
            slow: 60,
            slowTimesToPlay: 1,
            mid: 80,
            midTimesToPlay: 2,
            fast: 100,
            fastTimesToPlay: 3
        )
    }

    private func makeVM(
        slow: Int,
        slowTimesToPlay: Int,
        mid: Int,
        midTimesToPlay: Int,
        fast: Int,
        fastTimesToPlay: Int,
        playOrder: PlayOrder? = nil
    ) -> PlaybackBounceViewModel {
        PlaybackBounceViewModel(
            slow: slow,
            slowTimesToPlay: slowTimesToPlay,
            mid: mid,
            midTimesToPlay: midTimesToPlay,
            fast: fast,
            fastTimesToPlay: fastTimesToPlay,
            playOrder: playOrder == nil ? makePlayOrder() : playOrder
        )
    }
    
    private func makePlayOrder() -> PlayOrder {
        PlayOrder(name: "test", slowOrder: 1, midOrder: 2, fastOrder: 3, sortOrder: 1)
    }

    // MARK: - apply(to:)

    @Test("apply copies values to PlaybackBounce when valid")
    func applyCopiesValues() throws {
        let vm = makeVM(
            slow: 60, slowTimesToPlay: 1,
            mid: 80, midTimesToPlay: 2,
            fast: 100, fastTimesToPlay: 3
        )
        let playOrder = makePlayOrder()
        let model = PlaybackBounce(
            slow: 1, timesToPlaySlow: 2,
            mid: 3, timesToPlayMid: 4,
            fast: 5, timesToPlayFast: 6,
            playOrder: playOrder
        )

        vm.slowString = "70"
        vm.slowTimesToPlayString = "8"
        vm.midString = "90"
        vm.midTimesToPlayString = "6"
        vm.fastString = "110"
        vm.fastTimesToPlayString = "5"
        vm.playOrder = playOrder

        try vm.apply(to: model)
        #expect(model.slow == 70)
        #expect(model.timesToPlaySlow == 8)
        #expect(model.mid == 90)
        #expect(model.timesToPlayMid == 6)
        #expect(model.fast == 110)
        #expect(model.timesToPlayFast == 5)
        #expect(model.playOrder === playOrder)
    }

    @Test("apply throws and leaves model untouched when state is invalid")
    func applyThrowsWhenInvalid() {
        let vm = makeDefaultVM()
        let playOrder = makePlayOrder()
        let model = PlaybackBounce(
            slow: 10, timesToPlaySlow: 2,
            mid: 15, timesToPlayMid: 3,
            fast: 20, timesToPlayFast: 4,
            playOrder: playOrder
        )
        vm.slowString = "bad" // invalid input

        #expect(throws: Error.self) {
            try vm.apply(to: model)
        }
        // Model should be unchanged
        #expect(model.slow == 10)
        #expect(model.timesToPlaySlow == 2)
        #expect(model.mid == 15)
        #expect(model.timesToPlayMid == 3)
        #expect(model.fast == 20)
        #expect(model.timesToPlayFast == 4)
        #expect(model.playOrder === playOrder)
    }

    @Test("apply allows empty tempo when timesToPlay is zero")
    func applyAllowsEmptyTempoIfTimesToPlayZero() throws {
        let vm = makeVM(
            slow: 60, slowTimesToPlay: 1,
            mid: 80, midTimesToPlay: 2,
            fast: 100, fastTimesToPlay: 0
        )
        let playOrder = makePlayOrder()
        let model = PlaybackBounce(
            slow: 1, timesToPlaySlow: 2,
            mid: 3, timesToPlayMid: 4,
            fast: 5, timesToPlayFast: 6,
            playOrder: playOrder
        )
        vm.fastString = ""
        vm.fastTimesToPlayString = "0"

        try vm.apply(to: model)
        #expect(model.fast == 0)
        #expect(model.timesToPlayFast == 0)
    }

    @Test("apply throws and does not modify model if more than one timesToPlay is zero")
    func applyThrowsIfMultipleTimesToPlayZero() {
        let vm = makeVM(
            slow: 60, slowTimesToPlay: 0,
            mid: 80, midTimesToPlay: 0,
            fast: 100, fastTimesToPlay: 3
        )
        let playOrder = makePlayOrder()
        let model = PlaybackBounce(
            slow: 1, timesToPlaySlow: 2,
            mid: 3, timesToPlayMid: 4,
            fast: 5, timesToPlayFast: 6,
            playOrder: playOrder
        )
        vm.slowString = ""
        vm.slowTimesToPlayString = "0"
        vm.midString = ""
        vm.midTimesToPlayString = "0"

        #expect(throws: Error.self) {
            try vm.apply(to: model)
        }
        #expect(model.slow == 1)
        #expect(model.timesToPlaySlow == 2)
        #expect(model.mid == 3)
        #expect(model.timesToPlayMid == 4)
        #expect(model.fast == 5)
        #expect(model.timesToPlayFast == 6)
        #expect(model.playOrder === playOrder)
    }
}
