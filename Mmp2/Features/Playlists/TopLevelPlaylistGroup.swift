//
//  TopLevelPlaylistGroup.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import Foundation
import OSLog
import SwiftData

final class TopLevelPlaylistGroup: Identifiable {
    let playlistGroup: PlaylistGroup
    let playlists: [TopLevelPlaylist]
    
    init(playlistGroup: PlaylistGroup, playlists: [TopLevelPlaylist]) {
        self.playlistGroup = playlistGroup
        self.playlists = playlists
    }
    
    var id: PersistentIdentifier {
        playlistGroup.persistentModelID
    }
    
    var sortOrder: String {
        playlistGroup.name_normalized
    }
    
    var isExpanded: Bool {
        get { playlistGroup.isExpanded }
        set {
            playlistGroup.isExpanded = newValue
            Task {
                do {
                    try playlistGroup.modelContext?.save()
                } catch {
                    Logger.data.error("TopLevelPlaylistGroup.isExpanded.set - \(error.localizedDescription)")
                }
            }
        }
    }
}

extension TopLevelPlaylistGroup: Equatable {
    static func == (lhs: borrowing TopLevelPlaylistGroup, rhs: borrowing TopLevelPlaylistGroup) -> Bool {
        lhs.playlistGroup == rhs.playlistGroup
    }
}

extension TopLevelPlaylistGroup: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(playlistGroup)
    }
}
