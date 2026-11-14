//
//  PlaybackSequenceViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/12/26.
//

import Foundation

@Observable
final class PlaybackSequenceViewModel {
    let sequence: PlaybackSequence
    
    let uniquer = UUID()
    
    var value: Int
    var timesToPlay: Int?
    
    private var preciseValue: Double

    var storedValueString: String
    var storedTimesToPlayString: String
    
    var valueError: String? = nil
    var timesToPlayError: String? = nil
    
    init(sequence: PlaybackSequence) {
        self.sequence = sequence
        self.value = sequence.value
        self.preciseValue = Double(sequence.value)
        storedValueString = String(sequence.value)
        self.timesToPlay = sequence.timesToPlay
        
        if let timesToPlay = sequence.timesToPlay {
            storedTimesToPlayString = String(timesToPlay)
        } else {
            storedTimesToPlayString = ""
        }
    }

    func scaleRate(by factor: Double) {
        guard case .success = validateValue(storedValueString) else { return }
        preciseValue *= factor
        value = scaledPlaybackValue(preciseValue)
        storedValueString = String(value)
        validate()
    }

    var valueString: String {
        get { storedValueString }
        set {
            storedValueString = newValue
            let result = validateValue(storedValueString)
            applyValueValidationResult(result)
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

    func validateValue(_ valueValue: String) -> ValidationResult<Int> {
        if valueValue.isEmpty {
            return .failure("Value is required.")
        } else {
            if let value = Int(valueValue) {
                if value > 0 {
                    return .success(value)
                }
            }
        }
        
        return .failure("Value must be a number greater than zero.")
    }

    func validateTimesToPlay(_ timesToPlayValue: String) -> ValidationResult<Int?> {
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

    private func applyValueValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            valueError = nil
            self.value = value
        case .failure(let message):
            valueError = message
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

    var isValid: Bool {
        valueError == nil && timesToPlayError == nil
    }

    func validate() {
        applyValueValidationResult(validateValue(storedValueString))
        applyTimesToPlayValidationResult(validateTimesToPlay(storedTimesToPlayString))
    }
    
    func apply(to playbackSequence: PlaybackSequence) throws {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackSequence")
        }
        
        playbackSequence.playOrder = sequence.playOrder
        playbackSequence.value = value
        playbackSequence.timesToPlay = timesToPlay
    }
}
