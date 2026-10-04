//
//  PlaybackStepwiseViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackStepwiseViewModel {
    var start: Int
    var step: Int
    var max: Int
    var timesToPlay: Int
    
    var storedStartString: String
    var storedStepString: String
    var storedMaxString: String
    var storedTimesToPlayString: String
    
    var startError: String?
    var stepError: String?
    var maxError: String?
    var timesToPlayError: String?

    init(start: Int, step: Int, max: Int, timesToPlay: Int) {
        self.start = start
        self.step = step
        self.max = max
        self.timesToPlay = timesToPlay
        
        storedStartString = String(start)
        storedStepString = String(step)
        storedMaxString = String(max)
        storedTimesToPlayString = String(timesToPlay)
        
        validate()
    }
    
    var startString: String {
        get { storedStartString }
        set {
            storedStartString = newValue
            let result = validateStart(storedStartString)
            applyStartValidationResult(result)
        }
    }
    
    var stepString: String {
        get { storedStepString }
        set {
            storedStepString = newValue
            let result = validateStep(storedStepString)
            applyStepValidationResult(result)
        }
    }
    
    var maxString: String {
        get { storedMaxString }
        set {
            storedMaxString = newValue
            let result = validateMax(storedMaxString)
            applyMaxValidationResult(result)
        }
    }
    
    var timesToPlayString: String {
        get { storedTimesToPlayString }
        set {
            storedTimesToPlayString = newValue
            let result = validateStart(storedTimesToPlayString)
            applyTimesToPlayValidationResult(result)
        }
    }

    func validateStart(_ startValue: String) -> ValidationResult<Int> {
        if startValue.isEmpty {
            return .failure("Start is required.")
        } else {
            guard let start = Int(startValue) else {
                return .failure("Start must be a whole number.")
            }
            
            return .success(start)
        }
    }
    
    private func applyStartValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            startError = nil
            start = value
        case .failure(let message):
            startError = message
        }
    }
    
    func validateStep(_ stepValue: String) -> ValidationResult<Int> {
        if stepValue.isEmpty {
            return .failure("Step is required.")
        } else {
            guard let step = Int(stepValue) else {
                return .failure("Step must be a whole number.")
            }
            
            return .success(step)
        }
    }
    
    private func applyStepValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            stepError = nil
            step = value
        case .failure(let message):
            stepError = message
        }
    }
    
    func validateMax(_ maxValue: String) -> ValidationResult<Int> {
        if maxValue.isEmpty {
            return .failure("Max is required.")
        } else {
            guard let max = Int(maxValue) else {
                return .failure("Max must be a whole number.")
            }
            
            return .success(max)
        }
    }
    
    private func applyMaxValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            maxError = nil
            max = value
        case .failure(let message):
            maxError = message
        }
    }
    
    func validateTimesToPlay(_ timesToPlayValue: String) -> ValidationResult<Int> {
        if timesToPlayValue.isEmpty {
            return .failure("Times To Play is required.")
        } else {
            guard let timesToPlay = Int(timesToPlayValue) else {
                return .failure("Times To Play must be a whole number.")
            }
            
            return .success(timesToPlay)
        }
    }
    
    private func applyTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            timesToPlayError = nil
            timesToPlay = value
        case .failure(let message):
            timesToPlayError = message
        }
    }
    
    var isValid: Bool {
        startError == nil && stepError == nil && maxError == nil && timesToPlayError == nil
    }

    func validate() {
        let startResult = validateStart(storedStartString)
        applyStartValidationResult(startResult)
        let stepResult = validateStep(storedStepString)
        applyStepValidationResult(stepResult)
        let maxResult = validateMax(storedMaxString)
        applyMaxValidationResult(maxResult)
        let timesToPlayResult = validateStart(storedTimesToPlayString)
        applyTimesToPlayValidationResult(timesToPlayResult)
    }
    
    func apply(to stepwise: PlaybackStepwise) throws {
        validate()
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackStepwiseViewModel")
        }
        
        stepwise.start = start
        stepwise.step = step
        stepwise.max = max
        stepwise.timesToPlay = timesToPlay
    }
}
