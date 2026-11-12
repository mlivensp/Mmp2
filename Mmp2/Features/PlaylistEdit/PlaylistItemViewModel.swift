//
//  PlaylistItemViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/8/26.
//

import Foundation
import SwiftData

struct PlaylistItemViewModel: Identifiable {
    let playlistItem: PlaylistItem

    var id: PersistentIdentifier {
        playlistItem.persistentModelID
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
    
    var sequence: Int {
        playlistItem.sequence
    }
}
