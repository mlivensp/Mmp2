//
//  PlaylistEditViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/7/26.
//

import Foundation
import OSLog
import SwiftData

extension PlaylistEditView {
    @Observable
    final class ViewModel {
        let playlist: Playlist
        let context: ModelContext
        
        private var defaultDelay: Int
        public var shuffle: Bool
        private var timesToRepeat: Int?
        
        private var storedNameString: String
        private var storedDefaultDelayString: String
        private var storedTimesToRepeatString: String
        private var notes: String
        
        public var nameError: String?
        public var defaultDelayError: String?
        public var timesToRepeatError: String?
        
        init(playlist: Playlist, context: ModelContext) {
            self.playlist = playlist
            self.context = context
            
            self.storedNameString = playlist.primitiveName
            self.shuffle = playlist.shuffle
            self.defaultDelay = playlist.defaultSecondsToDelay
            self.storedDefaultDelayString = String(playlist.defaultSecondsToDelay)
            self.timesToRepeat = playlist.timesToRepeat
            
            if let timesToRepeat = playlist.timesToRepeat {
                self.storedTimesToRepeatString = String(timesToRepeat)
            } else {
                self.storedTimesToRepeatString = ""
            }
            
            self.notes = playlist.notes ?? ""
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
        
        var defaultDelayString: String {
            get { return storedDefaultDelayString }
            set {
                storedDefaultDelayString = newValue
                let result = validateDefaultDelay(storedDefaultDelayString)
                applyDefaultDelayValidationResult(result)
            }
        }
        
        var timesToRepeatString : String {
            get { return storedTimesToRepeatString }
            set {
                storedTimesToRepeatString = newValue
                let result = validateTimesToRepeat(storedTimesToRepeatString)
                applyTimesToRepeatValidationResult(result)
            }
        }
        
        public var playlistItems: [PlaylistItemViewModel] {
            playlist.playlistItems
                .sorted { $0.sequence < $1.sequence }
                .map { PlaylistItemViewModel(playlistItem: $0) }
        }
        
        public var groupItems: [PlaylistGroupItem] {
            playlist.groups
                .sorted { $0.playlistGroup.name_normalized < $1.playlistGroup.name_normalized }
        }
        
        // MARK: Validation
        
        fileprivate func validateName(_ nameValue: String) -> ValidationResult<String> {
            if nameValue.trimmingCharacters(in: .whitespaces).isEmpty {
                return .failure("Name is required.")
            }
            
            return validateNameUniqueness(nameValue, playlist: playlist)
        }
        
        fileprivate func validateNameUniqueness(_ nameValue: String, playlist: Playlist) -> ValidationResult<String> {
            
            var playlistsToCheck: [Playlist]
            
            
            let repo = PlaylistRepository(context: context)
            let existingPlaylists: [Playlist]
            do {
                existingPlaylists = try repo.fetchAll()
            } catch {
                Logger.data.error("PlaylistRepository.fetchAll \(error.localizedDescription)")
                return .failure("An error occured validating the name.")
            }
            
            if playlist.isNew {
                playlistsToCheck = existingPlaylists
            } else {
                playlistsToCheck = existingPlaylists.filter { $0.persistentModelID != playlist.persistentModelID}
            }
            
            let sameNamePlaylists = playlistsToCheck.filter{ $0.primitiveName == nameValue }
            
            if sameNamePlaylists.isEmpty {
                return .success(nameValue)
            } else {
                return .failure("A playlist with this name already exists.")
            }
        }
        
        private func validateDefaultDelay(_ defaultDelayValue: String) -> ValidationResult<Int> {
            if let defaultDelay = Int(defaultDelayValue) {
                return .success(defaultDelay)
            } else {
                return .failure("The value must be a number 0 or greater.")
            }
        }
        
        private func validateTimesToRepeat(_ timesToRepeatValue: String) -> ValidationResult<Int?> {
            guard !timesToRepeatValue.isEmpty else {
                return .success(nil)
            }
            
            if let timesToRepeat = Int(timesToRepeatValue) {
                return .success(timesToRepeat)
            } else {
                return .failure("The value must be empty or a number greater than 0.")
            }
        }
        
        var isValid: Bool {
            nameError == nil && defaultDelayError == nil && timesToRepeatError == nil
        }
        
        func validate() -> Bool {
            let validateNameResult = validateName(storedNameString)
            applyNameValidationResult(validateNameResult)
            
            let defaultDelayResult = validateDefaultDelay(storedDefaultDelayString)
            applyDefaultDelayValidationResult(defaultDelayResult)
            
            return isValid
        }
        
        
        // MARK: Apply validation results
        
        private func applyNameValidationResult(_ result: ValidationResult<String>) {
            switch result {
            case .success:
                nameError = nil
            case .failure(let message):
                nameError = message
            }
        }
        
        private func applyDefaultDelayValidationResult(_ result: ValidationResult<Int>) {
            switch result {
                
            case .success(let value):
                defaultDelay = value
                defaultDelayError = nil
            case .failure(let message):
                defaultDelayError = message
            }
        }
        
        private func applyTimesToRepeatValidationResult(_ result: ValidationResult<Int?>) {
            switch result {
                
            case .success(let value):
                timesToRepeat = value
                timesToRepeatError = nil
            case .failure(let message):
                timesToRepeatError = message
            }
        }
        
        // MARK: Save
        
        func save() throws -> Bool {
            guard validate() else { return false }
            
            playlist.primitiveName = name
            playlist.name_normalized = name.normalizedForSearch
            playlist.shuffle = shuffle
            playlist.defaultSecondsToDelay = defaultDelay
            playlist.timesToRepeat = timesToRepeat
            playlist.notes = notes.isEmpty ? nil : notes
            
            try context.save()
            return true
        }
        
        // MARK: move playlist items
        
        func moveItemUp(_ item: PlaylistItemViewModel) {
            
            guard let index = playlistItems.firstIndex(where: {
                $0.id == item.id
            }) else {
                return
            }
            
            guard index > 0 else {
                return
            }
            
            let current = playlistItems[index].playlistItem
            let previous = playlistItems[index - 1].playlistItem
            
            let temp = current.sequence
            current.sequence = previous.sequence
            previous.sequence = temp
        }
        
        func moveItemDown(_ item: PlaylistItemViewModel) {
            
            guard let index = playlistItems.firstIndex(where: {
                $0.id == item.id
            }) else {
                return
            }
            
            guard index < playlistItems.count - 1 else {
                return
            }
            
            let current = playlistItems[index].playlistItem
            let next = playlistItems[index + 1].playlistItem
            
            let temp = current.sequence
            current.sequence = next.sequence
            next.sequence = temp
        }
        
        // MARK: Delete group
        func removeGroupMembership(_ groupItem: PlaylistGroupItem) {
            context.delete(groupItem)

            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
    }
}
