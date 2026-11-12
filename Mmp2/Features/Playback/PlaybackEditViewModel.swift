//
//  PlaybackEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/3/26.
//

import Foundation
import SwiftData

@Observable
final class PlaybackEditViewModel {
    private var timesToPlay: Int?
    private var storedTimesToPlayString: String

    var bpm: Int? {
        didSet {
            guard oldValue != bpm else { return }
            let previousBpm = oldValue ?? 100
            let currentBpm = bpm ?? 100
            guard previousBpm > 0, currentBpm > 0 else { return }

            let factor = Double(currentBpm) / Double(previousBpm)
            constantVM.scaleRate(by: factor)
            progressionVM.scaleRates(by: factor)
            // TODO: sequence
        }
    }
    var context: ModelContext
    
    var mode: PlaybackMode
    var constantVM: PlaybackConstantViewModel
    var progressionVM: PlaybackProgressionViewModel
    
    var timesToPlayError: String? = nil

    init(playback: Playback, bpm: Int?, context: ModelContext) {
        self.timesToPlay = playback.timesToPlay
        self.bpm = bpm
        self.context = context
        
        if let constant = playback.playbackConstant {
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel(
                value: constant.value
            )
            self.progressionVM = PlaybackProgressionViewModel.default()
        } else if let progression = playback.playbackProgression {
            self.mode = .progression
            self.progressionVM = PlaybackProgressionViewModel(start: progression.start, increment: progression.increment, max: progression.max, timesToPlayEach: progression.timesToPlayEach)
            self.constantVM = PlaybackConstantViewModel.default()
            // TODO: sequence
        } else {
            // default mode for new clips
            self.mode = .constant
            self.constantVM = PlaybackConstantViewModel.default()
            self.progressionVM = PlaybackProgressionViewModel.default()
        }
        
        if let timesToPlay = playback.timesToPlay {
            storedTimesToPlayString = String(timesToPlay)
        } else {
            storedTimesToPlayString = ""
        }
        
        validate()
    }
    
    var timesToPlayString: String {
        get { return storedTimesToPlayString }
        set {
            self.storedTimesToPlayString = newValue
            let result = validateTimesToPlay(storedTimesToPlayString)
            applyTimesToPlayValidationResult(result)
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
        timesToPlayError = nil
        
        let timesToPlayResult = validateTimesToPlay(storedTimesToPlayString)
        applyTimesToPlayValidationResult(timesToPlayResult)
    }
    
    var isValid: Bool {
        timesToPlayError == nil
    }

    func apply(to playback: Playback, context: ModelContext) throws {
        validate()
        
        guard isValid else {
            throw AppError.attemptToSaveInvalidState("PlaybackConstant")
        }
        
        playback.timesToPlay = timesToPlay
        
        // 1. Switch mode (handles deletion + creation)
        playback.switchMode(to: mode, context: context)

        // 2. Apply values to the active submodel
        switch mode {
        case .constant:
            try constantVM.apply(to: playback.playbackConstant!)
        case .progression:
            try progressionVM.apply(to: playback.playbackProgression!)
            // TODO: sequence
        }
    }
}

func scaledPlaybackValue(_ value: Double) -> Int {
    let scaledValue = value.rounded()
    guard scaledValue.isFinite else { return Int(value) }
    if scaledValue >= Double(Int.max) { return Int.max }
    return max(1, Int(scaledValue))
}
