//
//  PlaylistPlayer.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/30/26.
//

import AVKit
import OSLog
import SwiftData
import SwiftUI

struct PlaylistPlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
    //    @Environment(\.modelContext) private var modelContext
    
    @State private var videoPlayer: AVPlayer?
    @State private var controller: MediaPlayerController?
    
    @State var playableItems: Queue<PlayableItem> = Queue<PlayableItem>()
    @State var playableItem: PlayableItem?
    @State var index = 0
    
    private func preparePlayback() throws {
        guard let playableItem else { return }
        
        let sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(
                from: playableItem.playback,
                bpm: playableItem.bpm,
                forPlaylist: true
            )
        } catch {
            throw error
        }
        
        controller = MediaPlayerController(
            playableItem: playableItem,
            sequencer: sequencer
        )
        
        let playerItem = controller?.createPlayerItem()
        
        if let videoPlayer {
            videoPlayer.replaceCurrentItem(with: playerItem)
        } else {
            let player = AVPlayer(playerItem: playerItem)
            videoPlayer = player
        }
        
        controller?.attachVideoPlayer(videoPlayer!)
    }

    var body: some View {
        VStack {
            Group {
                if let player = videoPlayer, let playableItem {
                    VStack {
                        Text(playableItem.title)
                            .font(.title)
                        Text(controller?.displayRate ?? "?")
//                        Slider(
//                            value: playRateBinding,
//                            in: 0...2,
//                            step: 0.01) {
//                                Text("Rate")
//                            } minimumValueLabel: {
//                                Text("0%")
//                            } maximumValueLabel: {
//                                Text("200%")
//                            }
                        
                        VideoPlayerView(player: player)
                    }
                } else {
                    Text("Unable to load media")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            let queueableItems = queuePlaylistItems()
            _ = queueableItems.map { playableItems.enqueue($0) }
            playableItem = playableItems.dequeue()
            try? preparePlayback()
            controller?.start {
                nextItem()
            }
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
    
    private func queuePlaylistItems() -> [PlayableItem] {
        let playlistItems = (appRootManager.selectedPlaylist?.playlistItems ?? [])
            .sorted(by: { $0.sequence < $1.sequence })
        let queuedItems = playlistItems.compactMap {
            queuePlaylistItem($0)
        }
        return queuedItems
    }
    
    private func queuePlaylistItem(_ playlistItem: PlaylistItem) -> PlayableItem? {
        if let source = playlistItem.source {
            return queueSourcePlaylistItem(source: source, playback: playlistItem.playback)
        } else if let clip = playlistItem.clip {
            return queueClipPlaylistItem(clip: clip, playback: playlistItem.playback)
        } else {
            // TODO: log a message explaining nil return
            return nil
        }
    }
    
    private func queueSourcePlaylistItem(source: Source, playback: Playback?) -> PlayableItem? {
        // TODO: log a message explaining nil return
        guard let url = try? source.media.resolveURL() else { return nil }
        
        var names: [String] = []
        names.append(source.mediaCollection?.primitiveName ?? "?")
        names.append(source.primitiveName)
        let title = String(names.joined(separator: " • "))
        
        let queuedPlaylistItem = PlayableItem(
            url: url,
            title: title,
            start: nil,
            end: nil,
            bpm: source.media.bpm,
            playback: playback ?? source.playback)
        return queuedPlaylistItem
    }
    
    private func queueClipPlaylistItem(clip: Clip, playback: Playback?) -> PlayableItem? {
        // TODO: log a message explaining nil return
        guard let source = clip.source else { return nil }
        guard let url = try? source.media.resolveURL() else { return nil }
        
        var names: [String] = []
        names.append(source.mediaCollection?.primitiveName ?? "?")
        names.append(source.primitiveName)
        names.append(clip.primitiveName)
        
        let title = String(names.joined(separator: " • "))
        let queuedPlaylistItem = PlayableItem(
            url: url,
            title: title,
            start: clip.startSeconds,
            end: clip.endSeconds,
            bpm: clip.media.bpm,
            playback: playback ?? clip.playback)
        return queuedPlaylistItem
    }

    func nextItem() {
        playableItem = playableItems.dequeue()
        
        if playableItem == nil {
            exit()
        } else {
            try? preparePlayback()
            controller?.start {
                nextItem()
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
