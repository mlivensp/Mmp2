//
//  SourceEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/5/26.
//

import Foundation
import SwiftData

extension SourceEditView {
    @Observable
    final class ViewModel {
        var source: Source
        var collection: MediaCollection
        var context: ModelContext
        
        var playbackVM: PlaybackEditViewModel

        internal var bpm: Int?
        internal var sortOrder: Int
        internal var measure1Start: Double?
        internal var isFavorite: Bool
        internal var notes: String

        internal var storedNameString: String
        private var storedBpmString: String
        private var storedSortOrderString: String
        private var storedMeasure1StartString: String
        private var storedSourceGroupString: String
        private var storedSourceGroup: SourceGroup?

        var nameError: String?
        var bpmError: String?
        var sortOrderError: String?
        var measure1StartError: String?
        
        init(source: Source, collection: MediaCollection, context: ModelContext) {
            self.source = source
            self.collection = collection
            self.context = context
            
            self.playbackVM = PlaybackEditViewModel(playback: source.playback, bpm: source.media.bpm, context: context)
            
            self.storedNameString = source.primitiveName
            self.bpm = source.media.bpm
            
            if let bpm = source.media.bpm {
                self.storedBpmString = String(bpm)
            } else {
                self.storedBpmString = ""
            }
            
            self.sortOrder = source.sortOrder
            self.storedSortOrderString = String(source.sortOrder)
            
            self.measure1Start = source.measure1Start
            
            if let measure1Start = source.measure1Start {
                self.storedMeasure1StartString = TimeFormatter.shared.string(from: measure1Start)
            } else {
                self.storedMeasure1StartString = ""
            }
            
            self.isFavorite = source.isFavorite
            self.storedSourceGroup = source.sourceGroup
            
            if let sourceGroup = source.sourceGroup {
                storedSourceGroupString = sourceGroup.primitiveName
            } else {
                storedSourceGroupString = ""
            }
            
            self.notes = source.notes ?? ""
            _ = validate()
        }
        
        var mediaPath: String {
            get { source.media.path ?? "" }
            set { source.media.path = newValue }
        }
        
        var bookmarkData: Data? {
            get { source.media.bookmark }
            set { source.media.bookmark = newValue }
        }
        
