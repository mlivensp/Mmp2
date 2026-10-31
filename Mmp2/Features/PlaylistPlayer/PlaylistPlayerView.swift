//
//  PlaylistPlayer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import OSLog
import SwiftData
import SwiftUI

struct PlaylistPlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
//    @Environment(\.modelContext) private var modelContext
//
    @State var playlistItems: [PlaylistItem] = []
    @State var playlist: Playlist
    
    var body: some View {
        List(playlistItems) { playlistItem in
            let sourceName = playlistItem.source?.primitiveName
            let clipName = playlistItem.clip?.primitiveName
            Text("\(sourceName)\(clipName)")
        }
        .onAppear {
            playlistItems = fetchPlaylistItems()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    appRootManager.currentRoot = .home
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
    
    private func fetchPlaylistItems() -> [PlaylistItem] {
//        let playlistItems = appRootManager.selectedPlaylist?.playlistItems ?? []
        return playlist.playlistItems.sorted(by: {
            $0.sequence < $1.sequence
        })
    }
//        let fetchDescriptor = FetchDescriptor<PlaylistItem>(
//            sortBy: [SortDescriptor(\.sequence)]
//        )
//        do {
//            return try modelContext.fetch(fetchDescriptor)
//        } catch {
//            Logger.data.error("\(error.localizedDescription)")
//            return []
//        }
//    }
}

//#Preview {
//    PlaylistPlayerView()
//}
