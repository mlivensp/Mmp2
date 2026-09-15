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
        case "Collections":
            CollectionsView()
        case "Playlists":
            Text("Playlists")
        case "Favorites":
            Text("Favorites")
        case "Recents":
            Text("Recents")
        case "Fix Locations":
            Text("Fix Locations")
        default:
            Text("Please choose a group from the sidebar.")
        }
    }
}

#Preview {
    ContentView()
}
