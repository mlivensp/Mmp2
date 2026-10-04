//
//  PlaybackBounceViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation

@Observable
final class PlaybackBounceViewModel {
    private var slowTempo: Int
    private var slowTempoTimesToPlay: Int
    private var midTempo: Int
    private var midTempoTimesToPlay: Int
    private var fastTempo: Int
    private var fastTempoTimesToPlay: Int
    private var numberOfBounces: Int
    
    private var storedSlowTempoString: String
    private var storedSlowTempoTimesToPlayString: String
    private var storedMidTempoString: String
    private var storedMidTempoTimesToPlayString: String
    private var storedFastTempoString: String
    private var storedFastTempoTimesToPlayString: String
    private var storedNumberOfBouncesString: String
    
    private var slowTempoError: String?
    private var slowTempoTimesToPlayError: String?
    private var midTempoError: String?
    private var midTempoTimesToPlayError: String?
    private var fastTempoError: String?
    private var fastTempoTimesToPlayError: String?
    private var numberOfBouncesError: String?
    
    init(slowTempo: Int, slowTempoTimesToPlay: Int, midTempo: Int, midTempoTimesToPlay: Int, fastTempo: Int, fastTempoTimesToPlay: Int, numberOfBounces: Int) {
        self.slowTempo = slowTempo
        self.slowTempoTimesToPlay = slowTempoTimesToPlay
        self.midTempo = midTempo
        self.midTempoTimesToPlay = midTempoTimesToPlay
        self.fastTempo = fastTempo
        self.fastTempoTimesToPlay = fastTempoTimesToPlay
        self.numberOfBounces = numberOfBounces
        
        self.storedSlowTempoString = String(slowTempo)
        self.storedSlowTempoTimesToPlayString = String(slowTempoTimesToPlay)
        self.storedMidTempoString = String(midTempo)
        self.storedMidTempoTimesToPlayString = String(midTempoTimesToPlay)
        self.storedFastTempoString = String(fastTempo)
        self.storedFastTempoTimesToPlayString = String(fastTempoTimesToPlay)
        self.storedNumberOfBouncesString = String(fastTempoTimesToPlay)
        
        validate()
    }
    
    var slowTempoString: String {
        get { storedSlowTempoString }
        set {
            storedSlowTempoString = newValue
            let result = validateTempo(storedSlowTempoString, fieldName: "Slow Tempo")
            applySlowTempoValidationResult(result)
        }
    }
    
    var slowTempoTimesToPlayString: String {
        get { storedSlowTempoTimesToPlayString }
        set {
            storedSlowTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedSlowTempoTimesToPlayString, fieldName: "Slow Tempo")
            applySlowTempoTimesToPlayValidationResult(result)
        }
    }
    
    var midTempoString: String {
        get { storedMidTempoString }
        set {
            storedMidTempoString = newValue
            let result = validateTempo(storedMidTempoString, fieldName: "Mid Tempo")
            applyMidTempoValidationResult(result)
        }
    }
    
    var midTempoTimesToPlayString: String {
        get { storedMidTempoTimesToPlayString }
        set {
            storedMidTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedMidTempoTimesToPlayString, fieldName: "Mid Tempo")
            applyMidTempoTimesToPlayValidationResult(result)
        }
    }
    
    var fastTempoString: String {
        get { storedFastTempoString }
        set {
            storedFastTempoString = newValue
            let result = validateTempo(storedSlowTempoString, fieldName: "Fast Tempo")
            applyFastTempoValidationResult(result)
        }
    }
    
    var fastTempoTimesToPlayString: String {
        get { storedFastTempoTimesToPlayString }
        set {
            storedFastTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedFastTempoTimesToPlayString, fieldName: "Fast Tempo")
            applyFastTempoTimesToPlayValidationResult(result)
        }
    }
    
    var numberOfBouncesString: String {
        get { storedNumberOfBouncesString }
        set {
            storedNumberOfBouncesString = newValue
            let result = validateNumberOfBounces(storedNumberOfBouncesString)
            applyNumberOfBouncesValidationResult(result)
        }
    }

    private func validateTempo(_ text: String, fieldName: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .failure("\(fieldName) is required.")
        } else {
            if let tempo = Int(text) {
                return .success(tempo)
            }
            else {
                return .failure("\(fieldName) must be a number greater than zero.")
            }
        }
    }
    
    private func validateTimesToPlay(_ text: String, fieldName: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .success(0)
        } else {
            if let timesToPlay = Int(text) {
                return .success(timesToPlay)
            }
            else {
                return .failure("\(fieldName) Times To Play must be a number greater than zero.")
            }
        }
    }
    
    private func validateNumberOfBounces(_ text: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .failure("Number Of Bounces is required.")
        } else {
            if let tempo = Int(text) {
                return .success(tempo)
            }
            else {
                return .failure("Number Of Bounces must be a number greater than zero.")
            }
        }
    }

    private func applySlowTempoValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            slowTempoError = nil
            slowTempo = value
        case .failure(let message):
            slowTempoError = message
        }
    }
    
    private func applySlowTempoTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            slowTempoTimesToPlayError = nil
            slowTempoTimesToPlay = value
        case .failure(let message):
            slowTempoTimesToPlayError = message
        }
    }
    
    private func applyMidTempoValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            midTempoError = nil
            midTempo = value
        case .failure(let message):
            midTempoError = message
        }
    }
    
    private func applyMidTempoTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            midTempoTimesToPlayError = nil
            midTempoTimesToPlay = value
        case .failure(let message):
            midTempoTimesToPlayError = message
        }
    }
    
    private func applyFastTempoValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            fastTempoError = nil
            fastTempo = value
        case .failure(let message):
            fastTempoError = message
        }
    }
    
    private func applyFastTempoTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            fastTempoTimesToPlayError = nil
            fastTempoTimesToPlay = value
        case .failure(let message):
            fastTempoTimesToPlayError = message
        }
    }
    
    private func applyNumberOfBouncesValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            numberOfBouncesError = nil
            numberOfBounces = value
        case .failure(let message):
            numberOfBouncesError = message
        }
    }

    func validate() {
        
    }
}
