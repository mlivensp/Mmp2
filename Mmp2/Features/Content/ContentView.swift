//
//  ContentView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppRootManager.self) var appRootManager
    
    var body: some View {
        switch appRootManager.selectedCategory {
        case .collections:
            CollectionsView()
        case .playlists:
            Text("Playlists")
        case .favorites:
            Text("Favorites")
        case .recents:
            Text("Recents")
        case .sourceEdit:
            CollectionsView()
        case .clipEdit:
            CollectionsView()
        }
//        case "Fix Locations":
//            Text("Fix Locations")
//        default:
//            Text("Please choose a group from the sidebar.")
//        }
    }
}

#Preview {
    ContentView()
}
