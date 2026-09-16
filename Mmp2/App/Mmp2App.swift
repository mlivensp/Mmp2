//
//  Mmp2App.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

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
                        NavigationStack {
                            ZStack {
                                switch appRootManager.selectedCategory {
                                case "Collections":
                                    if appRootManager.selectedMediaCollection == nil {
                                        ContentUnavailableView {
                                            Label("No content selected", systemImage: "exclamationmark.triangle.fill")
                                        }
                                    } else {
                                        SourcesView()
                                    }
                                case "Playlists":
                                    Text("Playlists")
//                                    PlaylistsView(dataController: dataController)
                                case "Favorites":
                                    Text("Favorites")
                                case "Recents":
                                    Text("Recents")
//                                    RecentsView(dataController: dataController)
                                case "Fix Locations":
                                    Text("Fix Locations")
//                                    FixLocationsView(dataController: dataController)
                                default:
                                    Text("Please choose a group from the sidebar.")
                                }
                           }
//                            .navigationDestination(for: NavigationDestination.self) { navigationDestination in
//                                switch navigationDestination {
//                                case .player(let mediaSource):
//                                    let _ = dataController.selectedMediaSource = mediaSource
//                                    ContentUnavailableView {
//                                        Label("Detail View", systemImage: "exclamationmark.triangle.fill")
//                                    }
////                                    PlayerView(dataController: dataController, mediaSource: mediaSource)
//                                }
//                            }
                        }
                     }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(appRootManager)
    }
}
