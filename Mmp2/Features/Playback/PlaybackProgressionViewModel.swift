//
//  PlaybackStepwiseViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackProgressionViewModel {
    var start: Int
    private var preciseStart: Double
    var increment: Int
    var max: Int
    private var preciseMax: Double
    var timesToPlayEach: Int
    
    var storedStartString: String
    var storedIncrementString: String
    var storedMaxString: String
    var storedTimesToPlayEachString: String
    
    var startError: String?
    var incrementError: String?
    var maxError: String?
    var timesToPlayEachError: String?
    
    static func `default`() -> PlaybackProgressionViewModel {
        PlaybackProgressionViewModel(start: 100, increment: 2, max: 110, timesToPlayEach: 1)
    }

    init(start: Int, increment: Int, max: Int, timesToPlayEach: Int) {
        self.start = start
        self.preciseStart = Double(start)
        self.increment = increment
        self.max = max
        self.preciseMax = Double(max)
        self.timesToPlayEach = timesToPlayEach
        
        storedStartString = String(start)
        storedIncrementString = String(increment)
        storedMaxString = String(max)
        storedTimesToPlayEachString = String(timesToPlayEach)
        
        validate()
    }

    func scaleRates(by factor: Double) {
        if case .success = validateStart(storedStartString) {
            preciseStart *= factor
            start = scaledPlaybackValue(preciseStart)
            storedStartString = String(start)
        }
        if case .success = validateMax(storedMaxString) {
            preciseMax *= factor
            max = scaledPlaybackValue(preciseMax)
            storedMaxString = String(max)
        }
        validate()
    }
    
    var startString: String {
        get { storedStartString }
        set {
            storedStartString = newValue
            let result = validateStart(storedStartString)
            applyStartValidationResult(result)
            if case .success(let value) = result {
                preciseStart = Double(value)
            }
            validateRelationships()
        }
    }
    
    var incrementString: String {
        get { storedIncrementString }
        set {
            storedIncrementString = newValue
            applyIncrementValidationResult(validateIncrement(storedIncrementString))
            validateRelationships()
        }
    }
    
    var maxString: String {
        get { storedMaxString }
        set {
            storedMaxString = newValue
            let result = validateMax(storedMaxString)
            applyMaxValidationResult(result)
            if case .success(let value) = result {
                preciseMax = Double(value)
            }
            validateRelationships()
        }
    }

    var timesToPlayEachString: String {
        get { storedTimesToPlayEachString }
        set {
            storedTimesToPlayEachString = newValue
            let result = validateTimesToPlayEach(storedTimesToPlayEachString)
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
    
    func validateIncrement(_ incrementValue: String) -> ValidationResult<Int> {
        if incrementValue.isEmpty {
            return .failure("Increment is required.")
        } else {
            if let increment = Int(incrementValue) {
                if increment > 0 {
                    return .success(increment)
                }
            }
        }
        
        return .failure("Increment must be a number greater than zero.")
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
    
    func validateTimesToPlayEach(_ timesToPlayValue: String) -> ValidationResult<Int> {
        if timesToPlayValue.isEmpty {
            return .failure("Times To Play Each is required.")
        } else {
            if let timesToPlay = Int(timesToPlayValue) {
                if timesToPlay > 0 {
                    return .success(timesToPlay)
                }
            }
        }
        
        return .failure("Times To Play Each must be a number greater than zero.")
    }
    
    // Cross-field validation. Only runs for fields that passed their own validation.
    // Re-applies the field-level result first so stale relationship errors are cleared.
    func validateRelationships() {
        let startResult = validateStart(storedStartString)
        let stepResult = validateIncrement(storedIncrementString)
        let maxResult = validateMax(storedMaxString)
        
        // Reset max/step errors to their field-level state
        applyMaxValidationResult(maxResult)
        applyIncrementValidationResult(stepResult)
        
        guard case .success(let startValue) = startResult,
              case .success(let maxValue) = maxResult else { return }
        
        // Max > start
        if maxValue <= startValue {
            maxError = "Max must be greater than Start."
            return // start + step <= max cannot hold if max <= start
        }
        
        // start + step <= max
        if case .success(let stepValue) = stepResult, startValue + stepValue > maxValue {
            incrementError = "Start + Step must not exceed Max."
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

    private func applyIncrementValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            incrementError = nil
            increment = value
        case .failure(let message):
            incrementError = message
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
            timesToPlayEachError = nil
            timesToPlayEach = value
        case .failure(let message):
            timesToPlayEachError = message
        }
    }
    
    var isValid: Bool {
        startError == nil && incrementError == nil && maxError == nil && timesToPlayEachError == nil
    }

    func validate() {
        applyStartValidationResult(validateStart(storedStartString))
        applyIncrementValidationResult(validateIncrement(storedIncrementString))
        applyMaxValidationResult(validateMax(storedMaxString))
        applyTimesToPlayValidationResult(validateTimesToPlayEach(storedTimesToPlayEachString))
        validateRelationships()
    }
    
    func apply(to progression: PlaybackProgression) throws {
        validate()
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackProgressionViewModel")
        }
        
        progression.start = start
        progression.increment = increment
        progression.max = max
        progression.timesToPlayEach = timesToPlayEach
    }
}
