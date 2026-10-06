//
//  CollectionEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import Foundation
import OSLog
import SwiftData

extension CollectionEditView {
    @Observable
    final class ViewModel {
        let collection: MediaCollection
        let context: ModelContext
        
        internal var storedNameString: String
        internal var notes: String
        
        internal var nameError: String?
        
        init(collection: MediaCollection, context: ModelContext) {
            self.collection = collection
            self.context = context
            
            self.storedNameString = collection.primitiveName
            self.notes = collection.notes ?? ""
        }
        
        var nameString: String {
            get { storedNameString }
            set {
                storedNameString = newValue
                applyNameValidationResult(validateName(storedNameString))
            }
        }
        
        // MARK: validation
        
        fileprivate func validateName(_ nameValue: String) -> ValidationResult<String> {
            if nameValue.trimmingCharacters(in: .whitespaces).isEmpty {
                return .failure("Name is required.")
            }
            
            let repo = MediaCollectionRepository(context: context)
            do {
                let existingCollections = try repo.fetchAll()
                return validateNameUniqueness(nameValue, collection: collection, existingCollections: existingCollections)
            } catch {
                Logger.data.error("MediaColledtionRepository.fetchAll \(error.localizedDescription)")
                return .failure("An error occured validating the name.")
            }
        }
        
        fileprivate func validateNameUniqueness(_ nameValue: String, collection: MediaCollection, existingCollections: [MediaCollection]) -> ValidationResult<String> {
            
            var collectionsToCheck: [MediaCollection]
            
            if collection.isNew {
                collectionsToCheck = existingCollections
            } else {
                collectionsToCheck = existingCollections.filter { $0.persistentModelID != collection.persistentModelID}
            }
            
            let sameNameCollectionss = collectionsToCheck.filter{ $0.primitiveName == nameValue }
            
            if sameNameCollectionss.isEmpty {
                return .success(nameValue)
            } else {
                return .failure("A collection with this name already exists.")
            }
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

        var isValid: Bool {
            nameError == nil
        }
        
        func validate() -> Bool {
            applyNameValidationResult(validateName(storedNameString))
            return isValid
        }
    }
}
