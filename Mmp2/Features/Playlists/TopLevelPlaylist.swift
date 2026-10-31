//
//  TopLevelPlaylist.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import Foundation
import SwiftData

final class TopLevelPlaylist: Identifiable {
    let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    var id: PersistentIdentifier {
        playlist.persistentModelID
    }
    
    var sortOrder: String {
        playlist.name_normalized
    }
}

extension TopLevelPlaylist: Equatable {
    static func == (lhs: borrowing TopLevelPlaylist, rhs: borrowing TopLevelPlaylist) -> Bool {
        lhs.playlist == rhs.playlist
    }
}

extension TopLevelPlaylist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(playlist)
    }
}
