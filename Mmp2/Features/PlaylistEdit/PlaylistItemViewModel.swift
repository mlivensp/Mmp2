//
//  PlaylistItemViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/8/26.
//

import Foundation
import SwiftData

@Observable
final class PlaylistItemViewModel: Identifiable {
    let playlistItem: PlaylistItem
    
    private var secondsToDelay: Int?
    private let bpm: Int?
    private let context: ModelContext
    
    var sortOrder: Int
    var isNew: Bool
    var useCustomPlayback: Bool
    var customPlaybackVM: PlaybackEditViewModel
    var itemPlaybackVM: PlaybackEditViewModel

    var storedSecondsToDelayString: String
    
    var secondsToDelayError: String?

    init(playlistItem: PlaylistItem, context: ModelContext, isNew: Bool = false) throws {
        self.playlistItem = playlistItem
        self.context = context
        self.sortOrder = playlistItem.playOrder
        self.isNew = isNew
        
        if let secondsToDelay = playlistItem.secondsToDelayOverride {
            self.storedSecondsToDelayString = String(secondsToDelay)
        } else {
            self.storedSecondsToDelayString = ""
        }
        
        let itemPlayback: Playback
        
        if let source = playlistItem.source {
            itemPlayback = source.playback
            bpm = source.bpm
        } else if let clip = playlistItem.clip {
            itemPlayback = clip.playback
            bpm = clip.bpm
        } else {
            throw AppError.invalidState
        }
        
        itemPlaybackVM = PlaybackEditViewModel(playback: itemPlayback, bpm: bpm, context: context)
        
        if let customPlayback = playlistItem.playback {
            useCustomPlayback = true
            customPlaybackVM = PlaybackEditViewModel(playback: customPlayback, bpm: bpm, context: context)
        } else {
            useCustomPlayback = false
            customPlaybackVM = PlaybackEditViewModel(playback: Playback.makeDraft(), bpm: bpm, context: context)
        }
    }
    
    var id: PersistentIdentifier {
        playlistItem.persistentModelID
    }
    
    var playbackVM: PlaybackEditViewModel {
        useCustomPlayback ? customPlaybackVM : itemPlaybackVM
    }
    
    var name: String {
        var nameParts: [String] = []
        
        if let source = playlistItem.source {
            nameParts.append(source.mediaCollection.primitiveName)
            nameParts.append(source.primitiveName)
        } else if let clip = playlistItem.clip {
            nameParts.append(clip.source.mediaCollection.primitiveName)
            nameParts.append(clip.source.primitiveName)
            nameParts.append(clip.primitiveName)
        }
        
        guard !nameParts.isEmpty else { return "Empty Playlist Item"}
        return nameParts.joined(separator: " • ")
    }
    
    var secondsToDelayString: String {
        get { storedSecondsToDelayString }
        set {
            storedSecondsToDelayString = newValue
            let result = validateSecondsToDelay(storedSecondsToDelayString)
            applySecondsToDelayValidationResult(result)
        }
    }
    
    private func validateSecondsToDelay(_ secondsToDelayValue: String) -> ValidationResult<Int?> {
        if secondsToDelayValue.isEmpty {
            return .success(nil)
        } else {
            if let defaultDelay = Int(secondsToDelayValue) {
                return .success(defaultDelay)
            } else {
                return .failure("The value must be a number 0 or greater.")
            }
        }
    }
    
    private func applySecondsToDelayValidationResult(_ result: ValidationResult<Int?>) {
        switch result {
        case .success(let value):
            secondsToDelayError = nil
            secondsToDelay = value
        case.failure(let message):
            secondsToDelayError = message
        }
    }
    
    func apply() {
        
    }
}
