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
        PlaylistsList(onPlaylistTapped: { appRootManager.play(playlist: $0) })
    }
}

#Preview {
    PlaylistsView()
}
