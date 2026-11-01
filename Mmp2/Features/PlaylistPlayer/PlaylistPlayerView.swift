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
    @State private var controller: PlaylistPlayerController?
    
    @State var playlistItemsQueue: Queue<QueuedPlaylistItem> = Queue<QueuedPlaylistItem>()
    @State var queuedPlaylistItem: QueuedPlaylistItem?
    @State var index = 0
    
    private func preparePlayback() throws {
        guard let queuedPlaylistItem else { return }
        
        let sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(
                from: queuedPlaylistItem.playback,
                bpm: queuedPlaylistItem.bpm,
                forPlaylist: true
            )
        } catch {
            throw error
        }
        
        controller = PlaylistPlayerController(
            item: queuedPlaylistItem,
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
                if let player = videoPlayer, let queuedPlaylistItem {
                    VStack {
                        Text(queuedPlaylistItem.title)
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
            _ = queueableItems.map { playlistItemsQueue.enqueue($0) }
            queuedPlaylistItem = playlistItemsQueue.dequeue()
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
    
    private func queuePlaylistItems() -> [QueuedPlaylistItem] {
        let playlistItems = (appRootManager.selectedPlaylist?.playlistItems ?? [])
            .sorted(by: { $0.sequence < $1.sequence })
        let queuedItems = playlistItems.compactMap {
            queuePlaylistItem($0)
        }
        return queuedItems
    }
    
    private func queuePlaylistItem(_ playlistItem: PlaylistItem) -> QueuedPlaylistItem? {
        if let source = playlistItem.source {
            return queueSourcePlaylistItem(source: source, playback: playlistItem.playback)
        } else if let clip = playlistItem.clip {
            return queueClipPlaylistItem(clip: clip, playback: playlistItem.playback)
        } else {
            // TODO: log a message explaining nil return
            return nil
        }
    }
    
    private func queueSourcePlaylistItem(source: Source, playback: Playback?) -> QueuedPlaylistItem? {
        // TODO: log a message explaining nil return
        guard let url = try? source.media.resolveURL() else { return nil }
        
        var names: [String] = []
        names.append(source.mediaCollection?.primitiveName ?? "?")
        names.append(source.primitiveName)
        let title = String(names.joined(separator: " • "))
        
        let queuedPlaylistItem = QueuedPlaylistItem(
            url: url,
            title: title,
            start: nil,
            end: nil,
            bpm: source.media.bpm,
            playback: playback ?? source.playback)
        return queuedPlaylistItem
    }
    
    private func queueClipPlaylistItem(clip: Clip, playback: Playback?) -> QueuedPlaylistItem? {
        // TODO: log a message explaining nil return
        guard let source = clip.source else { return nil }
        guard let url = try? source.media.resolveURL() else { return nil }
        
        var names: [String] = []
        names.append(source.mediaCollection?.primitiveName ?? "?")
        names.append(source.primitiveName)
        names.append(clip.primitiveName)
        
        let title = String(names.joined(separator: " • "))
        let queuedPlaylistItem = QueuedPlaylistItem(
            url: url,
            title: title,
            start: clip.startSeconds,
            end: clip.endSeconds,
            bpm: clip.media.bpm,
            playback: playback ?? clip.playback)
        return queuedPlaylistItem
    }

    func nextItem() {
        queuedPlaylistItem = playlistItemsQueue.dequeue()
        
        if queuedPlaylistItem == nil {
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
