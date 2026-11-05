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

    private var storedRateString: String
    
    var rateError: String? = nil
    
    init(value: Int) {
        self.value = value
        self.preciseValue = Double(value)
        
        self.storedRateString = String(value)
        
        validate()
    }
    
    static func `default`() -> PlaybackConstantViewModel {
        PlaybackConstantViewModel(value: 100)
    }

    func scaleRate(by factor: Double) {
        guard case .success = validateRate(storedRateString) else { return }
        preciseValue *= factor
        value = scaledPlaybackValue(preciseValue)
        storedRateString = String(value)
        validate()
    }

    var rateString: String {
        get { return storedRateString }
        set {
            storedRateString = newValue
            let result = validateRate(storedRateString)
            applyRateValidationResult(result)
            if case .success(let value) = result {
                preciseValue = Double(value)
            }
        }
    }
        
    
    private func applyRateValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let resultValue):
            rateError = nil
            value = resultValue
        case .failure(let message):
            rateError = message
        }
    }

    fileprivate func validateRate(_ value: String) -> ValidationResult<Int> {
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
        rateError = nil
        
        let rateResult = validateRate(storedRateString)
        applyRateValidationResult(rateResult)
    }
    
    var isValid: Bool {
        rateError == nil 
    }
    
    func apply(to playbackConstant: PlaybackConstant) throws {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackConstant")
        }
        
        playbackConstant.value = value
    }
}
