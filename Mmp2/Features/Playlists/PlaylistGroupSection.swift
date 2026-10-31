//
//  PlaylistGroupSection.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import SwiftUI

struct PlaylistGroupSection: View {
    let wrapper: TopLevelPlaylistGroup
    let onPlaylistTapped: (Playlist) -> Void
    let appRootManager: AppRootManager
    
    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { wrapper.isExpanded },
            set: { wrapper.isExpanded = $0 }
        )) {
            ForEach(wrapper.playlists) { playlistWrapper in
                PlaylistSection(
                    wrapper: playlistWrapper,
                    onPlaylistTapped: onPlaylistTapped,
                    appRootManager: appRootManager
                )
            }
        } label: {
            Label(wrapper.playlistGroup.primitiveName,
                  systemImage: "music.note.square.stack")
        }
    }
}

//#Preview {
//    PlaylistGroupSection()
//}
