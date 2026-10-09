//
//  SinglePlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI
import AVFoundation
import AVKit
import OSLog

struct SinglePlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    @State private var media: Media?
    @State private var playback: Playback?
    @State private var clipStart: Double?
    @State private var clipEnd: Double?
    @State private var videoPlayer: AVPlayer?
    @State private var resolvedURL: URL?
    @State private var controller: SinglePlayerController?
    @State private var source: Source?
    @State private var isAddingClip: Bool = false
    
    private func preparePlayback() throws {
        guard let url = resolvedURL else { return }
        guard let media else { return }
        guard let playback else { return }
        
        let sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(from: playback, bpm: media.bpm)
        } catch {
            throw error
        }
        
        let player = AVPlayer(url: url)
        videoPlayer = player
        
        controller = SinglePlayerController(
            bpm: media.bpm,
            clipStartSeconds: clipStart,
            clipEndSeconds: clipEnd,
            sequencer: sequencer
        )
        
        controller?.attachVideoPlayer(player)
    }
    
    var body: some View {
        HStack {
            Group {
                VStack {
                    Button(action: switchToSource, label: {
                        Text("Play Source")
                    })
                    
                    HStack {
                        Text("Clips")
                        Button(action: {
                            isAddingClip.toggle()
                        }, label: {
                            Label("", systemImage: isAddingClip ? "minus" : "plus")
                        })
                        .backgroundStyle(.clear)
                    }
                    
                    if isAddingClip {
                        addClipArea
                    }
                    
                    let clips: [Clip] = (source?.clips ?? []).sorted {
                        if $0.startSeconds == $1.startSeconds {
                            return $0.endSeconds < $1.endSeconds
                        }
                        
                        return $0.startSeconds < $1.startSeconds
                    }
                    
                    ClipListView(clips: clips) { clip in
                        switchToClip(clip)
                    }
                    .frame(maxWidth: 150)
                }
            }
            
            Group {
                if let player = videoPlayer {
                    VStack {
//                        let formattedRate = controller?.playRate
//                            .formatted(.percent.precision(.fractionLength(0))) ?? "?"
                        Text(controller?.displayRate ?? "?")
                        Slider(
                            value: playRateBinding,
                            in: 0...2,
                            step: 0.01) {
                                Text("Rate")
                            } minimumValueLabel: {
                                Text("0%")
                            } maximumValueLabel: {
                                Text("200%")
                            }
                        //                    onEditingChanged: { _ in
                        //
                        //                        }
                        
                        VideoPlayerView(player: player)
                    }
                } else {
                    Text("Unable to load media")
                        .foregroundColor(.secondary)
                }
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
    
    var playRateBinding: Binding<Float> {
        Binding(
            get: { controller?.playRate ?? 1.0 },
            set: { newValue in
                controller?.playRate = newValue
            }
        )
    }
    
    @State private var addClipStart: String?
    @State private var addClipEnd: String?
    
    private var addClipArea: some View {
        VStack {
            HStack {
                Button(action: {
                    addClipStart = controller?.position
                }, label: {
                    Text("Start")
                })
                
                Text(addClipStart ?? "0:00")
            }
            
            HStack {
                Button(action: {
                    addClipEnd = controller?.position
                }, label: {
                    Text("End")
                })
                
                Text(addClipEnd ?? "0:00")
            }
        }
        
    }
    
    private func switchToSource() {
        controller?.stop()
        appRootManager.selectedClip = nil
        media = source?.media
        guard let media else { return }
        guard let player = videoPlayer else { return }
        guard let playback = source?.playback else { return }
        let sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(from: playback, bpm: media.bpm)
        } catch {
            return
        }
        
        controller = SinglePlayerController(
            bpm: media.bpm,
            clipStartSeconds: nil,
            clipEndSeconds: nil,
            sequencer: sequencer
        )
        
        controller?.attachVideoPlayer(player)
        controller?.start()
    }
    
    private func switchToClip(_ clip: Clip) {
        Logger.ui.info("SinglePlayerView - switchToClip")
        controller?.stop()
        appRootManager.selectedClip = clip
        media = clip.media
        guard let media else { return }
        guard let player = videoPlayer else { return }
        let sequencer: PlayRateSequencer
        
        do {
            sequencer = try SequencerFactory.createSequencer(from: clip.playback, bpm: media.bpm)
        } catch {
            return
        }
        
        controller = SinglePlayerController(
            bpm: media.bpm,
            clipStartSeconds: clip.startSeconds,
            clipEndSeconds: clip.endSeconds,
            sequencer: sequencer
        )
        
        controller?.attachVideoPlayer(player)
        controller?.start()
    }

    private func selectMedia() throws {
        if let source = appRootManager.selectedSource {
            Logger.ui.info("SinglePlayerView.selectMedia - source selected")
            self.source = source
            media = source.media
            playback = source.playback
        } else if let clip = appRootManager.selectedClip {
            Logger.ui.info("SinglePlayerView.selectMedia - clip selected")
            self.source = clip.source
            media = clip.source?.media
            playback = clip.playback
            clipStart = clip.startSeconds
            clipEnd = clip.endSeconds
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
