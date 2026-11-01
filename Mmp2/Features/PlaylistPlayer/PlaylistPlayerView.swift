//
//  PlaylistPlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import SwiftUI

struct PlaylistPlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager

    @State private var controller: PlaylistController?

    var body: some View {
        VStack {
            if let controller, let current = controller.current {
                VStack {
                    Text(current.title)
                        .font(.title)
                    Text(controller.player.displayRate)

                    VideoPlayerView(player: controller.player.player)
                }
            } else {
                Text("Unable to load media")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            guard controller == nil, let playlist = appRootManager.selectedPlaylist else { return }
            let items = playlist.playlistItems
                .sorted { $0.sequence < $1.sequence }
                .compactMap { $0.makePlayableItem() }
            let controller = PlaylistController(items: items, repeatCount: playlist.timesToRepeat)
            self.controller = controller
            controller.start { exit() }
        }
        .onDisappear {
            controller?.stop()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    exit()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }

    func exit() {
        controller?.stop()
        appRootManager.currentRoot = .home
    }
}

//#Preview {
//    PlaylistPlayerView()
//}
