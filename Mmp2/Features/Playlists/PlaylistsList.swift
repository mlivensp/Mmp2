//
//  PlaylistsView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/29/26.
//

import SwiftData
import SwiftUI

struct PlaylistsList: View {
    @Environment(AppRootManager.self) var appRootManager
    @Environment(\.modelContext) private var modelContext
    @Query private var playlistGroups: [PlaylistGroup]
    @Query private var playlistGroupMembers: [PlaylistGroupMember]
    @Query(sort: \Playlist.name_normalized) private var playlists: [Playlist]

    let onPlaylistTapped: (Playlist) -> Void

    private var topLevelItems: [TopLevelPlaylistItem] {
        var items: [TopLevelPlaylistItem] = []
        
        // 1. Groups
        let groups = playlistGroups.map {
            TopLevelPlaylistGroup(
                playlistGroup: $0,
                playlists: topLevelPlaylists($0.groupMembers)
            )
        }
        
        items += groups.map { .group($0) }
        
        // 2. Ungrouped sources
        let ungrouped = playlists
            .filter { $0.groups.count == 0 }
            .map { TopLevelPlaylist(playlist: $0) }
        
        items += ungrouped.map { .playlist($0) }
        
        return items.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func topLevelPlaylists(_ groupMembers: [PlaylistGroupMember]) -> [TopLevelPlaylist] {
        groupMembers.map { TopLevelPlaylist(playlist: $0.playlist) }
            .sorted(by: { $0.sortOrder  < $1.sortOrder })
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(topLevelItems) { item in
                    switch item {
                    case .group(let wrapper):
                        PlaylistGroupSection(
                            wrapper: wrapper,
                            onPlaylistTapped: onPlaylistTapped,
                            appRootManager: appRootManager)
                    case .playlist(let wrapper):
                        PlaylistSection(
                            wrapper: wrapper,
                            onPlaylistTapped: onPlaylistTapped,
                            appRootManager: appRootManager)
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }
}

//#Preview {
//    PlaylistsView()
//}
