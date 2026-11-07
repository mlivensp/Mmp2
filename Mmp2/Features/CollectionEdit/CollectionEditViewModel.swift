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
        
        var topLevelRows: [CollectionRow] {
            var rows: [CollectionRow] = []
            
            let groups = Set(
                sources.compactMap(\.sourceGroup)
            )
            
            rows.append(contentsOf: groups.map(CollectionRow.group))
            
            rows.append(contentsOf:
                sources
                .filter { $0.sourceGroup == nil }
                .map(CollectionRow.ungroupedSource)
            )

            return rows.sorted {
                $0.sortOrder < $1.sortOrder
            }
        }

        var sources: [Source] {
            collection.sources.sorted(by: {
                if $0.effectiveSortOrder == $1.effectiveSortOrder {
                    return $0.sortOrder < $1.sortOrder
                } else {
                    return $0.sortOrder < $1.sortOrder
                }
            } )
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
        
        func save() throws -> Bool {
            guard validate() else {
                throw AppError.attemptToSaveInvalidState("CollectionEditViewModel")
            }
            
            collection.primitiveName = storedNameString
            collection.name_normalized = storedNameString.normalizedForSearch
            collection.notes = notes.isEmpty ? nil : notes
            
            try context.save()
            return true
        }
        
        func moveUp(_ selectedRow: CollectionRow) {
            switch selectedRow {

            case .group(let group):
                moveGroupUp(group)

            case .groupedSource(let source):
                moveGroupedSourceUp(source)
                
            case .ungroupedSource(let source):
                moveUngroupedSourceUp(source)
            }
        }

        func moveDown(_ selectedRow: CollectionRow) {
            switch selectedRow {

            case .group(let group):
                moveGroupDown(group)

            case .groupedSource(let source):
                moveGroupedSourceDown(source)
                
            case .ungroupedSource(let source):
                moveUngroupedSourceDown(source)
            }
        }
        
        private var orderedTopLevelRows: [CollectionRow] {
            topLevelRows.sorted {
                $0.sortOrder < $1.sortOrder
            }
        }
        
        private func moveUngroupedSourceUp(_ source: Source) {

            let rows = orderedTopLevelRows

            guard let index = rows.firstIndex(where: {
                $0 == .ungroupedSource(source)
            }) else {
                return
            }

            guard index > 0 else {
                return
            }

            swapSortOrders(
                rows[index],
                rows[index - 1]
            )
        }

        private func moveUngroupedSourceDown(_ source: Source) {

            let rows = orderedTopLevelRows

            guard let index = rows.firstIndex(where: {
                $0 == .ungroupedSource(source)
            }) else {
                return
            }

            guard index < rows.count - 1 else {
                return
            }

            swapSortOrders(
                rows[index],
                rows[index + 1]
            )
        }
        
        private func moveGroupedSourceUp(_ source: Source) {

            guard let group = source.sourceGroup else {
                return
            }

            let sources = group.sources
                .sorted { $0.sortOrder < $1.sortOrder }

            guard let index = sources.firstIndex(of: source) else {
                return
            }

            guard index > 0 else {
                return
            }

            let previous = sources[index - 1]

            let temp = source.sortOrder
            source.sortOrder = previous.sortOrder
            previous.sortOrder = temp
        }
        
        private func moveGroupedSourceDown(_ source: Source) {

            guard let group = source.sourceGroup else {
                return
            }

            let sources = group.sources
                .sorted { $0.sortOrder < $1.sortOrder }

            guard let index = sources.firstIndex(of: source) else {
                return
            }

            guard index < sources.count - 1 else {
                return
            }

            let next = sources[index + 1]

            let temp = source.sortOrder
            source.sortOrder = next.sortOrder
            next.sortOrder = temp
        }

        private func moveGroupUp(_ group: SourceGroup) {

            let rows = orderedTopLevelRows

            guard let index = rows.firstIndex(where: {
                $0 == .group(group)
            }) else {
                return
            }

            guard index > 0 else {
                return
            }

            swapSortOrders(
                rows[index],
                rows[index - 1]
            )
        }
        
        private func moveGroupDown(_ group: SourceGroup) {

            let rows = orderedTopLevelRows

            guard let index = rows.firstIndex(where: {
                $0 == .group(group)
            }) else {
                return
            }

            guard index < rows.count - 1 else {
                return
            }

            swapSortOrders(
                rows[index],
                rows[index + 1]
            )
        }
        
        private func swapSortOrders(
            _ lhs: CollectionRow,
            _ rhs: CollectionRow
        ) {
            let lhsSortOrder = lhs.sortOrder
            let rhsSortOrder = rhs.sortOrder

            switch lhs {
            case .group(let group):
                group.sortOrder = rhsSortOrder

            case .groupedSource:
                return

            case .ungroupedSource(let source):
                source.sortOrder = rhsSortOrder
            }

            switch rhs {
            case .group(let group):
                group.sortOrder = lhsSortOrder

            case .groupedSource:
                return

            case .ungroupedSource(let source):
                source.sortOrder = lhsSortOrder
            }
        }
    }
}
