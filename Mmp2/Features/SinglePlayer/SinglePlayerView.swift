//
//  SinglePlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct SinglePlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    @State private var media: Media?
    @State private var playback: Playback?
    @State private var clipStart: Double?
    @State private var clipEnd: Double?
    @State private var videoPlayer: AVPlayer?
    @State private var resolvedURL: URL?
    @State private var controller: SinglePlayerController?
    @State private var sequencer: PlayRateSequencer = DefaultSequencer()
    
    private func preparePlayback() throws {
        guard let url = resolvedURL else { return }
        guard let media else { return }
        guard let playback else { return }
        
        do {
            sequencer = try SequencerFactory.createSequencer(from: playback, bpm: media.bpm)
        } catch {
            throw error
        }
        
        let player = AVPlayer(url: url)
        videoPlayer = player
        
        controller = SinglePlayerController(
            clipStart: clipStart,
            clipEnd: clipEnd,
            sequencer: sequencer
        )
        
        controller?.attachVideoPlayer(player)
    }
    
    var body: some View {
        Group {
            if let player = videoPlayer {
                VStack {
                    Slider(value: $sequencer.currentRate, in: 0...2)
                    VideoPlayerView(player: player)
                }
            } else {
                Text("Unable to load media")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            try? selectMedia()
            try? resolveURL()
            try? preparePlayback()
            controller?.start()
        }
        .onDisappear {
            controller?.stop()
            
            if let url = resolvedURL {
                url.stopAccessingSecurityScopedResource()
                print("🔚 Stopped security-scoped access for \(url.path)")
            }
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
    
    private func selectMedia() throws {
        if let source = appRootManager.selectedSource {
            media = source.media
            playback = source.playback
        } else if let clip = appRootManager.selectedClip {
            media = clip.source?.media
            playback = clip.playback
            clipStart = clip.startTime.durationAsSeconds
            clipEnd = clip.endTime.durationAsSeconds
        } else {
            throw AppError.noMedia
        }
    }
    
    private func resolveURL() throws {
        guard let media else { throw AppError.noMedia }
        guard let bookmark = media.bookmark else { return }
        
        var isStale = false
        
        do {
            let url = try URL(
                resolvingBookmarkData: bookmark,
                options: [.withoutUI, .withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                print("⚠️ Stale bookmark for media")
                // TODO: trigger re-bookmark flow
                return
            }
            
            let ok = url.startAccessingSecurityScopedResource()
            print("startAccessingSecurityScopedResource = \(ok) for \(url.path)")
            
            guard ok else {
                print("❌ Failed to start security-scoped access for \(url.path)")
                return
            }
            
            resolvedURL = url
            print("✅ resolvedURL - \(url.absoluteString)")
        } catch {
            print("❌ resolveURL error: \(error)")
        }
    }
}

//#Preview {
//    SinglePlayerView()
//}
