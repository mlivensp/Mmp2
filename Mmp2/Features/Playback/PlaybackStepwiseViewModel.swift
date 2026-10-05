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
    
    static func `default`() -> PlaybackStepwiseViewModel {
        PlaybackStepwiseViewModel(start: 100, step: 2, max: 110, timesToPlay: 1)
    }

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
            applyStartValidationResult(validateStart(storedStartString))
            validateRelationships()
        }
    }
    
    var stepString: String {
        get { storedStepString }
        set {
            storedStepString = newValue
            applyStepValidationResult(validateStep(storedStepString))
            validateRelationships()
        }
    }
    
    var maxString: String {
        get { storedMaxString }
        set {
            storedMaxString = newValue
            applyMaxValidationResult(validateMax(storedMaxString))
            validateRelationships()
        }
    }

    var timesToPlayString: String {
        get { storedTimesToPlayString }
        set {
            storedTimesToPlayString = newValue
            let result = validateTimesToPlay(storedTimesToPlayString)
            applyTimesToPlayValidationResult(result)
        }
    }
    
    // MARK: validation

    func validateStart(_ startValue: String) -> ValidationResult<Int> {
        if startValue.isEmpty {
            return .failure("Start is required.")
        } else {
            if let start = Int(startValue) {
                if start > 0 {
                    return .success(start)
                }
            }
        }
        
        return .failure("Start must be a number greater than zero.")
    }
    
    func validateStep(_ stepValue: String) -> ValidationResult<Int> {
        if stepValue.isEmpty {
            return .failure("Step is required.")
        } else {
            if let step = Int(stepValue) {
                if step > 0 {
                    return .success(step)
                }
            }
        }
        
        return .failure("Step must be a number greater than zero.")
    }
    
    func validateMax(_ maxValue: String) -> ValidationResult<Int> {
        if maxValue.isEmpty {
            return .failure("Max is required.")
        } else {
            if let max = Int(maxValue) {
                if max > 0 {
                    return .success(max)
                }
            }
        }
        
        return .failure("Max must be a number greater than zero.")
    }
    
    func validateTimesToPlay(_ timesToPlayValue: String) -> ValidationResult<Int> {
        if timesToPlayValue.isEmpty {
            return .failure("Times To Play is required.")
        } else {
            if let timesToPlay = Int(timesToPlayValue) {
                if timesToPlay > 0 {
                    return .success(timesToPlay)
                }
            }
        }
        
        return .failure("Times To Play must be a number greater than zero.")
    }
    
    // Cross-field validation. Only runs for fields that passed their own validation.
    // Re-applies the field-level result first so stale relationship errors are cleared.
    func validateRelationships() {
        let startResult = validateStart(storedStartString)
        let stepResult = validateStep(storedStepString)
        let maxResult = validateMax(storedMaxString)
        
        // Reset max/step errors to their field-level state
        applyMaxValidationResult(maxResult)
        applyStepValidationResult(stepResult)
        
        guard case .success(let startValue) = startResult,
              case .success(let maxValue) = maxResult else { return }
        
        // Max > start
        if maxValue <= startValue {
            maxError = "Max must be greater than Start."
            return // start + step <= max cannot hold if max <= start
        }
        
        // start + step <= max
        if case .success(let stepValue) = stepResult, startValue + stepValue > maxValue {
            stepError = "Start + Step must not exceed Max."
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
    
    // MARK: apply validation result

    private func applyStepValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            stepError = nil
            step = value
        case .failure(let message):
            stepError = message
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
        applyStartValidationResult(validateStart(storedStartString))
        applyStepValidationResult(validateStep(storedStepString))
        applyMaxValidationResult(validateMax(storedMaxString))
        applyTimesToPlayValidationResult(validateTimesToPlay(storedTimesToPlayString))
        validateRelationships()
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
