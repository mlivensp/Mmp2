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
    @State private var audioPlayer: AVAudioPlayer?
    @State private var videoPlayer: AVPlayer?
    @State private var resolvedURL: URL?
    
    var body: some View {
        Group {
            if let url = resolvedURL {
                if url.pathExtension.lowercased() == "mp4" {
                    VideoPlayerView(player: AVPlayer(url: url))
                } else {
                    AudioPlayerControls(player: audioPlayer)
                }
            } else {
                Text("Unable to load media")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            try? selectMedia()
            try? resolveURL()
            preparePlayback()
        }
        .onDisappear {
            audioPlayer?.stop()
            videoPlayer?.pause()
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
            media = clip.media
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

    private func preparePlayback() {
        guard let url = resolvedURL else { return }

        if url.pathExtension.lowercased() == "mp4" {
            videoPlayer = AVPlayer(url: url)
        } else {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        }
    }
}

//#Preview {
//    SinglePlayerView()
//}
