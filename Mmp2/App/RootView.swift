//
//  RootView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/1/26.
//

import OSLog
import SwiftUI

struct RootView: View {
    let appRootManager: AppRootManager
    
    var body: some View {
        Group{
            switch appRootManager.currentRoot {
            case .splash:
                SplashView()
            case .play:
                SinglePlayerView()
            case .clipEdit:
                if let clip = appRootManager.editingClip,
                   let source = appRootManager.selectedSource {
                    ClipEditView(clip: clip, source: source)
                } else {
                    SplashView() // fallback, shouldn't normally happen
                }
            case .playlistPlayer:
                if appRootManager.selectedPlaylist != nil {
                    PlaylistPlayerView()
                }
            case .playlistEditor:
                SplashView()
            case .documents:
                SplashView()
            case .home:
                NavigationSplitView {
                    SidebarView()
                } content: {
                    ContentView()
                } detail: {
                    @Bindable var appRootManager = appRootManager
                    NavigationStack(path: $appRootManager.detailPath) {
                        Group {
                            switch appRootManager.selectedCategory {
                            case .collections: SourcesView()
                            case .playlists:   Text("Playlists")
                            case .favorites:   Text("Favorites")
                            case .recents:     Text("Recents")
                            }
                        }
                        .navigationDestination(for: DetailRoute.self) { route in
                            let _ = logDestination(route)

                            switch route {
                            case .collectionEdit(let collection):
                                let _ = print("navigationDestination - CollectionEeitView")
                                CollectionEditView(collection: collection)
                            case .sourceEdit(let source, let collection):
                                let _ = print("navigationDestination - SourceEditView")
                                SourceEditView(source: source, collection: collection)
                            case .clipEdit(let clip, let source):
                                let _ = print("navigationDestination - ClipEditView")
                                ClipEditView(clip: clip, source: source)
                            case .playlistEdit(let playlist):
                                let _ = print("navigationDestination - PlaylistEditView")
                                PlaylistEditView(playlist: playlist)
                            }
                        }
                    }
                    .onChange(of: appRootManager.detailPath.count) { old, new in
                        print("detailPath.count \(old) -> \(new)")
                    }                    }
            }
        }
    }
    
    private func logDestination(_ route: DetailRoute) {
        switch route {
        case .collectionEdit(_):
            Logger.navigation.info("destination - collectionEdit")
        case .sourceEdit(_, _):
            Logger.navigation.info("destination - sourceEdit")
        case .clipEdit(_, _):
            Logger.navigation.info("destination - clipEdit")
        case .playlistEdit(_):
            Logger.navigation.info("destination - playlistEdit")
        }
    }
}

//#Preview {
//    RootView()
//}
