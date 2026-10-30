//
//  PlaylistsView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/29/26.
//

import SwiftData
import SwiftUI

struct PlaylistsView: View {
    @Environment(AppRootManager.self) var appRootManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Playlist.name_normalized) private var playlists: [Playlist]
    
    var body: some View {
        VStack {
            List {
                ForEach(playlists) { playlist in
                    Text(playlist.primitiveName)
                }
            }
        }
    }
}

#Preview {
    PlaylistsView()
}
