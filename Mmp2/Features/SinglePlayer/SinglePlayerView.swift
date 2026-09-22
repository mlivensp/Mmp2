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
//    @State private var audioPlayer: AVAudioPlayer?
    @State private var videoPlayer: AVPlayer?
    @State private var resolvedURL: URL?
    @State private var controller: SinglePlayerController?

    private func preparePlayback() throws {
        guard let url = resolvedURL else { return }
//        guard let media else { return }
        guard let playback else { return }

        var sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(from: playback)
        } catch {
            throw error
        }

//        if url.pathExtension.lowercased() == "mp4" {
            let player = AVPlayer(url: url)
            videoPlayer = player
            
            controller = SinglePlayerController(
                clipStart: clipStart,
                clipEnd: clipEnd,
                sequencer: sequencer
            )
            
            controller?.attachVideoPlayer(player)
            
//        }
//        else {
//            let player = try? AVAudioPlayer(contentsOf: url)
//            audioPlayer = player
//            audioPlayer?.prepareToPlay()
//            
//            controller = SinglePlayerController(
//                clipStart: clipStart,
//                clipEnd: clipEnd,
//                sequencer: sequencer
//            )
//            
//            if let player { controller?.attachAudioPlayer(player) }
//        }
    }

    var body: some View {
        Group {
            if let url = resolvedURL {
//                if url.pathExtension.lowercased() == "mp4" {
                    VideoPlayerView(player: AVPlayer(url: url))
//                } else {
//                    AudioPlayerControls(player: audioPlayer)
//                }
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
//            audioPlayer?.stop()
//            videoPlayer?.pause()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
//                    viewModel.cleanUp()
                    appRootManager.currentRoot = .home
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
//                        Text(viewModel.backNavigationText)
                    }
                }
            }
        }
    }
    
    private func selectMedia() throws {
        if let source = appRootManager.selectedSource {
            media = source.media
        } else if let clip = appRootManager.selectedClip {
            media = clip.source?.media
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
            
            if url.startAccessingSecurityScopedResource() {
                resolvedURL = url
                print("resolvedURL - \(resolvedURL?.absoluteString ?? "")")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

//    private func preparePlayback() {
//        guard let url = resolvedURL else { return }
//
//        if url.pathExtension.lowercased() == "mp4" {
//            videoPlayer = AVPlayer(url: url)
//        } else {
//            audioPlayer = try? AVAudioPlayer(contentsOf: url)
//            audioPlayer?.prepareToPlay()
//        }
//    }
}

//#Preview {
//    SinglePlayerView()
//}
