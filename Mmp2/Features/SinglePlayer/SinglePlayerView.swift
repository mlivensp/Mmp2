//
//  SinglePlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/15/26.
//

import SwiftUI
import OSLog

struct SinglePlayerView: View {
    @Environment(AppRootManager.self) private var appRootManager
    
    @State private var resolvedURL: URL?
    @State private var controller: MediaPlayerController = MediaPlayerController()
    @State private var source: Source?
    @State private var isAddingClip: Bool = false
    @State private var appeared = false
    
    var body: some View {
        HSplitView {
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
                if controller.playableItem != nil {
                    VStack {
                        Text(controller.playableItem?.title ?? "?")
                            .font(.title)
                        Text(controller.displayRate)
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
                        
                        VideoPlayerView(player: controller.player)
                    }
                }
            }
        }
        .onAppear {
            guard !appeared else { return }
            appeared = true
            try? selectMedia()
            try? resolveURL()
            play(makeItem(clip: appRootManager.selectedClip))
        }
        .onDisappear {
            controller.stop()
            appeared = false
            
            if let url = resolvedURL {
                url.stopAccessingSecurityScopedResource()
                print("🔚 Stopped security-scoped access for \(url.path)")
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
    
    func exit() {
        appRootManager.currentRoot = .home
    }
    
    var playRateBinding: Binding<Float> {
        Binding(
            get: { controller.playRate },
            set: { newValue in
                controller.playRate = newValue
            }
        )
    }
    
    @State private var addClipStart: String?
    @State private var addClipEnd: String?
    
    private var addClipArea: some View {
        VStack {
            HStack {
                Button(action: {
                    addClipStart = controller.position
                }, label: {
                    Text("Start")
                })
                
                Text(addClipStart ?? "0:00")
            }
            
            HStack {
                Button(action: {
                    addClipEnd = controller.position
                }, label: {
                    Text("End")
                })
                
                Text(addClipEnd ?? "0:00")
            }
            
            Button(action: {
                guard let source else { return }
                let clip = Clip.makeDraft()

                appRootManager.selectedSource = source
                appRootManager.editingClip = clip
                appRootManager.currentRoot = .clipEdit
            }, label: {
                Text("Add Clip")
            })
        }
    }
    
    private func makeItem(clip: Clip?) -> PlayableItem? {
        guard let source, let url = resolvedURL else { return nil }
        if let clip { return PlayableItem(clip: clip, url: url) }
        return PlayableItem(source: source, url: url)
    }

    private func play(_ item: PlayableItem?) {
        guard let item else { return }
        do {
            try controller.load(item)
            controller.start { exit() }
        } catch {
            Logger.ui.error("Failed to load playableItem: \(error.localizedDescription)")
        }
    }

    private func switchToSource() {
        appRootManager.selectedClip = nil
        play(makeItem(clip: nil))
    }

    private func switchToClip(_ clip: Clip) {
        appRootManager.selectedClip = clip
        play(makeItem(clip: clip))
    }

    private func selectMedia() throws {
        if let clip = appRootManager.selectedClip {
            self.source = clip.source
        } else if let source = appRootManager.selectedSource {
            self.source = source
        } else {
            throw AppError.noMedia
        }
    }
    
    private func resolveURL() throws {
        guard let media = source?.media else { throw AppError.noMedia }
        guard let url = try media.resolveURL() else { return }
        resolvedURL = url
    }
}

//#Preview {
//    SinglePlayerView()
//}
