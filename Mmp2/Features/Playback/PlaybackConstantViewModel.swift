//
//  PlaybackConstantViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackConstantViewModel {
    private var storedRateString: String
    
    var rateString: String {
        get { return storedRateString }
        set {
            storedRateString = newValue
            
            rateError = nil
            let result = validateRate(storedRateString)
            switch result {
            case .success(let value):
                rate = value
            case .failure(let message):
                rateError = message
            }
        }
    }
    
    private var rate: Int
    
    private var storedTimesToPlayString: String
    
    var timesToPlayString: String {
        get { return storedTimesToPlayString }
        set {
            self.storedTimesToPlayString = newValue
            
            timesToPlayError = nil
            let result = validateTimesToPlay(storedTimesToPlayString)
            switch result {
            case .success(let value):
                self.timesToPlay = value
            case .failure(let message):
                self.timesToPlayError = message
            }
        }
    }
    
    private var timesToPlay: Int?
    
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
        
        switch rateResult {
        case.success(let rateValue):
            self.rate = rateValue
        case .failure(let message):
            rateError = message
        }
        
        let timesToPlayResult = validateTimesToPlay(storedTimesToPlayString)
        switch timesToPlayResult {
        case .success(let value):
            self.timesToPlay = value
        case .failure(let message):
            timesToPlayError = message
        }
    }
    
    var isValid: Bool {
        rateError == nil && timesToPlayError == nil
    }
    
    func apply(to playbackConstant: PlaybackConstant) {
        playbackConstant.rate = rate
        playbackConstant.timesToPlay = timesToPlay
    }
}
