//
//  PlaybackConstantViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackConstantViewModel {
    private var rate: Int
    private var timesToPlay: Int?

    private var storedRateString: String
    private var storedTimesToPlayString: String
    
    var rateError: String? = nil
    var timesToPlayError: String? = nil
    
    init(rate: Int, timesToPlay: Int?) {
        self.rate = rate
        self.timesToPlay = timesToPlay
        
        self.storedRateString = String(rate)
        
        if let timesToPlay {
            storedTimesToPlayString = String(timesToPlay)
        } else {
            storedTimesToPlayString = ""
        }
        
        validate()
    }

    var rateString: String {
        get { return storedRateString }
        set {
            storedRateString = newValue
            let result = validateRate(storedRateString)
            applyRateValidationResult(result)
        }
    }
        
    
    var timesToPlayString: String {
        get { return storedTimesToPlayString }
        set {
            self.storedTimesToPlayString = newValue
            let result = validateTimesToPlay(storedTimesToPlayString)
            applyTimesToPlayValidationResult(result)
        }
    }
    
    private func applyRateValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            rateError = nil
            rate = value
        case .failure(let message):
            rateError = message
        }
    }

    private func applyTimesToPlayValidationResult(_ result: ValidationResult<Int?>) {
        switch result {
        case .success(let value):
            timesToPlayError = nil
            timesToPlay = value
        case .failure(let message):
            timesToPlayError = message
        }
    }

    fileprivate func validateRate(_ rateValue: String) -> ValidationResult<Int> {
        if rateValue.isEmpty {
            return .failure("Rate is required.")
        } else {
            if let rate = Int(rateValue) {
                return .success(rate)
            }
        }
        
        return .failure("Rate must be a valid whole number.")
    }
    
    fileprivate func validateTimesToPlay(_ timesToPlayValue: String) -> ValidationResult<Int?> {
        if timesToPlayValue.isEmpty {
            return .success(nil)
        } else {
            if let timesToPlay = Int(timesToPlayValue) {
                return .success(timesToPlay)
            }
        }
        
        return .failure("Times To Play must be empty or a valid whole number.")
    }
    
    func validate() {
        rateError = nil
        timesToPlayError = nil
        
        let rateResult = validateRate(storedRateString)
        applyRateValidationResult(rateResult)
        let timesToPlayResult = validateTimesToPlay(storedTimesToPlayString)
        applyTimesToPlayValidationResult(timesToPlayResult)
    }
    
    var isValid: Bool {
        rateError == nil && timesToPlayError == nil
    }
    
    func apply(to playbackConstant: PlaybackConstant) {
        playbackConstant.rate = rate
        playbackConstant.timesToPlay = timesToPlay
    }
}
