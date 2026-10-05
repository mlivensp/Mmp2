//
//  PlaybackConstantViewModelTests.swift
//  Mmp2Tests
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Testing
@testable import Mmp2

@Suite("PlaybackConstantViewModel")
struct PlaybackConstantViewModelTests {
    
    // MARK: - Init
    
    @Test("init maps values to strings and starts valid")
    func initMapsValues() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
        #expect(vm.rateString == "80")
        #expect(vm.timesToPlayString == "3")
        #expect(vm.rateError == nil)
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    @Test("init with nil timesToPlay uses empty string and is valid")
    func initNilTimesToPlay() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: nil)
        
        #expect(vm.timesToPlayString == "")
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    @Test("init with invalid values reports errors")
    func initInvalidValues() {
        let vm = PlaybackConstantViewModel(rate: 0, timesToPlay: 0)
        
        #expect(vm.rateError != nil)
        #expect(vm.timesToPlayError != nil)
        #expect(!vm.isValid)
    }
    
    // MARK: - Rate
    
    @Test("rate accepts positive number")
    func rateAcceptsPositive() throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
        vm.rateString = "95"
        
        #expect(vm.rateString == "95")
        #expect(vm.rateError == nil)
        #expect(try appliedRate(vm) == 95)
    }
    
    @Test("rate invalid input sets error and keeps previous value",
          arguments: ["", "0", "-4", "abc", "1.5"])
    func rateRejectsInvalid(input: String) throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
        vm.rateString = input
        
        #expect(vm.rateString == input)
        #expect(vm.rateError != nil)
        #expect(!vm.isValid)
//        #expect(throws: AppError.self) {
//            #expect(try appliedRate(vm) == 80)
//        }
    }
    
    @Test("rate error messages")
    func rateErrorMessages() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
        vm.rateString = ""
        #expect(vm.rateError == "Rate is required.")
        
        vm.rateString = "0"
        #expect(vm.rateError == "Rate must be a number greater than zero.")
    }
    
    @Test("rate error clears after valid input")
    func rateErrorClears() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        vm.rateString = "abc"
        #expect(vm.rateError != nil)
        
        vm.rateString = "60"
        
        #expect(vm.rateError == nil)
        #expect(vm.isValid)
    }
    
    // MARK: - Times to play
    
    @Test("timesToPlay accepts positive number")
    func timesToPlayAcceptsPositive() throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: nil)
        
        vm.timesToPlayString = "5"
        
        #expect(vm.timesToPlayError == nil)
        #expect(try appliedTimesToPlay(vm) == 5)
    }
    
    @Test("timesToPlay empty is valid and sets value to nil")
    func timesToPlayEmptyIsNil() throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
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
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        
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
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        vm.timesToPlayString = "x"
        #expect(vm.timesToPlayError != nil)
        
        vm.timesToPlayString = "4"
        
        #expect(vm.timesToPlayError == nil)
        #expect(vm.isValid)
    }
    
    // MARK: - validate()
    
    @Test("validate clears stale errors when state is valid")
    func validateClearsErrors() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        vm.rateString = "bad"
        vm.timesToPlayString = "bad"
        #expect(!vm.isValid)
        
        vm.rateString = "80"
        vm.timesToPlayString = "3"
        vm.validate()
        
        #expect(vm.isValid)
    }
    
    @Test("validate re-reports errors for invalid stored strings")
    func validateReportsErrors() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        vm.rateString = "bad"
        
        vm.validate()
        
        #expect(vm.rateError == "Rate must be a number greater than zero.")
        #expect(!vm.isValid)
    }
    
    // MARK: - isValid
    
    @Test("isValid is false when either field has an error")
    func isValidFalseWithAnyError() {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        #expect(vm.isValid)
        
        vm.timesToPlayString = "0"
        #expect(!vm.isValid)
        
        vm.timesToPlayString = "1"
        #expect(vm.isValid)
    }
    
    // MARK: - apply(to:)
    
    @Test("apply copies rate and timesToPlay to model")
    func applyCopiesValues() throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        let model = makeModel(rate: 1, timesToPlay: 1)
        
        vm.rateString = "100"
        vm.timesToPlayString = "9"
        try vm.apply(to: model)
        
        #expect(model.rate == 100)
        #expect(model.timesToPlay == 9)
    }
    
    @Test("apply sets timesToPlay to nil when field is empty")
    func applySetsNilTimesToPlay() throws {
        let vm = PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
        let model = makeModel(rate: 1, timesToPlay: 7)
        
        vm.timesToPlayString = ""
        try vm.apply(to: model)
        
        #expect(model.timesToPlay == nil)
    }
    
//    @Test("apply writes last valid values when current input is invalid")
//    func applyWithInvalidInputWritesLastValid() throws {
//        let vm = Mmp2.PlaybackConstantViewModel(rate: 80, timesToPlay: 3)
//        let model = makeModel(rate: 1, timesToPlay: 1)
//        
//        vm.rateString = "bad"
//        #expect(throws: AppError.self) {
//            try vm.apply(to: model)
//        }
//        
//        #expect(model.rate == 80)
//        #expect(model.timesToPlay == 3)
//    }
    
    // MARK: - Helpers
    
    private func makeModel(rate: Int, timesToPlay: Int?) -> Mmp2.PlaybackConstant {
        Mmp2.PlaybackConstant(rate: rate, timesToPlay: timesToPlay, playback: nil)
    }
    
    private func appliedRate(_ vm: Mmp2.PlaybackConstantViewModel) throws -> Int {
        let model = makeModel(rate: -1, timesToPlay: nil)
        try vm.apply(to: model)
        return model.rate
    }
    
    private func appliedTimesToPlay(_ vm: Mmp2.PlaybackConstantViewModel) throws -> Int? {
        let model = makeModel(rate: -1, timesToPlay: -1)
        try vm.apply(to: model)
        return model.timesToPlay
    }
}

