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
    internal var slow: Int
    private var preciseSlow: Double
    internal var slowTimesToPlay: Int
    internal var mid: Int
    private var preciseMid: Double
    internal var midTimesToPlay: Int
    internal var fast: Int
    private var preciseFast: Double
    internal var fastTimesToPlay: Int
    
    private var storedSlowString: String
    private var storedSlowTimesToPlayString: String
    private var storedMidString: String
    private var storedMidTimesToPlayString: String
    private var storedFastString: String
    private var storedFastTimesToPlayString: String
    private var storedPlayOrder: PlayOrder?
    
    var slowError: String?
    var slowTimesToPlayError: String?
    var midError: String?
    var midTimesToPlayError: String?
    var fastError: String?
    var fastTimesToPlayError: String?
    var playOrderError: String?
    
    static func `default`() -> PlaybackBounceViewModel {
        PlaybackBounceViewModel(slow: 90, slowTimesToPlay: 1, mid: 100, midTimesToPlay: 1, fast: 110, fastTimesToPlay: 1)
    }
    
    init(slow: Int, slowTimesToPlay: Int, mid: Int, midTimesToPlay: Int, fast: Int, fastTimesToPlay: Int, playOrder: PlayOrder? = nil) {
        self.slow = slow
        self.preciseSlow = Double(slow)
        self.slowTimesToPlay = slowTimesToPlay
        self.mid = mid
        self.preciseMid = Double(mid)
        self.midTimesToPlay = midTimesToPlay
        self.fast = fast
        self.preciseFast = Double(fast)
        self.fastTimesToPlay = fastTimesToPlay
        self.storedPlayOrder = playOrder
        
        self.storedSlowString = String(slow)
        self.storedSlowTimesToPlayString = String(slowTimesToPlay)
        self.storedMidString = String(mid)
        self.storedMidTimesToPlayString = String(midTimesToPlay)
        self.storedFastString = String(fast)
        self.storedFastTimesToPlayString = String(fastTimesToPlay)
        
        validate()
    }

    func scaleTempos(by factor: Double) {
        if case .success = validateTempo(storedSlowString, fieldName: "Slow") {
            preciseSlow *= factor
            slow = scaledPlaybackValue(preciseSlow)
            storedSlowString = String(slow)
        }
        if case .success = validateTempo(storedMidString, fieldName: "Mid") {
            preciseMid *= factor
            mid = scaledPlaybackValue(preciseMid)
            storedMidString = String(mid)
        }
        if case .success = validateTempo(storedFastString, fieldName: "Fast") {
            preciseFast *= factor
            fast = scaledPlaybackValue(preciseFast)
            storedFastString = String(fast)
        }
        validate()
    }
    
    var slowString: String {
        get { storedSlowString }
        set {
            storedSlowString = newValue
            let result = validateTempo(storedSlowString, fieldName: "Slow")
            applySlowValidationResult(result)
            if case .success(let value) = result {
                preciseSlow = Double(value)
            }
            validateRelationships()
        }
    }
    
    var slowTimesToPlayString: String {
        get { storedSlowTimesToPlayString }
        set {
            storedSlowTimesToPlayString = newValue
            let result = validateTimesToPlay(storedSlowTimesToPlayString, fieldName: "Slow")
            applySlowTimesToPlayValidationResult(result)
            validateRelationships()
        }
    }
    
    var midString: String {
        get { storedMidString }
        set {
            storedMidString = newValue
            let result = validateTempo(storedMidString, fieldName: "Mid ")
            applyMidValidationResult(result)
            if case .success(let value) = result {
                preciseMid = Double(value)
            }
            validateRelationships()
        }
    }
    
    var midTimesToPlayString: String {
        get { storedMidTimesToPlayString }
        set {
            storedMidTimesToPlayString = newValue
            let result = validateTimesToPlay(storedMidTimesToPlayString, fieldName: "Mid")
            applyMidTimesToPlayValidationResult(result)
            validateRelationships()
        }
    }
    
    var fastString: String {
        get { storedFastString }
        set {
            storedFastString = newValue
            let result = validateTempo(storedFastString, fieldName: "Fast ")
            applyFastValidationResult(result)
            if case .success(let value) = result {
                preciseFast = Double(value)
            }
            validateRelationships()
        }
    }
    
    var fastTimesToPlayString: String {
        get { storedFastTimesToPlayString }
        set {
            storedFastTimesToPlayString = newValue
            let result = validateTimesToPlay(storedFastTimesToPlayString, fieldName: "Fast")
            applyFastTimesToPlayValidationResult(result)
            validateRelationships()
        }
    }
    
    var playOrder: PlayOrder? {
        get { storedPlayOrder }
        set {
            storedPlayOrder = newValue
            applyPlayOrderValidationResult(validatePlayOrder(storedPlayOrder))
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
    
    private func validatePlayOrder(_ playOrder: PlayOrder?) -> ValidationResult<PlayOrder> {
        guard let playOrder else {
            return .failure("Play Order is required.")
        }
        
        return .success(playOrder)
    }

    private func validateRelationships() {
        let slowTTP = successValue(validateTimesToPlay(storedSlowTimesToPlayString, fieldName: "Slow"))
        let midTTP = successValue(validateTimesToPlay(storedMidTimesToPlayString, fieldName: "Mid"))
        let fastTTP = successValue(validateTimesToPlay(storedFastTimesToPlayString, fieldName: "Fast"))
        
        // Reset times-to-play errors to field-level state
        applySlowTimesToPlayValidationResult(validateTimesToPlay(storedSlowTimesToPlayString, fieldName: "Slow"))
        applyMidTimesToPlayValidationResult(validateTimesToPlay(storedMidTimesToPlayString, fieldName: "Mid"))
        applyFastTimesToPlayValidationResult(validateTimesToPlay(storedFastTimesToPlayString, fieldName: "Fast"))
        
        // Rule 2: resolve each  (empty allowed only when its timesToPlay is 0/empty)
        let slowX = resolveTempo(storedSlowString, timesToPlay: slowTTP, fieldName: "Slow")
        let midX = resolveTempo(storedMidString, timesToPlay: midTTP, fieldName: "Mid")
        let fastX = resolveTempo(storedFastString, timesToPlay: fastTTP, fieldName: "Fast")
        
        slowError = slowX.error
        if let v = slowX.value { slow = v }
        midError = midX.error
        if let v = midX.value { mid = v }
        fastError = fastX.error
        if let v = fastX.value { fast = v }
        
        // Rule 1: only one timesToPlay can be 0/empty
        let zeroCount = [slowTTP, midTTP, fastTTP].filter { $0 == 0 }.count
        if zeroCount > 1 {
            let message = "Only one tempo can have empty or zero Times To Play."
            if slowTTP == 0 { slowTimesToPlayError = message }
            if midTTP == 0 { midTimesToPlayError = message }
            if fastTTP == 0 { fastTimesToPlayError = message }
        }
        
        // Rule 3: slow < mid < fast, comparing only tempos that are present (non-empty and valid)
        let slowPresent = slowX.isPresent ? slowX.value : nil
        let midPresent = midX.isPresent ? midX.value : nil
        let fastPresent = fastX.isPresent ? fastX.value : nil
        
        if let s = slowPresent, let m = midPresent, s >= m, midError == nil {
            midError = "Mid must be greater than Slow."
        }
        if let m = midPresent, let f = fastPresent, m >= f, fastError == nil {
            fastError = "Fast must be greater than Mid."
        }
        if midPresent == nil, let s = slowPresent, let f = fastPresent, s >= f, fastError == nil {
            fastError = "Fast must be greater than Slow."
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

    private func applySlowValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            slowError = nil
            slow = value
        case .failure(let message):
            slowError = message
        }
    }
    
    private func applySlowTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            slowTimesToPlayError = nil
            slowTimesToPlay = value
        case .failure(let message):
            slowTimesToPlayError = message
        }
    }
    
    private func applyMidValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            midError = nil
            mid = value
        case .failure(let message):
            midError = message
        }
    }
    
    private func applyMidTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            midTimesToPlayError = nil
            midTimesToPlay = value
        case .failure(let message):
            midTimesToPlayError = message
        }
    }
    
    private func applyFastValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            fastError = nil
            fast = value
        case .failure(let message):
            fastError = message
        }
    }
    
    private func applyFastTimesToPlayValidationResult(_ result: ValidationResult<Int>) {
        switch result {
        case .success(let value):
            fastTimesToPlayError = nil
            fastTimesToPlay = value
        case .failure(let message):
            fastTimesToPlayError = message
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
        slowError == nil && slowTimesToPlayError == nil &&
        midError == nil && midTimesToPlayError == nil &&
        fastError == nil && fastTimesToPlayError == nil &&
        playOrderError == nil
    }

    func validate() {
        applySlowValidationResult(validateTempo(storedSlowString, fieldName: "Slow "))
        applySlowTimesToPlayValidationResult(validateTimesToPlay(storedSlowTimesToPlayString, fieldName: "Slow "))
        applyMidValidationResult(validateTempo(storedMidString, fieldName: "Mid "))
        applyMidTimesToPlayValidationResult(validateTimesToPlay(storedMidTimesToPlayString, fieldName: "Mid "))
        applyFastValidationResult(validateTempo(storedFastString, fieldName: "Fast "))
        applyFastTimesToPlayValidationResult(validateTimesToPlay(storedFastTimesToPlayString, fieldName: "Fast "))
        applyPlayOrderValidationResult(validatePlayOrder(storedPlayOrder))
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
        
        bounce.slow = slow
        bounce.timesToPlaySlow = slowTimesToPlay
        bounce.mid = mid
        bounce.timesToPlayMid = midTimesToPlay
        bounce.fast = fast
        bounce.timesToPlayFast = fastTimesToPlay
        bounce.playOrder = storedPlayOrder
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
