//
//  PlaylistSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import SwiftUI

struct PlaylistSection: View {
    let wrapper: TopLevelPlaylist
    let onPlaylistTapped: (Playlist) -> Void
    let appRootManager: AppRootManager
    
    var body: some View {
        let playlist = wrapper.playlist
        
        PlaylistRow(playlist: playlist) { p in
            appRootManager.editPlaylist(p)
        }
        .onTapGesture { onPlaylistTapped(playlist) }
    }
}
