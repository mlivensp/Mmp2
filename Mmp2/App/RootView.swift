//
//  RootView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/1/26.
//

import OSLog
import SwiftData
import SwiftUI

struct RootView: View {
    let appRootManager: AppRootManager
    let modelContext: ModelContext
    
    var body: some View {
        Group {
            switch appRootManager.currentRoot {
            case .splash:
                SplashView()
            case .play:
                SinglePlayerView(modelContext: modelContext)
            case .clipEdit:
                if let clip = appRootManager.editingClip,
                   let source = appRootManager.selectedSource {
                    ClipEditView(clip: clip, source: source)
                } else {
                    SplashView()
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
                switch appRootManager.selectedCategory {
                case .collections:
                    CollectionsRootView()
                case .playlists:
                    PlaylistsRootView()
                case .favorites:
                    FavoritesRootView()
                case .recents:
                    RecentsRootView()
                }
            }
        }
    }
}

struct CollectionsRootView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            CollectionsView()
        } detail: {
            HomeDetailStack {
                SourcesView()
            }
        }
    }
}

struct PlaylistsRootView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            HomeDetailStack {
                PlaylistsView()
            }
        }
    }
}

struct FavoritesRootView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            FavoritesView()
        }
    }
}

struct RecentsRootView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            RecentsView()
        }
    }
}

private struct HomeDetailStack<Content: View>: View {
    @Environment(AppRootManager.self) private var appRootManager
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        @Bindable var appRootManager = appRootManager
        
        NavigationStack(path: $appRootManager.detailPath) {
            content()
                .navigationDestination(for: DetailRoute.self) { route in
                    let _ = logDestination(route)
                    
                    switch route {
                    case .collectionEdit(let collection):
                        CollectionEditView(collection: collection)
                    case .sourceEdit(let source, let collection):
                        SourceEditView(source: source, collection: collection)
                    case .clipEdit(let clip, let source):
                        ClipEditView(clip: clip, source: source)
                    case .playlistEdit(let playlist):
                        PlaylistEditView(playlist: playlist)
                    }
                }
        }
    }
    private func logDestination(_ route: DetailRoute) {
        switch route {
        case .collectionEdit:
            Logger.navigation.info("destination - collectionEdit")
        case .sourceEdit:
            Logger.navigation.info("destination - sourceEdit")
        case .clipEdit:
            Logger.navigation.info("destination - clipEdit")
        case .playlistEdit:
            Logger.navigation.info("destination - playlistEdit")
        }
    }
}
