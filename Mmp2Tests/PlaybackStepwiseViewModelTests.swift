//
//  PlaybackStepwiseViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/4/26.
//

import Testing
@testable import Mmp2

@Suite("PlaybackStepwiseViewModel")
struct PlaybackStepwiseViewModelTests {

    // MARK: - Init

    @Test("init maps values to strings and numeric state, and starts valid")
    func initMapsValues() {
        let vm = makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)

        #expect(vm.startString == "60")
        #expect(vm.stepString == "5")
        #expect(vm.maxString == "120")
        #expect(vm.timesToPlayString == "3")

        #expect(vm.start == 60)
        #expect(vm.step == 5)
        #expect(vm.max == 120)
        #expect(vm.timesToPlay == 3)

        #expect(vm.isValid)
        #expect(vm.startError == nil)
        #expect(vm.stepError == nil)
        #expect(vm.maxError == nil)
        #expect(vm.timesToPlayError == nil)
    }

    @Test("init with invalid values reports errors after validate()")
    func initWithInvalidValuesIsInvalid() {
        let vm = makeVM(start: 0, step: 0, max: 0, timesToPlay: 0)

        #expect(!vm.isValid)
        #expect(vm.startError != nil)
        #expect(vm.stepError != nil)
        #expect(vm.maxError != nil)
        #expect(vm.timesToPlayError != nil)
    }

    // MARK: - Start

    @Test("start accepts positive number")
    func startAcceptsPositive() {
        let vm = makeDefaultVM()
        vm.startString = "72"

        #expect(vm.start == 72)
        #expect(vm.startError == nil)
    }

    @Test("start invalid input sets error and keeps previous value",
          arguments: ["", "0", "-5", "abc", "1.5"])
    func startRejectsInvalid(input: String) {
        let vm = makeDefaultVM()
        let original = vm.start

        vm.startString = input

        #expect(vm.startString == input)
        #expect(vm.start == original)
        #expect(vm.startError != nil)
        #expect(!vm.isValid)
    }

    @Test("start error clears after valid input")
    func startErrorClears() {
        let vm = makeDefaultVM()
        vm.startString = "abc"
        #expect(vm.startError != nil)

        vm.startString = "50"

        #expect(vm.startError == nil)
        #expect(vm.start == 50)
        #expect(vm.isValid)
    }

    // MARK: - Step

    @Test("step accepts positive number")
    func stepAcceptsPositive() {
        let vm = makeDefaultVM()
        vm.stepString = "10"

        #expect(vm.step == 10)
        #expect(vm.stepError == nil)
    }

    @Test("step invalid input sets error and keeps previous value",
          arguments: ["", "0", "-1", "x"])
    func stepRejectsInvalid(input: String) {
        let vm = makeDefaultVM()
        let original = vm.step

        vm.stepString = input

        #expect(vm.step == original)
        #expect(vm.stepError != nil)
        #expect(!vm.isValid)
    }

    // MARK: - Max

    @Test("max accepts positive number")
    func maxAcceptsPositive() {
        let vm = makeDefaultVM()
        vm.maxString = "200"

        #expect(vm.max == 200)
        #expect(vm.maxError == nil)
    }

    @Test("max invalid input sets error and keeps previous value",
          arguments: ["", "0", "-1", "x"])
    func maxRejectsInvalid(input: String) {
        let vm = makeDefaultVM()
        let original = vm.max

        vm.maxString = input

        #expect(vm.max == original)
        #expect(vm.maxError != nil)
        #expect(!vm.isValid)
    }

    // MARK: - Times to play

    @Test("timesToPlay accepts positive number")
    func timesToPlayAcceptsPositive() {
        let vm = makeDefaultVM()
        vm.timesToPlayString = "4"

        #expect(vm.timesToPlay == 4)
        #expect(vm.timesToPlayError == nil)
    }

    @Test("timesToPlay invalid input sets error and keeps previous value",
          arguments: ["", "0", "-1", "x"])
    func timesToPlayRejectsInvalid(input: String) {
        let vm = makeDefaultVM()
        let original = vm.timesToPlay

        vm.timesToPlayString = input

        #expect(vm.timesToPlay == original)
        #expect(vm.timesToPlayError != nil)
        #expect(!vm.isValid)
    }

    // Documents a bug: the setter and validate() call validateStart for timesToPlay,
    // so the message mentions "Start" instead of "Times To Play". Fails until fixed.
    @Test("timesToPlay error message refers to Times To Play")
    func timesToPlayErrorMessage() {
        let vm = makeDefaultVM()
        vm.timesToPlayString = ""

        #expect(vm.timesToPlayError == "Times To Play is required.")
    }
    
    // MARK: - Cross-field validation: max > start
    
    @Test("max > start: valid when max is greater than start")
    func maxGreaterThanStartValid() {
        let vm = makeVM(start: 50, step: 5, max: 100, timesToPlay: 3)
        
        #expect(vm.isValid)
        #expect(vm.maxError == nil)
    }
    
    @Test("max > start: invalid when max equals start")
    func maxEqualsStartInvalid() {
        let vm = makeVM(start: 50, step: 5, max: 50, timesToPlay: 3)
        
        #expect(!vm.isValid)
        #expect(vm.maxError == "Max must be greater than Start.")
    }
    
    @Test("max > start: invalid when max is less than start")
    func maxLessThanStartInvalid() {
        let vm = makeVM(start: 100, step: 5, max: 50, timesToPlay: 3)
        
        #expect(!vm.isValid)
        #expect(vm.maxError == "Max must be greater than Start.")
    }
    
    @Test("max > start: error clears when max is increased above start")
    func maxGreaterThanStartErrorClears() {
        let vm = makeVM(start: 50, step: 5, max: 50, timesToPlay: 3)
        #expect(vm.maxError != nil)
        
        vm.maxString = "100"
        
        #expect(vm.maxError == nil)
        #expect(vm.isValid)
    }
    
    @Test("max > start: error clears when start is decreased below max")
    func maxGreaterThanStartErrorClearsViaStart() {
        let vm = makeVM(start: 100, step: 5, max: 50, timesToPlay: 3)
        #expect(vm.maxError != nil)
        
        vm.startString = "40"
        
        #expect(vm.maxError == nil)
        #expect(vm.isValid)
    }
    
    // MARK: - Cross-field validation: start + step <= max
    
    @Test("start + step <= max: valid when sum is less than max")
    func startPlusStepLessThanMaxValid() {
        let vm = makeVM(start: 50, step: 20, max: 100, timesToPlay: 3)
        
        #expect(vm.isValid)
        #expect(vm.stepError == nil)
    }
    
    @Test("start + step <= max: valid when sum equals max")
    func startPlusStepEqualsMaxValid() {
        let vm = makeVM(start: 50, step: 50, max: 100, timesToPlay: 3)
        
        #expect(vm.isValid)
        #expect(vm.stepError == nil)
    }
    
    @Test("start + step <= max: invalid when sum exceeds max")
    func startPlusStepExceedsMaxInvalid() {
        let vm = makeVM(start: 50, step: 60, max: 100, timesToPlay: 3)
        
        #expect(!vm.isValid)
        #expect(vm.stepError == "Start + Step must not exceed Max.")
    }
    
    @Test("start + step <= max: error clears when step is decreased")
    func startPlusStepErrorClearsViaStep() {
        let vm = makeVM(start: 50, step: 60, max: 100, timesToPlay: 3)
        #expect(vm.stepError != nil)
        
        vm.stepString = "30"
        
        #expect(vm.stepError == nil)
        #expect(vm.isValid)
    }
    
    @Test("start + step <= max: error clears when start is decreased")
    func startPlusStepErrorClearsViaStart() {
        let vm = makeVM(start: 60, step: 60, max: 100, timesToPlay: 3)
        #expect(vm.stepError != nil)
        
        vm.startString = "30"
        
        #expect(vm.stepError == nil)
        #expect(vm.isValid)
    }
    
    @Test("start + step <= max: error clears when max is increased")
    func startPlusStepErrorClearsViaMax() {
        let vm = makeVM(start: 50, step: 60, max: 100, timesToPlay: 3)
        #expect(vm.stepError != nil)
        
        vm.maxString = "150"
        
        #expect(vm.stepError == nil)
        #expect(vm.isValid)
    }
    
    @Test("start + step <= max: skipped when step fails field validation")
    func startPlusStepSkippedWhenStepInvalid() {
        let vm = makeVM(start: 50, step: 20, max: 100, timesToPlay: 3)
        
        vm.stepString = "abc"
        
        #expect(vm.stepError == "Step must be a number greater than zero.")
        #expect(!vm.isValid)
    }
    
    @Test("start + step <= max: no error when max > start but sum exceeds max (max > start only)")
    func maxGreaterThanStartTakesPriority() {
        let vm = makeVM(start: 100, step: 50, max: 150, timesToPlay: 3)
        
        // First violate max > start
        vm.maxString = "50"
        
        #expect(vm.maxError == "Max must be greater than Start.")
        // The step rule should not run because max <= start
        #expect(vm.stepError == nil)
        #expect(!vm.isValid)
    }
    // MARK: - Validators

    @Test("validateStart")
    func validateStartResults() {
        #expect(successValue(makeDefaultVM().validateStart("5")) == 5)
        #expect(failureMessage(makeDefaultVM().validateStart("")) == "Start is required.")
        #expect(failureMessage(makeDefaultVM().validateStart("0")) == "Start must be a number greater than zero.")
    }

    @Test("validateStep")
    func validateStepResults() {
        #expect(successValue(makeDefaultVM().validateStep("5")) == 5)
        #expect(failureMessage(makeDefaultVM().validateStep("")) == "Step is required.")
        #expect(failureMessage(makeDefaultVM().validateStep("-2")) == "Step must be a number greater than zero.")
    }

    @Test("validateMax")
    func validateMaxResults() {
        #expect(successValue(makeDefaultVM().validateMax("5")) == 5)
        #expect(failureMessage(makeDefaultVM().validateMax("")) == "Max is required.")
        #expect(failureMessage(makeDefaultVM().validateMax("q")) == "Max must be a number greater than zero.")
    }

    @Test("validateTimesToPlay")
    func validateTimesToPlayResults() {
        #expect(successValue(makeDefaultVM().validateTimesToPlay("5")) == 5)
        #expect(failureMessage(makeDefaultVM().validateTimesToPlay("")) == "Times To Play is required.")
        #expect(failureMessage(makeDefaultVM().validateTimesToPlay("0")) == "Times To Play must be a number greater than zero.")
    }

    // MARK: - isValid

    @Test("isValid is false when any single field has an error")
    func isValidFalseWithAnyError() {
        let vm = makeDefaultVM()
        #expect(vm.isValid)

        vm.stepString = "bad"
        #expect(!vm.isValid)

        vm.stepString = "5"
        #expect(vm.isValid)
    }

    // MARK: - apply(to:)

    @Test("apply copies values to PlaybackStepwise when valid")
    func applyCopiesValues() throws {
        let vm = makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)
        let model = Mmp2.PlaybackStepwise(start: 1, step: 1, max: 1, timesToPlay: 1, playback: nil)

        vm.startString = "70"
        vm.stepString = "10"
        vm.maxString = "150"
        vm.timesToPlayString = "6"

        try vm.apply(to: model)

        #expect(model.start == 70)
        #expect(model.step == 10)
        #expect(model.max == 150)
        #expect(model.timesToPlay == 6)
    }

    @Test("apply throws and leaves model untouched when state is invalid")
    func applyThrowsWhenInvalid() {
        let vm = makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)
        let model = Mmp2.PlaybackStepwise(start: 1, step: 2, max: 3, timesToPlay: 4, playback: nil)

        vm.maxString = "nope"

        #expect(throws: (any Error).self) {
            try vm.apply(to: model)
        }
        #expect(model.start == 1)
        #expect(model.step == 2)
        #expect(model.max == 3)
        #expect(model.timesToPlay == 4)
    }

    // MARK: - Helpers

    private func makeDefaultVM() -> PlaybackStepwiseViewModel {
        makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)
    }

    private func makeVM(start: Int, step: Int, max: Int, timesToPlay: Int) -> PlaybackStepwiseViewModel {
        PlaybackStepwiseViewModel(start: start, step: step, max: max, timesToPlay: timesToPlay)
    }

    private func successValue(_ result: ValidationResult<Int>) -> Int? {
        if case .success(let value) = result { return value }
        return nil
    }

    private func failureMessage(_ result: ValidationResult<Int>) -> String? {
        if case .failure(let message) = result { return message }
        return nil
    }

    // MARK: - apply(to:)

