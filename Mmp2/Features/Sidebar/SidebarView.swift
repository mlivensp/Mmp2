//
//  SidebarView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SidebarView: View {
    @Environment(AppRootManager.self) var appRootManager
    
    let items = [
        "Collections",
        "Playlists",
        "Recents",
        "Favorites",
        "Fix Locations"
    ]
    
    @State private var selectedCategory: String?

    init() {
    }

    var body: some View {
        @Bindable var appRootManager = appRootManager
        
        List(selection: $appRootManager.selectedCategory) {
            ForEach(items, id: \.self) { item in
                NavigationLink(value: item) {
                    Text(item)
                }
            }
        }
    }
}

#Preview {
    SidebarView()
}
