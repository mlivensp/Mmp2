//
//  ClipEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/28/26.
//

import Foundation
import SwiftData

extension ClipEditViewContent {
    @Observable
    final class ViewModel {
        var clip: Clip
        var source: Source
        let context: ModelContext
        
        var playbackVM: PlaybackEditViewModel
        
        var measureMode = false

        internal var storedNameString: String
        private var storedBpmString: String
        private var storedStartTimeString: String
        private var storedEndTimeString: String
        private var storedFirstMeasureString: String
        private var storedLastMeasureString: String
        
        internal var bpm: Int?
        internal var startSeconds: Double
        internal var endSeconds: Double
        internal var firstMeasure: Int?
        internal var lastMeasure: Int?
        internal var isFavorite: Bool
        internal var notes: String
        
        // Per-field errors
        var nameError: String?
        var bpmError: String?
        var startSecondsError: String?
        var endSecondsError: String?
        var firstMeasureError: String?
        var lastMeasureError: String?
        
        init(clip: Clip, source: Source, context: ModelContext) {
            self.clip = clip
            self.source = source
            self.context = context
            
            self.playbackVM = PlaybackEditViewModel(playback: clip.playback, bpm: clip.media.bpm)
            
            storedNameString = clip.primitiveName
            
            if let bpm = clip.media.bpm {
                self.storedBpmString = String(bpm)
            } else {
                self.storedBpmString = ""
            }
            
            self.startSeconds = clip.startSeconds
            self.endSeconds = clip.endSeconds
            
            self.storedStartTimeString = TimeFormatter.shared.string(from: clip.startSeconds)
            self.storedEndTimeString = TimeFormatter.shared.string(from: clip.endSeconds)
            
            if let firstMeasure = clip.firstMeasure {
                storedFirstMeasureString = String(firstMeasure)
            } else {
                storedFirstMeasureString = ""
            }
            
            if let lastMeasure = clip.lastMeasure {
                storedLastMeasureString = String(lastMeasure)
            } else {
                storedLastMeasureString = ""
            }

            self.isFavorite = clip.isFavorite
            self.notes = clip.notes ?? ""
            
            measureMode = determineMeasureMode()
            _ = validate()
        }
        
        fileprivate func determineMeasureMode() -> Bool {
            if source.measure1Start == nil {
                return false
            } else {
                if clip.isNew {
                    return true
                } else {
                    if !startMeasureString.isEmpty {
                        return true
                    }
                }
            }
            
            return false
        }

        // MARK: Editable fields
        var name: String {
            get { return storedNameString }
            set {
                storedNameString = newValue
                
                let result = validateName(storedNameString)
                applyNameValidationResult(result)
            }
        }
        
        var bpmString: String {
            get { return storedBpmString }
            set {
                storedBpmString = newValue
                
                let result = validateBpm(storedBpmString)
                applyBpmValidationResult(result)
            }
        }
        
        var startTimeString: String {
            get { return storedStartTimeString }
            set {
                storedStartTimeString = newValue
                let _ = validateStartEndSeconds()
            }
        }
                
        var endTimeString: String {
            get { return storedEndTimeString }
            set {
                storedEndTimeString = newValue
                let _ = validateStartEndSeconds()
            }
        }
        
        
        var startMeasureString: String {
            get { return storedFirstMeasureString }
            set {
                storedFirstMeasureString = newValue
                _ = validateStartEndMeasures()
            }
        }
                
        var endMeasureString: String {
            get { return storedLastMeasureString }
            set {
                storedLastMeasureString = newValue
                _ = validateStartEndMeasures()
            }
        }
        
        // MARK: validation functions
        fileprivate func validateName(_ nameValue: String) -> ValidationResult<String> {
            nameError = nil
            
            if nameValue.trimmingCharacters(in: .whitespaces).isEmpty {
                return .failure("Name is required.")
            }
            
            return validateNameUniqueness(nameValue, clip: clip, existingClips: source.clips)
        }
        
        fileprivate func validateNameUniqueness(_ nameValue: String, clip: Clip, existingClips: [Clip]) -> ValidationResult<String> {
            
            var clipsToCheck: [Clip]
            
            if clip.isNew {
                clipsToCheck = existingClips
            } else {
                clipsToCheck = existingClips.filter { $0.persistentModelID != clip.persistentModelID}
            }
            
            let sameNameClips = clipsToCheck.filter{ $0.primitiveName == nameValue }
            
            if sameNameClips.isEmpty {
                return .success(nameValue)
            } else {
                return .failure("A clip with this name already exists.")
            }
        }
        
        fileprivate func validateBpm(_ bpmValue: String) -> ValidationResult<Int?> {
            bpmError = nil
            
            if bpmValue.isEmpty {
                return .success(nil)
            } else {
                if let bpm = Int(bpmValue) {
                    return .success(bpm)
                }
            }
            
            return .failure("BPM must be a valid whole number.")
        }
        
