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
        let vm = PlaybackConstantViewModel(value: 80)
        
        #expect(vm.rateString == "80")
        #expect(vm.rateError == nil)
        #expect(vm.isValid)
    }
    
    @Test("init with invalid values reports errors")
    func initInvalidValues() {
        let vm = PlaybackConstantViewModel(value: 0)
        
        #expect(vm.rateError != nil)
        #expect(!vm.isValid)
    }
    
    // MARK: - Rate
    
    @Test("rate accepts positive number")
    func rateAcceptsPositive() throws {
        let vm = PlaybackConstantViewModel(value: 80)
        
        vm.rateString = "95"
        
        #expect(vm.rateString == "95")
        #expect(vm.rateError == nil)
        #expect(try appliedRate(vm) == 95)
    }
    
    @Test("rate invalid input sets error and keeps previous value",
          arguments: ["", "0", "-4", "abc", "1.5"])
    func rateRejectsInvalid(input: String) throws {
        let vm = PlaybackConstantViewModel(value: 80)
        
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
        let vm = PlaybackConstantViewModel(value: 80)
        
        vm.rateString = ""
        #expect(vm.rateError == "Rate is required.")
        
        vm.rateString = "0"
        #expect(vm.rateError == "Rate must be a number greater than zero.")
    }
    
    @Test("rate error clears after valid input")
    func rateErrorClears() {
        let vm = PlaybackConstantViewModel(value: 80)
        vm.rateString = "abc"
        #expect(vm.rateError != nil)
        
        vm.rateString = "60"
        
        #expect(vm.rateError == nil)
        #expect(vm.isValid)
    }
    
    
    // MARK: - validate()
    
    @Test("validate clears stale errors when state is valid")
    func validateClearsErrors() {
        let vm = PlaybackConstantViewModel(value: 80)
        vm.rateString = "bad"
        #expect(!vm.isValid)
        
        vm.rateString = "80"
        vm.validate()
        
        #expect(vm.isValid)
    }
    
    @Test("validate re-reports errors for invalid stored strings")
    func validateReportsErrors() {
        let vm = PlaybackConstantViewModel(value: 80)
        vm.rateString = "bad"
        
        vm.validate()
        
        #expect(vm.rateError == "Rate must be a number greater than zero.")
        #expect(!vm.isValid)
    }
    
    // MARK: - apply(to:)
    
    @Test("apply copies rate and timesToPlay to model")
    func applyCopiesValues() throws {
        let vm = PlaybackConstantViewModel(value: 80)
        let model = makeModel(rate: 1)
        
        vm.rateString = "100"
        try vm.apply(to: model)
        
        #expect(model.value == 100)
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
    
    private func makeModel(rate: Int) -> Mmp2.PlaybackConstant {
        Mmp2.PlaybackConstant(value: rate)
    }
    
    private func appliedRate(_ vm: Mmp2.PlaybackConstantViewModel) throws -> Int {
        let model = makeModel(rate: -1)
        try vm.apply(to: model)
        return model.value
    }
}