        var sourceGroups: [SourceGroup] {
            collection.sourceGroups.sorted(by: { $0.sortOrder < $1.sortOrder })
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
        
        var sortOrderString: String {
            get { storedSortOrderString }
            set {
                storedSortOrderString = newValue
                let result = validateSortOrder(storedSortOrderString)
                applySortOrderValidationResult(result)
            }
        }
        
        var measure1StartString: String {
            get { storedMeasure1StartString }
            set {
                storedMeasure1StartString = newValue
                let result = validateMeasure1Start(storedMeasure1StartString)
                applyMeasure1StartValidationResult(result)
            }
        }
        
        var sourceGroupString: String {
            get {
                if let sourceGroup {
                    if sourceGroup.primitiveName == storedSourceGroupString {
                        return ""
                    }
                }
                
                return storedSourceGroupString
            }
            
            set {
                storedSourceGroupString = newValue
                
                if storedSourceGroupString.isEmpty {
                    storedSourceGroup = nil
                } else {
                    if let sourceGroup = findExistingSourceGroup(name: storedSourceGroupString, collection: collection, context: context) {
                        self.sourceGroup = sourceGroup
                    } else {
                        self.sourceGroup = nil
                    }
                }
            }
        }
        
        var sourceGroup: SourceGroup? {
            get { storedSourceGroup }
            set {
                storedSourceGroup = newValue
                
                if let sourceGroup = newValue {
                    storedSourceGroupString = sourceGroup.primitiveName
                } else {
                    storedSourceGroupString = ""
                }
            }
        }
        
        // MARK: validation
        
        fileprivate func validateName(_ nameValue: String) -> ValidationResult<String> {
            nameError = nil
            
            if nameValue.trimmingCharacters(in: .whitespaces).isEmpty {
                return .failure("Name is required.")
            }
            
            return validateNameUniqueness(nameValue, source: source, existingSources: collection.sources)
        }
        
        fileprivate func validateNameUniqueness(_ nameValue: String, source: Source, existingSources: [Source]) -> ValidationResult<String> {
            
            var sourcesToCheck: [Source]
            
            if source.isNew {
                sourcesToCheck = existingSources
            } else {
                sourcesToCheck = existingSources.filter { $0.persistentModelID != source.persistentModelID}
            }
            
            let sameNameSources = sourcesToCheck.filter{ $0.primitiveName == nameValue }
            
            if sameNameSources.isEmpty {
                return .success(nameValue)
            } else {
                return .failure("A source with this name already exists.")
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
        
        fileprivate func validateSortOrder(_ text: String) -> ValidationResult<Int> {
            if text.isEmpty {
                return .failure("Sort Order is a required field.")
            } else {
                if let sortOrderValue = Int(text) {
                    return .success(sortOrderValue)
                }
            }
            
            return .failure("Sort Order must be a number >= 0.")
        }
        
        fileprivate func validateMeasure1Start(_ text: String) -> ValidationResult<Double?> {
            if text.isEmpty {
                return .success(nil)
            } else {
                do {
                    return .success(try TimeFormatter.shared.seconds(from: text))
                } catch {
                    return .failure("Measure 1 Start must be empty or a valid time string.")
                }
            }
        }
        
        // MARK: apply validation
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
        
        private func applySortOrderValidationResult(_ result: ValidationResult<Int>) {
            switch result {
            case .success(let value):
                sortOrderError = nil
                sortOrder = value
            case.failure(let message):
                sortOrderError = message
            }
        }
        
        private func applyMeasure1StartValidationResult(_ result: ValidationResult<Double?>) {
            switch result {
            case .success(let value):
                measure1StartError = nil
                measure1Start = value
            case .failure(let message):
                measure1StartError = message
            }
        }
        
        var isValid: Bool {
            nameError == nil && bpmError == nil && sortOrderError == nil && measure1StartError == nil
        }
        
        func validate() -> Bool {
            applyNameValidationResult(validateName(storedNameString))
            applyBpmValidationResult(validateBpm(storedBpmString))
            applySortOrderValidationResult(validateSortOrder(storedSortOrderString))
            applyMeasure1StartValidationResult(validateMeasure1Start(storedMeasure1StartString))
            return isValid
        }
        
        func save() throws -> Bool {
            guard validate() else {
                throw AppError.attemptToSaveInvalidState("SourceEditViewModel")
            }

            source.primitiveName = storedNameString
            source.name_normalized = storedNameString.normalizedForSearch
            source.sortOrder = sortOrder
            source.measure1Start = measure1Start
            source.isFavorite = isFavorite
            source.notes = notes.isEmpty ? nil : notes
            source.media.bpm = bpm

            // Resolve the group once.
            source.sourceGroup = storedSourceGroupString.isEmpty
                ? nil
            : (sourceGroup ?? findOrCreateSourceGroup(name: storedSourceGroupString))

            do {
                if source.isNew {
                    context.insert(source)            // media and playback come with it (cascade relationships)
                    source.mediaCollection = collection
                }
                
                // Playback is now in the context, so submodels attach to a real parent.
                try playbackVM.apply(to: source.playback, context: context)
                try context.save()
                return true
            } catch {
                context.rollback()                    // don't leave a half-saved source behind
                throw error
            }
        }
        
        private func findExistingSourceGroup(name: String, collection: MediaCollection, context: ModelContext) -> SourceGroup? {
            if let sourceGroup = collection.sourceGroups.filter( { $0.primitiveName == name } ).first {
                return sourceGroup
            }
            
            return nil
        }
        
        private func findOrCreateSourceGroup(name: String) -> SourceGroup {
            if let existing = findExistingSourceGroup(name: name, collection: collection, context: context) {
                return existing
            }
            let next = (collection.sourceGroups.map(\.sortOrder).max() ?? 0) + 1
            let group = SourceGroup(name: name, sortOrder: next, mediaCollection: collection)
            context.insert(group)
            return group
        }
    }
}
