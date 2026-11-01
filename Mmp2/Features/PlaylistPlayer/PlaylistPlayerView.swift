//
//  PlaylistPlayer.swift
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

    // MARK: - Building playable items

//    private func queuePlaylistItems() -> [PlayableItem] {
//        (appRootManager.selectedPlaylist?.playlistItems ?? [])
//            .sorted(by: { $0.sequence < $1.sequence })
//            .compactMap { queuePlaylistItem($0) }
//    }
//
//    private func queuePlaylistItem(_ playlistItem: PlaylistItem) -> PlayableItem? {
//        if let source = playlistItem.source {
//            return queueSourcePlaylistItem(source: source, playback: playlistItem.playback)
//        } else if let clip = playlistItem.clip {
//            return queueClipPlaylistItem(clip: clip, playback: playlistItem.playback)
//        } else {
//            // TODO: log a message explaining nil return
//            return nil
//        }
//    }
//
//    private func queueSourcePlaylistItem(source: Source, playback: Playback?) -> PlayableItem? {
//        // TODO: log a message explaining nil return
//        guard let url = try? source.media.resolveURL() else { return nil }
//
//        var names: [String] = []
//        names.append(source.mediaCollection?.primitiveName ?? "?")
//        names.append(source.primitiveName)
//        let title = String(names.joined(separator: " • "))
//
//        return PlayableItem(
//            url: url,
//            title: title,
//            start: nil,
//            end: nil,
//            bpm: source.media.bpm,
//            playback: playback ?? source.playback)
//    }
//
//    private func queueClipPlaylistItem(clip: Clip, playback: Playback?) -> PlayableItem? {
//        // TODO: log a message explaining nil return
//        guard let source = clip.source else { return nil }
//        guard let url = try? source.media.resolveURL() else { return nil }
//
//        var names: [String] = []
//        names.append(source.mediaCollection?.primitiveName ?? "?")
//        names.append(source.primitiveName)
//        names.append(clip.primitiveName)
//        let title = String(names.joined(separator: " • "))
//
//        return PlayableItem(
//            url: url,
//            title: title,
//            start: clip.startSeconds,
//            end: clip.endSeconds,
//            bpm: clip.media.bpm,
//            playback: playback ?? clip.playback)
//    }

    func exit() {
        controller?.stop()
        appRootManager.currentRoot = .home
    }
}

//#Preview {
//    PlaylistPlayerView()
//}
