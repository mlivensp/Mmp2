//
//  PlaybackBounceViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation
import OSLog
import SwiftData

@Observable
final class PlaybackBounceViewModel {
    internal var slowTempo: Int
    internal var slowTempoTimesToPlay: Int
    internal var midTempo: Int
    internal var midTempoTimesToPlay: Int
    internal var fastTempo: Int
    internal var fastTempoTimesToPlay: Int
    internal var numberOfBounces: Int
    internal var playOrder: PlayOrder?
    
    private var storedSlowTempoString: String
    private var storedSlowTempoTimesToPlayString: String
    private var storedMidTempoString: String
    private var storedMidTempoTimesToPlayString: String
    private var storedFastTempoString: String
    private var storedFastTempoTimesToPlayString: String
    private var storedNumberOfBouncesString: String
    
    var slowTempoError: String?
    var slowTempoTimesToPlayError: String?
    var midTempoError: String?
    var midTempoTimesToPlayError: String?
    var fastTempoError: String?
    var fastTempoTimesToPlayError: String?
    var numberOfBouncesError: String?
    var playOrderError: String?
    
    var playOrders: [PlayOrder] = []
    
    static func `default`(context: ModelContext) -> PlaybackBounceViewModel {
        PlaybackBounceViewModel(slowTempo: 90, slowTempoTimesToPlay: 1, midTempo: 100, midTempoTimesToPlay: 1, fastTempo: 110, fastTempoTimesToPlay: 1, numberOfBounces: 1, context: context)
    }
    
    init(slowTempo: Int, slowTempoTimesToPlay: Int, midTempo: Int, midTempoTimesToPlay: Int, fastTempo: Int, fastTempoTimesToPlay: Int, numberOfBounces: Int, playOrder: PlayOrder? = nil, context: ModelContext) {
        self.slowTempo = slowTempo
        self.slowTempoTimesToPlay = slowTempoTimesToPlay
        self.midTempo = midTempo
        self.midTempoTimesToPlay = midTempoTimesToPlay
        self.fastTempo = fastTempo
        self.fastTempoTimesToPlay = fastTempoTimesToPlay
        self.numberOfBounces = numberOfBounces
        self.playOrder = playOrder
        
        self.storedSlowTempoString = String(slowTempo)
        self.storedSlowTempoTimesToPlayString = String(slowTempoTimesToPlay)
        self.storedMidTempoString = String(midTempo)
        self.storedMidTempoTimesToPlayString = String(midTempoTimesToPlay)
        self.storedFastTempoString = String(fastTempo)
        self.storedFastTempoTimesToPlayString = String(fastTempoTimesToPlay)
        self.storedNumberOfBouncesString = String(numberOfBounces)
        
        playOrders = fetchPlayOrders(context: context)
        validate()
    }
    
    var slowTempoString: String {
        get { storedSlowTempoString }
        set {
            storedSlowTempoString = newValue
            let result = validateTempo(storedSlowTempoString, fieldName: "Slow Tempo")
            applySlowTempoValidationResult(result)
            validateRelationships()
        }
    }
    
