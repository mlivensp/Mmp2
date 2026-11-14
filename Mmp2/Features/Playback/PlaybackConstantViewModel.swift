//
//  PlaybackConstantViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackConstantViewModel {
    private var value: Int
    private var preciseValue: Double

    private var storedValueString: String
    
    var valueError: String? = nil
    
    init(value: Int) {
        self.value = value
        self.preciseValue = Double(value)
        
        self.storedValueString = String(value)
        
        validate()
    }
    
    static func draft() -> PlaybackConstantViewModel {
        PlaybackConstantViewModel(value: 100)
    }

    func scaleRate(by factor: Double) {
        guard case .success = validateValue(storedValueString) else { return }
        preciseValue *= factor
        value = scaledPlaybackValue(preciseValue)
        storedValueString = String(value)
        validate()
    }

    var valueString: String {
        get { return storedValueString }
        set {
            storedValueString = newValue
            let result = validateValue(storedValueString)
            applyValueValidationResult(result)
            if case .success(let value) = result {
                preciseValue = Double(value)
            }
        }
    }
        
    
    private func applyValueValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let resultValue):
            valueError = nil
            value = resultValue
        case .failure(let message):
            valueError = message
        }
    }

    fileprivate func validateValue(_ value: String) -> ValidationResult<Int> {
        if value.isEmpty {
            return .failure("Rate is required.")
        } else {
            if let rate = Int(value) {
                if rate > 0 {
                    return .success(rate)
                }
            }
        }
        
        return .failure("Rate must be a number greater than zero.")
    }
    
    fileprivate func validateTimesToPlay(_ timesToPlayValue: String) -> ValidationResult<Int?> {
        if timesToPlayValue.isEmpty {
            return .success(nil)
        } else {
            if let timesToPlay = Int(timesToPlayValue) {
                if timesToPlay > 0 {
                    return .success(timesToPlay)
                }
            }
        }
        
        return .failure("Times To Play must be empty or a number greater than zero.")
    }
    
    func validate() {
        valueError = nil
        
        let rateResult = validateValue(storedValueString)
        applyValueValidationResult(rateResult)
    }
    
    var isValid: Bool {
        valueError == nil 
    }
    
    func apply(to playbackConstant: PlaybackConstant) throws {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackConstant")
        }
        
        playbackConstant.value = value
    }
}
