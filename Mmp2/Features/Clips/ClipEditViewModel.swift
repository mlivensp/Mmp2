//
//  ClipEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/28/26.
//

import Foundation

extension ClipEditView {
    @Observable
    final class ViewModel {
        var clip: Clip
        var source: Source
        
        // Editable fields
        var name: String {
            didSet {
                _ = validateName()
            }
        }
        
        var startTimeString: String {
            didSet {
                _ = validateStartEndSeconds()
            }
        }
        
        var startSeconds: Double
        
        var endTimeString: String {
            didSet {
                _ = validateStartEndSeconds()
            }
        }
        
        var endSeconds: Double
        
        var isFavorite: Bool
        var notes: String
        
        var startMeasureString: String {
            didSet {
                _ = validateStartEndMeasures()
            }
        }
        
        var startMeasure: Int?
        
        var endMeasureString: String {
            didSet {
                _ = validateStartEndMeasures()
            }
        }
        
        var endMeasure: Int?
        
        // Per-field errors
        var nameError: String?
        var startSecondsError: String?
        var endSecondsError: String?
        var startMeasureError: String?
        var endMeasureError: String?
        
        var measureMode = false
        var isValid = true
        
        init(clip: Clip, source: Source) {
            self.clip = clip
            self.source = source
            
            self.name = clip.primitiveName
            self.startSeconds = clip.startSeconds
            self.startTimeString = String(clip.startSeconds)
            self.endSeconds = clip.endSeconds
            self.endTimeString = String(clip.endSeconds)
            self.isFavorite = clip.isFavorite
            self.notes = clip.notes ?? ""
            self.startMeasureString = clip.startMeasure.map(String.init) ?? ""
            self.endMeasureString = clip.endMeasure.map(String.init) ?? ""
            measureMode = determineMeasureMode()
            isValid = validate()
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
        
        fileprivate func validateName() -> Bool {
            nameError = nil
            
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                nameError = "Name is required."
                return false
            }
            
            return true
        }
        
        fileprivate func validateStartEndSeconds() -> Bool {
            startSecondsError = nil
            endSecondsError = nil

            var isValid = true
            var parsedStart: Double?
            var parsedEnd: Double?

            // Validate start
            switch validateSeconds(startTimeString, fieldName: "Start time") {
            case .success(let seconds):
                parsedStart = seconds
            case .failure(let error):
                startSecondsError = error
                isValid = false
            }

            // Validate end
            switch validateSeconds(endTimeString, fieldName: "End time") {
            case .success(let seconds):
                parsedEnd = seconds
            case .failure(let error):
                endSecondsError = error
                isValid = false
            }

            // If either failed, we’re done (both have been checked)
            guard isValid,
                  let start = parsedStart,
                  let end = parsedEnd
            else {
                return false
            }

            // Range validation using parsed values
            if end <= start {
                startSecondsError = "Start time must be before end time."
                endSecondsError = "End time must be after start time."
                return false
            }

            // Only now mutate state
            startSeconds = start
            endSeconds = end

            return true
        }
        
        fileprivate func validateSeconds(_ text: String, fieldName: String) -> FieldValidation<Double> {
            do {
                return .success(try TimeFormatter.shared.seconds(from: text))
            } catch {
                return .failure("\(fieldName) must be a valid time string.")
            }

        }

        fileprivate func validateStartEndMeasures() -> Bool {
            startMeasureError = nil
            endMeasureError = nil

            var isValid = true
            var parsedStart: Int?
            var parsedEnd: Int?

            // Validate start
            switch validateMeasure(startMeasureString, fieldName: "Start measure") {
            case .success(let value):
                parsedStart = value
            case .failure(let error):
                startMeasureError = error
                isValid = false
            }

            // Validate end
            switch validateMeasure(endMeasureString, fieldName: "End measure") {
            case .success(let value):
                parsedEnd = value
            case .failure(let error):
                endMeasureError = error
                isValid = false
            }

            // If either failed, we’re done (both have been checked)
            guard isValid,
                  let start = parsedStart,
                  let end = parsedEnd
            else {
                return false
            }

            // Range validation using parsed values
            if end <= start {
                startMeasureError = "Start measure must be before end measure."
                endMeasureError = "End measure must be after start measure."
                return false
            }

            // Only now mutate state
            clip.startMeasure = start
            clip.endMeasure = end

            return true
        }

        fileprivate func validateMeasure(_ text: String, fieldName: String) -> FieldValidation<Int> {
            guard !text.isEmpty else {
                return .failure("\(fieldName) is required.")
            }
            guard let value = Int(text) else {
                return .failure("\(fieldName) must be a whole number.")
            }
            return .success(value)
        }
        
        func validate() -> Bool {
            isValid = true
            
            let isNameValid = validateName()
            isValid = isValid && isNameValid
            
            if measureMode == false {
                let isStartEndValid = validateStartEndSeconds()
                isValid = isValid && isStartEndValid
            } else {
                let isStartEndValid = validateStartEndMeasures()
                isValid = isValid && isStartEndValid
            }

            return isValid
        }
        
        func save() -> Bool {
            guard validate() else { return false }
            
            clip.primitiveName = name
            clip.name_normalized = name.normalizedForSearch
            clip.startSeconds = startSeconds
            clip.endSeconds = endSeconds
            clip.isFavorite = isFavorite
            clip.notes = notes.isEmpty ? nil : notes
            clip.startMeasure = startMeasure
            clip.endMeasure = endMeasure
            
            return true
        }
    }
    
}
