//
//  Mmp2App.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import OSLog
import SwiftUI
import SwiftData

@main
struct Mmp2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = SchemaV1.schema
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var appRootManager = AppRootManager.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            Group{
                switch appRootManager.currentRoot {
                case .splash:
                    SplashView()
                case .play:
                    SinglePlayerView()
                case .playlistPlayer:
                    SplashView()
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
                        let _ = print("refreshing detail")
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
                                }
                            }
                        }
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(appRootManager)
    }
    
    private func logDestination(_ route: DetailRoute) {
        switch route {            
        case .collectionEdit(_):
            Logger.navigation.info("destination - collectionEdit")
        case .sourceEdit(_, _):
            Logger.navigation.info("destination - sourceEdit")
        case .clipEdit(_, _):
            Logger.navigation.info("destination - clipEdit")

        }
    }
}
