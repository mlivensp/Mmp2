//
//  PlaylistRow.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import SwiftUI

struct PlaylistRow: View {
    let playlist: Playlist
    let onEdit: (Playlist) -> Void
    
    var body: some View {
        Text(playlist.primitiveName)
        .contextMenu {
            Button {
                onEdit(playlist)
            } label: {
                Label("Edit Playlist", systemImage: "pencil")
            }
        }
    }
}

//#Preview {
//    PlaylistRow()
//}