//    @Test("apply copies values to PlaybackStepwise when valid")
//    func applyCopiesValues() throws {
//        let vm = makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)
//        let model = Mmp2.PlaybackStepwise(start: 1, step: 1, max: 1, timesToPlay: 1, playback: nil)
//
//        vm.startString = "80"
//        vm.stepString = "7"
//        vm.maxString = "200"
//        vm.timesToPlayString = "6"
//
//        try vm.apply(to: model)
//
//        #expect(model.start == 80)
//        #expect(model.step == 7)
//        #expect(model.max == 200)
//        #expect(model.timesToPlay == 6)
//    }
//
//    @Test("apply throws and leaves model untouched when state is invalid")
//    func applyThrowsWhenInvalid() {
//        let vm = makeVM(start: 60, step: 5, max: 120, timesToPlay: 3)
//        let model = Mmp2.PlaybackStepwise(start: 2, step: 4, max: 6, timesToPlay: 8, playback: nil)
//
//        vm.startString = "bad" // invalid input
//
//        #expect(throws: (any Error).self) {
//            try vm.apply(to: model)
//        }
//        // Model should be unchanged
//        #expect(model.start == 2)
//        #expect(model.step == 4)
//        #expect(model.max == 6)
//        #expect(model.timesToPlay == 8)
//    }
}
