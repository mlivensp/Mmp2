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
            if let controller {

                switch controller.playbackState {

                case .countingDown(let upcoming, let secondsRemaining):

                    VStack(spacing: 24) {

                        Text("Coming Up")
                            .font(.title2)

                        Text(upcoming.title)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)

                        Text("\(secondsRemaining)")
                            .font(.system(size: 120, weight: .bold))

                        Text(
                            secondsRemaining == 1
                            ? "second"
                            : "seconds"
                        )
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .playing(let current):

                    VStack {
                        Text(current.title)
                            .font(.title)

                        Text(controller.player.displayRate)

                        VideoPlayerView(
                            player: controller.player.player
                        )
                    }

                case .finished:

                    ProgressView()

                case nil:

                    ProgressView()
                }
            }
        }
        .onAppear {
            guard controller == nil, let playlist = appRootManager.selectedPlaylist else { return }
            let items = playlist.playlistItems
                .sorted { $0.sequence < $1.sequence }
                .compactMap { playlistItem -> PlaylistPlaybackItem? in

                    guard let playable = playlistItem.makePlayableItem() else {
                        return nil
                    }

                    return PlaylistPlaybackItem(
                        playableItem: playable,
                        delaySeconds:
                            playlistItem.secondsToDelayOverride
                            ?? playlist.defaultSecondsToDelay
                    )
                }
            let controller = PlaylistController(
                items: items,
                repeatCount: playlist.timesToRepeat
            )
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
