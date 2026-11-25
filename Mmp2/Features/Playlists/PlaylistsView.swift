//
//  PlaylistsView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import SwiftUI

struct PlaylistsView: View {
    @Environment(AppRootManager.self) private var appRootManager

    var body: some View {
        VStack {
            HStack {
                Text("Playlists")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, formPadding)
                Spacer()
                Button {
                    let playlist = Playlist.makeDraft();
                    appRootManager.editPlaylist(playlist)
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing, 4)
            }
            
            PlaylistsList(onPlaylistTapped: { appRootManager.play(playlist: $0) })
        }
    }
}

#Preview {
    PlaylistsView()
}
