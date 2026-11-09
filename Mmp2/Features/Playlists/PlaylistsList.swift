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
    @Query(sort: \Playlist.name_normalized) private var playlists: [Playlist]
    @Query private var groupItems: [PlaylistGroupItem]
    
    let onPlaylistTapped: (Playlist) -> Void

    private var topLevelItems: [TopLevelPlaylistItem] {
        var items: [TopLevelPlaylistItem] = []
        
        // 1. Groups
        let groups = playlistGroups.map { group in
            let memberships = groupItems.filter {
                $0.playlistGroup.id == group.id
            }
            
            return TopLevelPlaylistGroup(
                playlistGroup: group,
                playlists: topLevelPlaylists(memberships)
                    .sorted(by: { $0.playlist.primitiveName < $1.playlist.primitiveName })
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
    
    private func topLevelPlaylists(_ groupItemss: [PlaylistGroupItem]) -> [TopLevelPlaylist] {
        groupItemss.map { TopLevelPlaylist(playlist: $0.playlist) }
            .sorted(by: { $0.sortOrder  < $1.sortOrder })
    }
    
    var body: some View {
        VStack {
            // the following line establishes a view dependeny on groupItems,
            // forcing the view to redraw when groupItems changes. This happens
            // when a playlist is added to or removed from a playlist group
            let _ = groupItems.count
            
            List {
                ForEach(topLevelItems) { item in
                    switch item {
                    case .group(let wrapper):
                        PlaylistGroupSection(
                            wrapper: wrapper,
                            onPlaylistTapped: onPlaylistTapped,
                            appRootManager: appRootManager)
                        .id("\(wrapper.id)-\(wrapper.playlists.count)")
                    case .playlist(let wrapper):
                        PlaylistSection(
                            wrapper: wrapper,
                            onPlaylistTapped: onPlaylistTapped,
                            appRootManager: appRootManager)
                        .id("\(wrapper.id)-\(wrapper.playlist.id)")
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