        fileprivate func validateStartEndSeconds() -> Bool {
            startSecondsError = nil
            endSecondsError = nil

            // Validate start
            let startSecondsResult = validateSeconds(startTimeString, fieldName: "Start Time")
            applyStartSecondsValidationResult(startSecondsResult)
            
            // Validate end
            let endSecondsValidationResult = validateSeconds(endTimeString, fieldName: "End time")
            applyEndSecondsValidationResult(endSecondsValidationResult)
            
            // If either failed, we’re done (both have been checked)
            guard startSecondsError == nil, endSecondsError == nil else {
                return false
            }

            // Range validation
            if endSeconds <= startSeconds {
                startSecondsError = "Start time must be before end time."
                endSecondsError = "End time must be after start time."
                return false
            }

            return true
        }
        
        fileprivate func validateSeconds(_ text: String, fieldName: String) -> ValidationResult<Double> {
            do {
                return .success(try TimeFormatter.shared.seconds(from: text))
            } catch {
                return .failure("\(fieldName) must be a valid time string.")
            }
        }

        fileprivate func validateStartEndMeasures() -> Bool {
            firstMeasureError = nil
            lastMeasureError = nil

            var isValid = true

            // Validate start
            let firstMeasureValidationResult = validateMeasure(startMeasureString, fieldName: "Start measure")
            applyFirstMeasureValidationResult(firstMeasureValidationResult)

            // Validate end
            let lastMeasureValidationResult = validateMeasure(endMeasureString, fieldName: "End measure")
            applyLastMeasureValidationResult(lastMeasureValidationResult)

            // If either failed, we’re done (both have been checked)
            guard firstMeasureError == nil, lastMeasureError == nil else {
                return false
            }
            
            guard let firstMeasure, let lastMeasure else {
                return false
            }

            // Range validation using parsed values
            if lastMeasure <= firstMeasure {
                firstMeasureError = "Start measure must be before end measure."
                lastMeasureError = "End measure must be after start measure."
                return false
            }

            return true
        }

        fileprivate func validateMeasure(_ text: String, fieldName: String) -> ValidationResult<Int> {
            guard !text.isEmpty else {
                return .failure("\(fieldName) is required.")
            }
            
            guard let value = Int(text) else {
                return .failure("\(fieldName) must be a whole number.")
            }
            
            return .success(value)
        }
        
        // MARK: apply validation results
        private func applyNameValidationResult(_ result: ValidationResult<String>) {
            switch result {
            case .success:
                nameError = nil
            case .failure(let message):
                nameError = message
            }
        }
        
        private func applyBpmValidationResult(_ result: ValidationResult<Int?>) {
            switch result {
            case .success(let value):
                bpmError = nil
                bpm = value
                playbackVM.bpm = value
            case .failure(let message):
                bpmError = message
            }
        }
        
        private func applyStartSecondsValidationResult(_ result: ValidationResult<Double>) {
            switch result {
            case .success(let seconds):
                startSecondsError = nil
                startSeconds = seconds
            case .failure(let error):
                startSecondsError = error
            }
        }
        
        private func applyEndSecondsValidationResult(_ result: ValidationResult<Double>) {
            switch result  {
            case .success(let seconds):
                endSecondsError = nil
                endSeconds = seconds
            case .failure(let error):
                endSecondsError = error
            }
        }
        
        private func applyFirstMeasureValidationResult(_ result: ValidationResult<Int>) {
            switch result  {
            case .success(let value):
                firstMeasureError = nil
                firstMeasure = value
            case .failure(let error):
                firstMeasureError = error
            }
        }
        
        private func applyLastMeasureValidationResult(_ result: ValidationResult<Int>) {
            switch result {
            case .success(let value):
                lastMeasureError = nil
                lastMeasure = value
            case .failure(let error):
                lastMeasureError = error
            }
        }

        var isValid: Bool {
            nameError == nil && bpmError == nil && startSecondsError == nil && endSecondsError == nil && firstMeasureError == nil && lastMeasureError == nil
        }
        
        func validate() -> Bool {
            let validateNameResult = validateName(storedNameString)
            applyNameValidationResult(validateNameResult)
            
            if measureMode == false {
                firstMeasureError = nil
                lastMeasureError = nil
                _ = validateStartEndSeconds()
            } else {
                startSecondsError = nil
                endSecondsError = nil
                _ = validateStartEndMeasures()
            }

            return isValid
        }
        
        func save() throws -> Bool {
            guard validate() else { return false }
            
            clip.primitiveName = name
            clip.name_normalized = name.normalizedForSearch
            // TODO: need to calculate seconds from measures
            clip.startSeconds = startSeconds
            clip.endSeconds = endSeconds
            clip.isFavorite = isFavorite
            clip.notes = notes.isEmpty ? nil : notes
            
            if measureMode {
                clip.firstMeasure = firstMeasure
                clip.lastMeasure = lastMeasure
            } else {
                clip.firstMeasure = nil
                clip.lastMeasure = nil
            }
            
            playbackVM.apply(to: clip.playback)
            
//            if clip.isNew {
//                let duration = endSeconds - startSeconds
//                let media = createMedia(bpm: bpm, duration: duration)
//                clip.media = media
//                
//                clip.playback = Playback()
//                clip.source = source
//                context.insert(clip)
//            }
            
            try context.save()
            return true
        }
        
//        fileprivate func createMedia(bpm: Int?, duration: Double) -> Media {
//            let media = Media(bpm: bpm, path: "", duration: duration)
//            return media
//        }
    }
}