    var slowTempoTimesToPlayString: String {
        get { storedSlowTempoTimesToPlayString }
        set {
            storedSlowTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedSlowTempoTimesToPlayString, fieldName: "Slow Tempo")
            applySlowTempoTimesToPlayValidationResult(result)
            validateRelationships()
        }
    }
    
    var midTempoString: String {
        get { storedMidTempoString }
        set {
            storedMidTempoString = newValue
            let result = validateTempo(storedMidTempoString, fieldName: "Mid Tempo")
            applyMidTempoValidationResult(result)
            validateRelationships()
        }
    }
    
    var midTempoTimesToPlayString: String {
        get { storedMidTempoTimesToPlayString }
        set {
            storedMidTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedMidTempoTimesToPlayString, fieldName: "Mid Tempo")
            applyMidTempoTimesToPlayValidationResult(result)
            validateRelationships()
        }
    }
    
    var fastTempoString: String {
        get { storedFastTempoString }
        set {
            storedFastTempoString = newValue
            let result = validateTempo(storedFastTempoString, fieldName: "Fast Tempo")
            applyFastTempoValidationResult(result)
            validateRelationships()
        }
    }
    
    var fastTempoTimesToPlayString: String {
        get { storedFastTempoTimesToPlayString }
        set {
            storedFastTempoTimesToPlayString = newValue
            let result = validateTimesToPlay(storedFastTempoTimesToPlayString, fieldName: "Fast Tempo")
            applyFastTempoTimesToPlayValidationResult(result)
            validateRelationships()
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
    
    // MARK: validation

    private func validateTempo(_ text: String, fieldName: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .failure("\(fieldName) is required.")
        } else {
            if let tempo = Int(text) {
                
                if tempo > 0 {
                    return .success(tempo)
                }
            }
        }
        return .failure("\(fieldName) must be a number greater than zero.")
    }
    
    private func validateTimesToPlay(_ text: String, fieldName: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .success(0)
        } else {
            if let timesToPlay = Int(text) {
                return .success(timesToPlay)
            }
        }
        
        return .failure("\(fieldName) Times To Play must be a number or empty.")
    }
    
    private func validateNumberOfBounces(_ text: String) -> ValidationResult<Int> {
        if text.isEmpty {
            return .failure("Number Of Bounces is required.")
        } else {
            if let tempo = Int(text) {
                
                if tempo > 0 {
                    return .success(tempo)
                }
            }
        }
        
        return .failure("Number Of Bounces must be a number greater than zero.")
    }
    
    private func validatePlayOrder() -> ValidationResult<PlayOrder> {
        guard let playOrder else {
            return .failure("Play Order is required.")
        }
        
        return .success(playOrder)
    }

    private func validateRelationships() {
        let slowTTP = successValue(validateTimesToPlay(storedSlowTempoTimesToPlayString, fieldName: "Slow Tempo"))
        let midTTP = successValue(validateTimesToPlay(storedMidTempoTimesToPlayString, fieldName: "Mid Tempo"))
        let fastTTP = successValue(validateTimesToPlay(storedFastTempoTimesToPlayString, fieldName: "Fast Tempo"))
        
        // Reset times-to-play errors to field-level state
        applySlowTempoTimesToPlayValidationResult(validateTimesToPlay(storedSlowTempoTimesToPlayString, fieldName: "Slow Tempo"))
        applyMidTempoTimesToPlayValidationResult(validateTimesToPlay(storedMidTempoTimesToPlayString, fieldName: "Mid Tempo"))
        applyFastTempoTimesToPlayValidationResult(validateTimesToPlay(storedFastTempoTimesToPlayString, fieldName: "Fast Tempo"))
        
        // Rule 2: resolve each tempo (empty allowed only when its timesToPlay is 0/empty)
        let slow = resolveTempo(storedSlowTempoString, timesToPlay: slowTTP, fieldName: "Slow Tempo")
        let mid = resolveTempo(storedMidTempoString, timesToPlay: midTTP, fieldName: "Mid Tempo")
        let fast = resolveTempo(storedFastTempoString, timesToPlay: fastTTP, fieldName: "Fast Tempo")
        
        slowTempoError = slow.error
        if let v = slow.value { slowTempo = v }
        midTempoError = mid.error
        if let v = mid.value { midTempo = v }
        fastTempoError = fast.error
        if let v = fast.value { fastTempo = v }
        
        // Rule 1: only one timesToPlay can be 0/empty
        let zeroCount = [slowTTP, midTTP, fastTTP].filter { $0 == 0 }.count
        if zeroCount > 1 {
            let message = "Only one tempo can have empty or zero Times To Play."
            if slowTTP == 0 { slowTempoTimesToPlayError = message }
            if midTTP == 0 { midTempoTimesToPlayError = message }
            if fastTTP == 0 { fastTempoTimesToPlayError = message }
        }
        
        // Rule 3: slow < mid < fast, comparing only tempos that are present (non-empty and valid)
        let slowPresent = slow.isPresent ? slow.value : nil
        let midPresent = mid.isPresent ? mid.value : nil
        let fastPresent = fast.isPresent ? fast.value : nil
        
        if let s = slowPresent, let m = midPresent, s >= m, midTempoError == nil {
            midTempoError = "Mid Tempo must be greater than Slow Tempo."
        }
        if let m = midPresent, let f = fastPresent, m >= f, fastTempoError == nil {
            fastTempoError = "Fast Tempo must be greater than Mid Tempo."
        }
        if midPresent == nil, let s = slowPresent, let f = fastPresent, s >= f, fastTempoError == nil {
            fastTempoError = "Fast Tempo must be greater than Slow Tempo."
        }
    }
    
    private struct ResolvedTempo {
        var value: Int?      // value to store (0 when legitimately empty); nil leaves previous value
        var error: String?
        var isPresent: Bool  // non-empty and valid
    }
    
    private func resolveTempo(_ text: String, timesToPlay: Int?, fieldName: String) -> ResolvedTempo {
        if text.isEmpty {
            switch timesToPlay {
            case .some(0):
                return ResolvedTempo(value: 0, error: nil, isPresent: false)
            case .some:
                return ResolvedTempo(value: nil, error: "\(fieldName) can only be empty if \(fieldName) Times To Play is empty or zero.", isPresent: false)
            case .none:
                // timesToPlay itself is invalid, so we can't evaluate; keep field-level error
                return ResolvedTempo(value: nil, error: "\(fieldName) is required.", isPresent: false)
            }
        }
        switch validateTempo(text, fieldName: fieldName) {
        case .success(let v): return ResolvedTempo(value: v, error: nil, isPresent: true)
        case .failure(let message): return ResolvedTempo(value: nil, error: message, isPresent: false)
        }
    }
    // MARK: apply validation results

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
    
    private func applyPlayOrderValidationResult(_ result: ValidationResult<PlayOrder>) {
        switch result {
        case .success:
            playOrderError = nil
        case .failure(let message):
            playOrderError = message
        }
    }
    
    var isValid: Bool {
        slowTempoError == nil && slowTempoTimesToPlayError == nil &&
        midTempoError == nil && midTempoTimesToPlayError == nil &&
        fastTempoError == nil && fastTempoTimesToPlayError == nil &&
        numberOfBouncesError == nil && playOrderError == nil
    }

    func validate() {
        applySlowTempoValidationResult(validateTempo(storedSlowTempoString, fieldName: "Slow Tempo"))
        applySlowTempoTimesToPlayValidationResult(validateTimesToPlay(storedSlowTempoTimesToPlayString, fieldName: "Slow Tempo"))
        applyMidTempoValidationResult(validateTempo(storedMidTempoString, fieldName: "Mid Tempo"))
        applyMidTempoTimesToPlayValidationResult(validateTimesToPlay(storedMidTempoTimesToPlayString, fieldName: "Mid Tempo"))
        applyFastTempoValidationResult(validateTempo(storedFastTempoString, fieldName: "Fast Tempo"))
        applyFastTempoTimesToPlayValidationResult(validateTimesToPlay(storedFastTempoTimesToPlayString, fieldName: "Fast Tempo"))
        applyNumberOfBouncesValidationResult(validateNumberOfBounces(storedNumberOfBouncesString))
        applyPlayOrderValidationResult(validatePlayOrder())
        validateRelationships()
    }
    
    // MARK: - Helper for extracting success values
    
    private func successValue(_ result: ValidationResult<Int>) -> Int? {
        if case .success(let value) = result { return value }
        return nil
    }
    
    // MARK: data handling
    
    func apply(to bounce: PlaybackBounce) throws {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackBounce")
        }
        
        bounce.slowTempo = slowTempo
        bounce.timesToPlaySlowTempo = slowTempoTimesToPlay
        bounce.midTempo = midTempo
        bounce.timesToPlayMidTempo = midTempoTimesToPlay
        bounce.fastTempo = fastTempo
        bounce.timesToPlayFastTempo = fastTempoTimesToPlay
        bounce.numberOfBounces = numberOfBounces
        bounce.playOrder = playOrder
    }
    
    func fetchPlayOrders(context: ModelContext) -> [PlayOrder] {
        do {
            return try context.fetch(
                FetchDescriptor<PlayOrder>(
                    sortBy: [SortDescriptor(\.sortOrder)]
                )
            )
        } catch {
            Logger.data.error("Error fetching playOrders: \(error.localizedDescription)")
            return []
        }
    }
}
